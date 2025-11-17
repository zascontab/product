import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/errors/failure_commons.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_entity.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_sync_meta_data.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_enums.dart';
import 'package:rantipay_app/features/product_management/domain/entities/tax_configuration.dart';
import 'package:rantipay_app/features/product_management/domain/repositories/product_repository.dart';

/// Mock implementation of IProductRepository for testing and development
/// Provides hardcoded sample data to test product search functionality
@Injectable(as: IProductRepository)
class ProductRepositoryMock implements IProductRepository {
  /// Hardcoded sample products for testing
  static final List<ProductEntity> _mockProducts = [
    ProductEntity(
      id: EntityIdentifier.temp('1'),
      metadata: EntityMetadata.create(),
      status: EntityStatus.active(),
      syncMeta: SyncMetadata.notSynced(),
      code: 'PROD001',
      name: 'Laptop Dell Inspiron 15',
      description: 'Laptop Dell Inspiron 15, 8GB RAM, 256GB SSD',
      barcode: '1234567890123',
      brand: 'Dell',
      model: 'Inspiron 15',
      basePrice: 850.00,
      salePrice: 950.00,
      priceConfig: const PriceConfiguration(),
      inventoryConfig: const InventoryConfiguration(
        isManaged: true,
        currentStock: 15,
        minStock: 5,
        maxStock: 50,
        unit: 'unidad',
      ),
      taxConfig: const TaxConfiguration(
        sriProductCode: '1234567890',
        sriIvaCode: '4',
        ivaRate: 15.0,
        iceRate: 0.0,
      ),
    ),
    ProductEntity(
      id: EntityIdentifier.temp('2'),
      metadata: EntityMetadata.create(),
      status: EntityStatus.active(),
      syncMeta: SyncMetadata.notSynced(),
      code: 'PROD002',
      name: 'Mouse Inalámbrico Logitech',
      description: 'Mouse inalámbrico Logitech MX Master 3',
      barcode: '1234567890124',
      brand: 'Logitech',
      model: 'MX Master 3',
      basePrice: 45.00,
      salePrice: 55.00,
      priceConfig: const PriceConfiguration(),
      inventoryConfig: const InventoryConfiguration(
        isManaged: true,
        currentStock: 25,
        minStock: 10,
        maxStock: 100,
        unit: 'unidad',
      ),
      taxConfig: const TaxConfiguration(
        sriProductCode: '1234567891',
        sriIvaCode: '4',
        ivaRate: 15.0,
        iceRate: 0.0,
      ),
    ),
    ProductEntity(
      id: EntityIdentifier.temp('3'),
      metadata: EntityMetadata.create(),
      status: EntityStatus.active(),
      syncMeta: SyncMetadata.notSynced(),
      code: 'PROD003',
      name: 'Teclado Mecánico Gaming',
      description: 'Teclado mecánico RGB para gaming',
      barcode: '1234567890125',
      brand: 'Corsair',
      model: 'K95 RGB',
      basePrice: 120.00,
      salePrice: 140.00,
      priceConfig: const PriceConfiguration(),
      inventoryConfig: const InventoryConfiguration(
        isManaged: true,
        currentStock: 8,
        minStock: 3,
        maxStock: 30,
        unit: 'unidad',
      ),
      taxConfig: const TaxConfiguration(
        sriProductCode: '1234567892',
        sriIvaCode: '4',
        ivaRate: 15.0,
        iceRate: 0.0,
      ),
    ),
    ProductEntity(
      id: EntityIdentifier.temp('4'),
      metadata: EntityMetadata.create(),
      status: EntityStatus.active(),
      syncMeta: SyncMetadata.notSynced(),
      code: 'SERV001',
      name: 'Servicio de Consultoría IT',
      description: 'Consultoría en tecnologías de información por hora',
      brand: '',
      model: '',
      basePrice: 50.00,
      salePrice: 65.00,
      type: ProductType.service,
      isService: true,
      priceConfig: const PriceConfiguration(),
      inventoryConfig: const InventoryConfiguration(
        isManaged: false,
        currentStock: 0,
        unit: 'hora',
      ),
      taxConfig: const TaxConfiguration(
        sriProductCode: '1234567893',
        sriIvaCode: '4',
        ivaRate: 15.0,
        iceRate: 0.0,
      ),
    ),
    ProductEntity(
      id: EntityIdentifier.temp('5'),
      metadata: EntityMetadata.create(),
      status: EntityStatus.active(),
      syncMeta: SyncMetadata.notSynced(),
      code: 'PROD005',
      name: 'Cable USB-C 2m',
      description: 'Cable USB-C de 2 metros para carga rápida',
      barcode: '1234567890126',
      brand: 'Anker',
      model: 'PowerLine+',
      basePrice: 12.00,
      salePrice: 18.00,
      priceConfig: const PriceConfiguration(),
      inventoryConfig: const InventoryConfiguration(
        isManaged: true,
        currentStock: 50,
        minStock: 20,
        maxStock: 200,
        unit: 'unidad',
      ),
      taxConfig: const TaxConfiguration(
        sriProductCode: '1234567894',
        sriIvaCode: '4',
        ivaRate: 15.0,
        iceRate: 0.0,
      ),
    ),
  ];

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> getEntities({
    int? limit,
    int? offset,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      var products = List<ProductEntity>.from(_mockProducts);

      if (offset != null && offset > 0) {
        if (offset >= products.length) {
          return (<ProductEntity>[], null);
        }
        products = products.sublist(offset);
      }

      if (limit != null && limit > 0) {
        products = products.take(limit).toList();
      }

      return (products, null);
    } catch (e) {
      return (null, FailureCommons.create('Error al obtener productos: $e'));
    }
  }

