import 'package:rantipay_app/core/errors/failure_commons.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';
import 'package:rantipay_app/features/product_management/domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../mappers/product_mapper.dart';
import '../api/product_api_client.dart';

/// Implementation of IProductRepository with offline-first pattern
/// Coordinates between local and remote data sources
/// Provides automatic fallback and sync capabilities
class ProductRepositoryImpl implements IProductRepository {
  final ProductLocalDataSource _localDataSource;
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl({
    required ProductLocalDataSource localDataSource,
    required ProductRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  // ========== GET OPERATIONS (Offline-First) ==========

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> getEntities({
    int? limit,
    int? offset,
  }) async {
    try {
      // 1. Try local cache first (offline-first)
      final cachedProducts = await _localDataSource.getAllProducts(
        limit: limit,
        offset: offset,
      );

      // 2. Return cached data immediately if available
      if (cachedProducts.isNotEmpty) {
        final entities = ProductMapper.tableDataListToEntityList(cachedProducts);

        // 3. Fetch fresh data in background (don't await)
        _refreshCacheInBackground();

        return (entities, null);
      }

      // 4. If no cache, fetch from remote
      final (remoteProducts, failure) = await _getFromRemote();
      if (failure != null) {
        return (null, failure);
      }

      // 5. Cache remote data
      if (remoteProducts != null && remoteProducts.isNotEmpty) {
        await _cacheProducts(remoteProducts);
      }

      return (remoteProducts, null);
    } catch (e) {
      return (null, FailureCommons.create('Failed to load products: $e'));
    }
  }

  @override
  Future<(ProductEntity?, FailureCommons?)> getEntityById(String id) async {
    try {
      // 1. Try local cache first
      final cachedProduct = await _localDataSource.getProductById(id);
      if (cachedProduct != null) {
        final entity = ProductMapper.tableDataToEntity(cachedProduct);
        return (entity, null);
      }

      // 2. Fetch from remote
      try {
        final remoteDto = await _remoteDataSource.getProductById(id);
        final entity = ProductMapper.dtoToEntity(remoteDto);

        // 3. Cache the product
        final tableData = ProductMapper.entityToTableData(entity);
        await _localDataSource.insertProduct(tableData);

        return (entity, null);
      } on NetworkException catch (e) {
        return (null, FailureCommons.network(e.message));
      } on NotFoundException catch (e) {
        return (null, FailureCommons.notFound(e.message));
      }
    } catch (e) {
      return (null, FailureCommons.create('Failed to load product: $e'));
    }
  }

  // ========== CREATE OPERATION (Optimistic Update) ==========

  @override
  Future<(ProductEntity?, FailureCommons?)> createEntity(ProductEntity entity) async {
    try {
      // 1. Save locally first (optimistic update)
      final tableData = ProductMapper.entityToTableData(entity);
      await _localDataSource.insertProduct(tableData);

      // 2. Try to sync to remote
      try {
        final dto = ProductMapper.entityToDto(entity);
        final createdDto = await _remoteDataSource.createProduct(dto);
        final syncedEntity = ProductMapper.dtoToEntity(createdDto);

        // 3. Update local with server ID
        final syncedTableData = ProductMapper.entityToTableData(syncedEntity);
        await _localDataSource.updateProduct(syncedTableData);
        await _localDataSource.markAsSynced(syncedEntity.id.uniqueKey, DateTime.now());

        return (syncedEntity, null);
      } on NetworkException catch (e) {
        // Return local entity, will sync later
        return (entity, null);
      } on ValidationException catch (e) {
        // Delete local entity if validation failed
        await _localDataSource.hardDeleteProduct(entity.id.uniqueKey);
        return (null, FailureCommons.validation(e.message));
      }
    } catch (e) {
      return (null, FailureCommons.create('Failed to create product: $e'));
    }
  }

  // ========== UPDATE OPERATION (Optimistic Update) ==========

  @override
  Future<(ProductEntity?, FailureCommons?)> updateEntity(ProductEntity entity) async {
    try {
      // 1. Update locally first (optimistic update)
      final tableData = ProductMapper.entityToTableData(entity);
      await _localDataSource.updateProduct(tableData);

      // 2. Try to sync to remote
      try {
        final dto = ProductMapper.entityToDto(entity);
        final updatedDto = await _remoteDataSource.updateProduct(
          entity.id.uniqueKey,
          dto,
        );
        final syncedEntity = ProductMapper.dtoToEntity(updatedDto);

        // 3. Update local with server response
        final syncedTableData = ProductMapper.entityToTableData(syncedEntity);
        await _localDataSource.updateProduct(syncedTableData);
        await _localDataSource.markAsSynced(syncedEntity.id.uniqueKey, DateTime.now());

        return (syncedEntity, null);
      } on NetworkException catch (e) {
        // Return local entity, will sync later
        return (entity, null);
      } on NotFoundException catch (e) {
        return (null, FailureCommons.notFound(e.message));
      }
    } catch (e) {
      return (null, FailureCommons.create('Failed to update product: $e'));
    }
  }

  // ========== DELETE OPERATION (Soft Delete) ==========

  @override
  Future<(bool, FailureCommons?)> deleteEntity(String id) async {
    try {
      // 1. Soft delete locally first
      await _localDataSource.softDeleteProduct(id);

      // 2. Try to sync to remote
      try {
        await _remoteDataSource.deleteProduct(id);
        return (true, null);
      } on NetworkException catch (e) {
        // Marked as deleted locally, will sync later
        return (true, null);
      } on NotFoundException catch (e) {
        // Already deleted on server
        return (true, null);
      }
    } catch (e) {
      return (false, FailureCommons.create('Failed to delete product: $e'));
    }
  }

  // ========== SEARCH OPERATIONS ==========

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> searchProducts({
    required String query,
    int? limit,
    int? offset,
  }) async {
    try {
      // 1. Search local cache first
      final cachedResults = await _localDataSource.searchProducts(
        query: query,
        limit: limit,
        offset: offset,
      );

      if (cachedResults.isNotEmpty) {
        final entities = ProductMapper.tableDataListToEntityList(cachedResults);
        return (entities, null);
      }

      // 2. Search remote if no local results
      try {
        final remoteResponse = await _remoteDataSource.searchProducts(
          query: query,
          limit: limit,
          offset: offset,
        );

        final entities = ProductMapper.dtoListToEntityList(remoteResponse.products);

        // Cache results
        if (entities.isNotEmpty) {
          await _cacheProducts(entities);
        }

        return (entities, null);
      } on NetworkException catch (e) {
        return ([], null); // Return empty list on network error
      }
    } catch (e) {
      return (null, FailureCommons.create('Failed to search products: $e'));
    }
  }

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> getProductsByCategory(
    String category, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Local first
      final cachedProducts = await _localDataSource.getProductsByCategory(
        category: category,
        limit: limit,
        offset: offset,
      );

      if (cachedProducts.isNotEmpty) {
        final entities = ProductMapper.tableDataListToEntityList(cachedProducts);
        return (entities, null);
      }

      // Remote fallback
      try {
        final remoteResponse = await _remoteDataSource.getProductsByCategory(
          category: category,
          limit: limit,
          offset: offset,
        );

        final entities = ProductMapper.dtoListToEntityList(remoteResponse.products);
        if (entities.isNotEmpty) {
          await _cacheProducts(entities);
        }

        return (entities, null);
      } on NetworkException catch (e) {
        return ([], null);
      }
    } catch (e) {
      return (null, FailureCommons.create('Failed to get products by category: $e'));
    }
  }

  @override
  Future<(ProductEntity?, FailureCommons?)> findDuplicateProduct({
    required String name,
    required String category,
    String? brand,
    String? excludeId,
  }) async {
    try {
      // Check local first
      final localDuplicate = await _localDataSource.findDuplicateProduct(
        name: name,
        category: category,
        brand: brand,
        excludeId: excludeId,
      );

      if (localDuplicate != null) {
        final entity = ProductMapper.tableDataToEntity(localDuplicate);
        return (entity, null);
      }

      // Check remote
      try {
        final remoteDto = await _remoteDataSource.findDuplicateProduct(
          name: name,
          category: category,
          brand: brand,
          excludeId: excludeId,
        );

        if (remoteDto != null) {
          final entity = ProductMapper.dtoToEntity(remoteDto);
          return (entity, null);
        }

        return (null, null);
      } on NetworkException catch (e) {
        return (null, null); // No duplicate found offline
      }
    } catch (e) {
      return (null, FailureCommons.create('Failed to check for duplicates: $e'));
    }
  }

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> getLowStockProducts({
    int? limit,
    int? offset,
  }) async {
    try {
      final cachedProducts = await _localDataSource.getLowStockProducts(
        limit: limit,
        offset: offset,
      );

      if (cachedProducts.isNotEmpty) {
        final entities = ProductMapper.tableDataListToEntityList(cachedProducts);
        return (entities, null);
      }

      try {
        final remoteResponse = await _remoteDataSource.getLowStockProducts(
          limit: limit,
          offset: offset,
        );

        final entities = ProductMapper.dtoListToEntityList(remoteResponse.products);
        return (entities, null);
      } on NetworkException catch (e) {
        return ([], null);
      }
    } catch (e) {
      return (null, FailureCommons.create('Failed to get low stock products: $e'));
    }
  }

  @override
  Future<(ProductEntity?, FailureCommons?)> updateStock({
    required String productId,
    required int newStock,
    String? reason,
  }) async {
    try {
      // Update locally first
      await _localDataSource.updateStock(
        productId: productId,
        newStock: newStock,
      );

      // Sync to remote
      try {
        final updatedDto = await _remoteDataSource.updateStock(
          productId: productId,
          newStock: newStock,
          reason: reason,
        );

        final entity = ProductMapper.dtoToEntity(updatedDto);

        // Update local cache
        final tableData = ProductMapper.entityToTableData(entity);
        await _localDataSource.updateProduct(tableData);

        return (entity, null);
      } on NetworkException catch (e) {
        // Get local version
        final local = await _localDataSource.getProductById(productId);
        if (local != null) {
          final entity = ProductMapper.tableDataToEntity(local);
          return (entity, null);
        }
        return (null, FailureCommons.network(e.message));
      }
    } catch (e) {
      return (null, FailureCommons.create('Failed to update stock: $e'));
    }
  }

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> getProductsByStatus(
    String status, {
    int? limit,
    int? offset,
  }) async {
    try {
      final cachedProducts = await _localDataSource.getProductsByStatus(
        status: status,
        limit: limit,
        offset: offset,
      );

      final entities = ProductMapper.tableDataListToEntityList(cachedProducts);
      return (entities, null);
    } catch (e) {
      return (null, FailureCommons.create('Failed to get products by status: $e'));
    }
  }

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> getInvoiceableProducts({
    int? limit,
    int? offset,
  }) async {
    try {
      // Local first for quick response
      final cachedProducts = await _localDataSource.getInvoiceableProducts(
        limit: limit,
        offset: offset,
      );

      if (cachedProducts.isNotEmpty) {
        final entities = ProductMapper.tableDataListToEntityList(cachedProducts);
        return (entities, null);
      }

      // Remote fallback
      try {
        final remoteResponse = await _remoteDataSource.getInvoiceableProducts(
          limit: limit,
          offset: offset,
        );

        final entities = ProductMapper.dtoListToEntityList(remoteResponse.products);
        if (entities.isNotEmpty) {
          await _cacheProducts(entities);
        }

        return (entities, null);
      } on NetworkException catch (e) {
        return ([], null);
      }
    } catch (e) {
      return (null, FailureCommons.create('Failed to get invoiceable products: $e'));
    }
  }

  @override
  Future<(bool, List<String>)> validateSale({
    required String productId,
    required int quantity,
  }) async {
    try {
      // Check local product first
      final localProduct = await _localDataSource.getProductById(productId);
      if (localProduct == null) {
        return (false, ['Product not found']);
      }

      final entity = ProductMapper.tableDataToEntity(localProduct);

      // Local validation
      final errors = <String>[];

      if (!entity.isActive || entity.productStatus != ProductStatus.active) {
        errors.add('Product is not active');
      }

      if (entity.inventoryConfig.isManaged) {
        if (entity.inventoryConfig.currentStock < quantity &&
            !entity.inventoryConfig.allowNegativeStock) {
          errors.add('Insufficient stock. Available: ${entity.inventoryConfig.currentStock}');
        }
      }

      if (entity.salePrice <= 0) {
        errors.add('Invalid sale price');
      }

      if (errors.isNotEmpty) {
        return (false, errors);
      }

      // Try remote validation
      try {
        final result = await _remoteDataSource.validateSale(
          productId: productId,
          quantity: quantity,
        );

        final isValid = result['isValid'] as bool? ?? true;
        final remoteErrors = (result['errors'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [];

        return (isValid, remoteErrors);
      } on NetworkException catch (e) {
        // Return local validation result
        return (true, []);
      }
    } catch (e) {
      return (false, ['Validation failed: $e']);
    }
  }

  @override
  Future<(Map<String, dynamic>?, FailureCommons?)> getProductStats(
    String productId,
  ) async {
    try {
      final remoteStats = await _remoteDataSource.getProductStats(productId);
      return (remoteStats, null);
    } on NetworkException catch (e) {
      // Return local stats if available
      final localProduct = await _localDataSource.getProductById(productId);
      if (localProduct != null) {
        final stats = {
          'salesCount': localProduct.salesCount,
          'totalSalesValue': localProduct.totalSalesValue,
          'lastSaleDate': localProduct.lastSaleDate?.toIso8601String(),
          'currentStock': localProduct.currentStock,
        };
        return (stats, null);
      }
      return (null, FailureCommons.network(e.message));
    } catch (e) {
      return (null, FailureCommons.create('Failed to get product stats: $e'));
    }
  }

  // ========== HELPER METHODS ==========

  /// Fetch products from remote and return entities
  Future<(List<ProductEntity>?, FailureCommons?)> _getFromRemote() async {
    try {
      final remoteResponse = await _remoteDataSource.getProducts();
      final entities = ProductMapper.dtoListToEntityList(remoteResponse.products);
      return (entities, null);
    } on NetworkException catch (e) {
      return (null, FailureCommons.network(e.message));
    } on ServerException catch (e) {
      return (null, FailureCommons.server(e.message));
    } catch (e) {
      return (null, FailureCommons.create('Remote fetch failed: $e'));
    }
  }

  /// Cache products in local database
  Future<void> _cacheProducts(List<ProductEntity> products) async {
    try {
      final tableDataList = ProductMapper.entityListToTableDataList(products);
      await _localDataSource.insertProducts(tableDataList);
    } catch (e) {
      // Silently fail cache operations
      print('Cache failed: $e');
    }
  }

  /// Refresh cache in background (fire and forget)
  void _refreshCacheInBackground() {
    Future.delayed(Duration.zero, () async {
      try {
        final (remoteProducts, failure) = await _getFromRemote();
        if (remoteProducts != null && failure == null) {
          await _cacheProducts(remoteProducts);
        }
      } catch (e) {
        // Silently fail background refresh
        print('Background refresh failed: $e');
      }
    });
  }

  /// Sync unsynced products to remote (for background sync)
  Future<void> syncUnsyncedProducts() async {
    try {
      final unsyncedProducts = await _localDataSource.getUnsyncedProducts();

      for (final productData in unsyncedProducts) {
        try {
          final entity = ProductMapper.tableDataToEntity(productData);
          final dto = ProductMapper.entityToDto(entity);

          // Determine if create or update
          if (entity.id.hasServerId) {
            await _remoteDataSource.updateProduct(entity.id.serverId!, dto);
          } else {
            await _remoteDataSource.createProduct(dto);
          }

          await _localDataSource.markAsSynced(productData.id, DateTime.now());
        } catch (e) {
          // Continue with next product
          print('Failed to sync product ${productData.id}: $e');
        }
      }
    } catch (e) {
      print('Sync failed: $e');
    }
  }
}
