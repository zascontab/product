import '../database/product_dao.dart';
import '../database/product_table.dart';

/// Local data source for product persistence
/// Encapsulates Drift database operations
class ProductLocalDataSource {
  final ProductDao _dao;

  ProductLocalDataSource({required ProductDao dao}) : _dao = dao;

  // ========== CRUD Operations ==========

  Future<ProductTableData?> getProductById(String id) async {
    return await _dao.getProductById(id);
  }

  Future<List<ProductTableData>> getAllProducts({
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    return await _dao.getAllProducts(
      limit: limit,
      offset: offset,
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  Future<int> insertProduct(ProductTableData product) async {
    return await _dao.insertProductData(product);
  }

  Future<void> insertProducts(List<ProductTableData> products) async {
    return await _dao.insertProducts(products);
  }

  Future<bool> updateProduct(ProductTableData product) async {
    return await _dao.updateProduct(product);
  }

  Future<int> softDeleteProduct(String id) async {
    return await _dao.softDeleteProduct(id);
  }

  Future<int> hardDeleteProduct(String id) async {
    return await _dao.hardDeleteProduct(id);
  }

  // ========== Search & Filter Operations ==========

  Future<List<ProductTableData>> searchProducts({
    required String query,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    return await _dao.searchProducts(
      query: query,
      limit: limit,
      offset: offset,
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  Future<List<ProductTableData>> getProductsByCategory({
    required String category,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    return await _dao.getProductsByCategory(
      category: category,
      limit: limit,
      offset: offset,
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  Future<List<ProductTableData>> getProductsByStatus({
    required String status,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    return await _dao.getProductsByStatus(
      status: status,
      limit: limit,
      offset: offset,
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  Future<List<ProductTableData>> getInvoiceableProducts({
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    return await _dao.getInvoiceableProducts(
      limit: limit,
      offset: offset,
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  Future<List<ProductTableData>> getLowStockProducts({
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    return await _dao.getLowStockProducts(
      limit: limit,
      offset: offset,
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  // ========== Sync Operations ==========

  Future<List<ProductTableData>> getUnsyncedProducts({
    String? tenantId,
    String? companyId,
  }) async {
    return await _dao.getUnsyncedProducts(
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  Future<int> markAsSynced(String id, DateTime syncTime) async {
    return await _dao.markAsSynced(id, syncTime);
  }

  // ========== Inventory Operations ==========

  Future<int> updateStock({
    required String productId,
    required int newStock,
  }) async {
    return await _dao.updateStock(
      productId: productId,
      newStock: newStock,
    );
  }

  // ========== Business Logic Operations ==========

  Future<bool> productCodeExists(String code, {String? excludeId}) async {
    return await _dao.productCodeExists(code, excludeId: excludeId);
  }

  Future<ProductTableData?> findDuplicateProduct({
    required String name,
    required String category,
    String? brand,
    String? excludeId,
  }) async {
    return await _dao.findDuplicateProduct(
      name: name,
      category: category,
      brand: brand,
      excludeId: excludeId,
    );
  }

  // ========== Statistics ==========

  Future<int> countProducts({
    String? status,
    String? tenantId,
    String? companyId,
  }) async {
    return await _dao.countProducts(
      status: status,
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  Future<Map<String, dynamic>> getProductStats({
    String? tenantId,
    String? companyId,
  }) async {
    return await _dao.getProductStats(
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  // ========== Streams ==========

  Stream<List<ProductTableData>> watchAllProducts({
    String? tenantId,
    String? companyId,
  }) {
    return _dao.watchAllProducts(
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  Stream<ProductTableData?> watchProduct(String id) {
    return _dao.watchProduct(id);
  }

  // ========== Utility ==========

  Future<int> deleteAllProducts() async {
    return await _dao.deleteAllProducts();
  }

  Future<void> clearCache() async {
    await _dao.deleteAllProducts();
  }
}