  @override
  Future<(ProductEntity?, FailureCommons?)> getEntityById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final product = _mockProducts.firstWhere(
        (p) => p.id.uniqueKey == id,
        orElse: () => throw Exception('Producto no encontrado'),
      );

      return (product, null);
    } catch (e) {
      return (null, FailureCommons.create('Producto no encontrado'));
    }
  }

  @override
  Future<(ProductEntity?, FailureCommons?)> createEntity(
      ProductEntity entity) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return (entity, null);
  }

  @override
  Future<(ProductEntity?, FailureCommons?)> updateEntity(
      ProductEntity entity) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return (entity, null);
  }

  @override
  Future<(bool, FailureCommons?)> deleteEntity(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return (true, null);
  }

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> searchProducts({
    required String query,
    int? limit,
    int? offset,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      if (query.trim().isEmpty) {
        return getEntities(limit: limit, offset: offset);
      }

      final searchTerm = query.toLowerCase();
      var filteredProducts = _mockProducts.where((product) {
        return product.name.toLowerCase().contains(searchTerm) ||
            product.code.toLowerCase().contains(searchTerm) ||
            product.description.toLowerCase().contains(searchTerm) ||
            (product.brand?.toLowerCase().contains(searchTerm) ?? false) ||
            (product.barcode?.contains(searchTerm) ?? false);
      }).toList();

      if (offset != null && offset > 0) {
        if (offset >= filteredProducts.length) {
          return (<ProductEntity>[], null);
        }
        filteredProducts = filteredProducts.sublist(offset);
      }

      if (limit != null && limit > 0) {
        filteredProducts = filteredProducts.take(limit).toList();
      }

      return (filteredProducts, null);
    } catch (e) {
      return (null, FailureCommons.create('Error en búsqueda: $e'));
    }
  }

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> getProductsByCategory(
    String category, {
    int? limit,
    int? offset,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      var filteredProducts = _mockProducts.where((product) {
        return product.category
            .toString()
            .toLowerCase()
            .contains(category.toLowerCase());
      }).toList();

      if (offset != null && offset > 0) {
        if (offset >= filteredProducts.length) {
          return (<ProductEntity>[], null);
        }
        filteredProducts = filteredProducts.sublist(offset);
      }

      if (limit != null && limit > 0) {
        filteredProducts = filteredProducts.take(limit).toList();
      }

      return (filteredProducts, null);
    } catch (e) {
      return (
        null,
        FailureCommons.create('Error al obtener productos por categoría: $e')
      );
    }
  }

  @override
  Future<(ProductEntity?, FailureCommons?)> findDuplicateProduct({
    required String name,
    required String category,
    String? brand,
    String? excludeId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return (null, null); // No duplicates in mock data
  }

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> getLowStockProducts({
    int? limit,
    int? offset,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      var lowStockProducts = _mockProducts.where((product) {
        return product.inventoryConfig.isManaged &&
            product.inventoryConfig.minStock != null &&
            product.inventoryConfig.currentStock <
                product.inventoryConfig.minStock!;
      }).toList();

      if (offset != null && offset > 0) {
        if (offset >= lowStockProducts.length) {
          return (<ProductEntity>[], null);
        }
        lowStockProducts = lowStockProducts.sublist(offset);
      }

      if (limit != null && limit > 0) {
        lowStockProducts = lowStockProducts.take(limit).toList();
      }

      return (lowStockProducts, null);
    } catch (e) {
      return (
        null,
        FailureCommons.create('Error al obtener productos con stock bajo: $e')
      );
    }
  }

  // Implement remaining required methods with basic implementations
  @override
  Future<(List<ProductEntity>?, FailureCommons?)> getInvoiceableProducts({
    int? limit,
    int? offset,
  }) async {
    return getEntities(limit: limit, offset: offset);
  }
/* 
  @override
  Future<(Map<String, dynamic>?, FailureCommons?)> getProductStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ({'total': _mockProducts.length, 'active': _mockProducts.length}, null);
  }

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> getProductsByStatus(
    ProductStatus status, {
    int? limit,
    int? offset,
  }) async {
    var filteredProducts = _mockProducts.where((p) => p.productStatus == status).toList();
    return (filteredProducts, null);
  }

  @override
  Future<(bool, FailureCommons?)> validateSale({
    required String productId,
    required double quantity,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return (true, null); // Always valid in mock
  } */

  @override
  Future<(ProductEntity?, FailureCommons?)> updateStock({
    required String productId,
    required int newStock,
    String? reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      final productIndex =
          _mockProducts.indexWhere((p) => p.id.uniqueKey == productId);
      if (productIndex == -1) {
        return (null, FailureCommons.create('Producto no encontrado'));
      }

      final product = _mockProducts[productIndex];
      final updatedProduct = product.copyWith(
        inventoryConfig: product.inventoryConfig.copyWith(
          currentStock: newStock,
        ),
      );

      _mockProducts[productIndex] = updatedProduct;
      return (updatedProduct, null);
    } catch (e) {
      return (null, FailureCommons.create('Error al actualizar stock: $e'));
    }
  }

  @override
  Future<(Map<String, dynamic>?, FailureCommons?)> getProductStats(
      String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return (
      {'total': _mockProducts.length, 'active': _mockProducts.length},
      null
    );
  }

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> getProductsByStatus(
      String status,
      {int? limit,
      int? offset}) async {
    var filteredProducts =
        _mockProducts.where((p) => p.productStatus == status).toList();
    return (filteredProducts, null);
  }

  @override
  Future<(bool, List<String>)> validateSale(
      {required String productId, required int quantity}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final result = (true, <String>[]); // Always valid in mock
    return result;
  }
}
