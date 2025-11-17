import 'package:drift/drift.dart';
import 'product_table.dart';

part 'product_dao.g.dart';

/// Data Access Object for Product operations
/// Handles all database CRUD operations for products
@DriftAccessor(tables: [ProductTable])
class ProductDao extends DatabaseAccessor<ProductDatabase> with _$ProductDaoMixin {
  ProductDao(ProductDatabase db) : super(db);

  // ========== CREATE ==========

  /// Insert a new product
  Future<int> insertProduct(ProductTableCompanion product) {
    return into(productTable).insert(product);
  }

  /// Insert a complete product
  Future<int> insertProductData(ProductTableData product) {
    return into(productTable).insert(product);
  }

  /// Insert multiple products (bulk)
  Future<void> insertProducts(List<ProductTableData> products) async {
    await batch((batch) {
      batch.insertAll(productTable, products);
    });
  }

  // ========== READ ==========

  /// Get all products (non-deleted)
  Future<List<ProductTableData>> getAllProducts({
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) {
    final query = select(productTable)
      ..where((tbl) => tbl.status.isNotValue('deleted'))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    if (tenantId != null) {
      query.where((tbl) => tbl.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      query.where((tbl) => tbl.companyId.equals(companyId));
    }
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }

    return query.get();
  }

  /// Get product by ID
  Future<ProductTableData?> getProductById(String id) {
    return (select(productTable)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Search products by query (name, code, description, barcode)
  Future<List<ProductTableData>> searchProducts({
    required String query,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) {
    final searchQuery = select(productTable)
      ..where((tbl) =>
          (tbl.name.contains(query) |
           tbl.code.contains(query) |
           tbl.description.contains(query) |
           (tbl.barcode.isNotNull() & tbl.barcode.contains(query))) &
          tbl.status.isNotValue('deleted'))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    if (tenantId != null) {
      searchQuery.where((tbl) => tbl.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      searchQuery.where((tbl) => tbl.companyId.equals(companyId));
    }
    if (limit != null) {
      searchQuery.limit(limit, offset: offset ?? 0);
    }

    return searchQuery.get();
  }

  /// Get products by category
  Future<List<ProductTableData>> getProductsByCategory({
    required String category,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) {
    final query = select(productTable)
      ..where((tbl) => tbl.category.equals(category) & tbl.status.isNotValue('deleted'))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    if (tenantId != null) {
      query.where((tbl) => tbl.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      query.where((tbl) => tbl.companyId.equals(companyId));
    }
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }

    return query.get();
  }

  /// Get products by status
  Future<List<ProductTableData>> getProductsByStatus({
    required String status,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) {
    final query = select(productTable)
      ..where((tbl) => tbl.status.equals(status))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    if (tenantId != null) {
      query.where((tbl) => tbl.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      query.where((tbl) => tbl.companyId.equals(companyId));
    }
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }

    return query.get();
  }

  /// Get invoiceable products (active, with price, in stock or stock not managed)
  Future<List<ProductTableData>> getInvoiceableProducts({
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) {
    final query = select(productTable)
      ..where((tbl) =>
          tbl.status.equals('active') &
          tbl.isActive.equals(true) &
          tbl.salePrice.isBiggerThanValue(0.0) &
          ((tbl.inventoryManaged.equals(false)) |
           (tbl.currentStock.isBiggerThanValue(0)) |
           tbl.allowNegativeStock.equals(true)))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);

    if (tenantId != null) {
      query.where((tbl) => tbl.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      query.where((tbl) => tbl.companyId.equals(companyId));
    }
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }

    return query.get();
  }

  /// Get low stock products
  Future<List<ProductTableData>> getLowStockProducts({
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) {
    final query = select(productTable)
      ..where((tbl) =>
          tbl.inventoryManaged.equals(true) &
          tbl.status.isNotValue('deleted') &
          ((tbl.currentStock.isSmallerOrEqualValue(tbl.minStock)) |
           (tbl.currentStock.isSmallerOrEqualValue(tbl.reorderPoint))))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.currentStock)]);

    if (tenantId != null) {
      query.where((tbl) => tbl.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      query.where((tbl) => tbl.companyId.equals(companyId));
    }
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }

    return query.get();
  }

  /// Get unsynced products
  Future<List<ProductTableData>> getUnsyncedProducts({
    String? tenantId,
    String? companyId,
  }) {
    final query = select(productTable)
      ..where((tbl) => tbl.isSynced.equals(false));

    if (tenantId != null) {
      query.where((tbl) => tbl.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      query.where((tbl) => tbl.companyId.equals(companyId));
    }

    return query.get();
  }

  // ========== UPDATE ==========

  /// Update a product
  Future<bool> updateProduct(ProductTableData product) {
    return update(productTable).replace(product);
  }

  /// Update product companion
  Future<int> updateProductCompanion(String id, ProductTableCompanion companion) {
    return (update(productTable)..where((tbl) => tbl.id.equals(id))).write(companion);
  }

  /// Update product stock
  Future<int> updateStock({
    required String productId,
    required int newStock,
  }) {
    return (update(productTable)..where((tbl) => tbl.id.equals(productId)))
        .write(ProductTableCompanion(
      currentStock: Value(newStock),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Mark product as synced
  Future<int> markAsSynced(String id, DateTime syncTime) {
    return (update(productTable)..where((tbl) => tbl.id.equals(id)))
        .write(ProductTableCompanion(
      isSynced: const Value(true),
      lastSyncAt: Value(syncTime),
      syncStatus: const Value('synced'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // ========== DELETE ==========

  /// Soft delete (set status to 'deleted')
  Future<int> softDeleteProduct(String id) {
    return (update(productTable)..where((tbl) => tbl.id.equals(id)))
        .write(ProductTableCompanion(
      status: const Value('deleted'),
      deletedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Hard delete (permanent removal)
  Future<int> hardDeleteProduct(String id) {
    return (delete(productTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Delete all products (for testing/cleanup)
  Future<int> deleteAllProducts() {
    return delete(productTable).go();
  }

  // ========== STATISTICS ==========

  /// Count products by criteria
  Future<int> countProducts({
    String? status,
    String? tenantId,
    String? companyId,
  }) async {
    final query = selectOnly(productTable)
      ..addColumns([productTable.id.count()]);

    if (status != null) {
      query.where(productTable.status.equals(status));
    } else {
      query.where(productTable.status.isNotValue('deleted'));
    }

    if (tenantId != null) {
      query.where(productTable.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      query.where(productTable.companyId.equals(companyId));
    }

    final count = await query
        .map((row) => row.read(productTable.id.count()))
        .getSingleOrNull();

    return count ?? 0;
  }

  /// Get product statistics
  Future<Map<String, dynamic>> getProductStats({
    String? tenantId,
    String? companyId,
  }) async {
    final totalActive = await countProducts(
      status: 'active',
      tenantId: tenantId,
      companyId: companyId,
    );

    final totalInactive = await countProducts(
      status: 'inactive',
      tenantId: tenantId,
      companyId: companyId,
    );

    final lowStock = await getLowStockProducts(
      tenantId: tenantId,
      companyId: companyId,
    );

    final unsynced = await getUnsyncedProducts(
      tenantId: tenantId,
      companyId: companyId,
    );

    return {
      'totalActive': totalActive,
      'totalInactive': totalInactive,
      'lowStockCount': lowStock.length,
      'unsyncedCount': unsynced.length,
      'total': totalActive + totalInactive,
    };
  }

  // ========== UTILITY ==========

  /// Check if product code exists
  Future<bool> productCodeExists(String code, {String? excludeId}) async {
    final query = select(productTable)
      ..where((tbl) => tbl.code.equals(code) & tbl.status.isNotValue('deleted'));

    if (excludeId != null) {
      query.where((tbl) => tbl.id.isNotValue(excludeId));
    }

    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Find duplicate products
  Future<ProductTableData?> findDuplicateProduct({
    required String name,
    required String category,
    String? brand,
    String? excludeId,
  }) async {
    final query = select(productTable)
      ..where((tbl) =>
          tbl.name.equals(name) &
          tbl.category.equals(category) &
          tbl.status.isNotValue('deleted'));

    if (brand != null) {
      query.where((tbl) => tbl.brand.equals(brand));
    }

    if (excludeId != null) {
      query.where((tbl) => tbl.id.isNotValue(excludeId));
    }

    return query.getSingleOrNull();
  }

  /// Watch all products (stream)
  Stream<List<ProductTableData>> watchAllProducts({
    String? tenantId,
    String? companyId,
  }) {
    final query = select(productTable)
      ..where((tbl) => tbl.status.isNotValue('deleted'))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    if (tenantId != null) {
      query.where((tbl) => tbl.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      query.where((tbl) => tbl.companyId.equals(companyId));
    }

    return query.watch();
  }

  /// Watch product by ID (stream)
  Stream<ProductTableData?> watchProduct(String id) {
    return (select(productTable)..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull();
  }
}

/// Base database class (to be extended)
/// This should be defined in your main database file
abstract class ProductDatabase extends GeneratedDatabase {
  ProductDatabase(QueryExecutor e) : super(e);

  late final ProductTable productTable = ProductTable();
}
