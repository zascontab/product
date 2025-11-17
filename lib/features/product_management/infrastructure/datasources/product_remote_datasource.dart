import '../api/product_api_client.dart';
import '../dtos/product_dto.dart';

/// Remote data source for product API communication
/// Encapsulates HTTP requests to backend
class ProductRemoteDataSource {
  final ProductApiClient _apiClient;

  ProductRemoteDataSource({required ProductApiClient apiClient})
      : _apiClient = apiClient;

  // ========== CRUD Operations ==========

  Future<ProductListResponseDto> getProducts({
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    return await _apiClient.getProducts(
      limit: limit,
      offset: offset,
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  Future<ProductDto> getProductById(String id) async {
    return await _apiClient.getProductById(id);
  }

  Future<ProductDto> createProduct(ProductDto product) async {
    return await _apiClient.createProduct(product);
  }

  Future<ProductDto> updateProduct(String id, ProductDto product) async {
    return await _apiClient.updateProduct(id, product);
  }

  Future<void> deleteProduct(String id) async {
    return await _apiClient.deleteProduct(id);
  }

  // ========== Search & Filter Operations ==========

  Future<ProductListResponseDto> searchProducts({
    required String query,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    return await _apiClient.searchProducts(
      query: query,
      limit: limit,
      offset: offset,
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  Future<ProductListResponseDto> getProductsByCategory({
    required String category,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    return await _apiClient.getProductsByCategory(
      category: category,
      limit: limit,
      offset: offset,
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  Future<ProductListResponseDto> getProductsByStatus({
    required String status,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    return await _apiClient.getProductsByStatus(
      status: status,
      limit: limit,
      offset: offset,
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  Future<ProductListResponseDto> getInvoiceableProducts({
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    return await _apiClient.getInvoiceableProducts(
      limit: limit,
      offset: offset,
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  Future<ProductListResponseDto> getLowStockProducts({
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    return await _apiClient.getLowStockProducts(
      limit: limit,
      offset: offset,
      tenantId: tenantId,
      companyId: companyId,
    );
  }

  // ========== Inventory Operations ==========

  Future<ProductDto> updateStock({
    required String productId,
    required int newStock,
    String? reason,
  }) async {
    return await _apiClient.updateStock(
      productId: productId,
      newStock: newStock,
      reason: reason,
    );
  }

  // ========== Business Logic Operations ==========

  Future<ProductDto?> findDuplicateProduct({
    required String name,
    required String category,
    String? brand,
    String? excludeId,
  }) async {
    return await _apiClient.findDuplicateProduct(
      name: name,
      category: category,
      brand: brand,
      excludeId: excludeId,
    );
  }

  Future<Map<String, dynamic>> validateSale({
    required String productId,
    required int quantity,
  }) async {
    return await _apiClient.validateSale(
      productId: productId,
      quantity: quantity,
    );
  }

  Future<Map<String, dynamic>> getProductStats(String productId) async {
    return await _apiClient.getProductStats(productId);
  }

  // ========== Batch Operations ==========

  Future<List<ProductDto>> bulkCreateProducts(List<ProductDto> products) async {
    return await _apiClient.bulkCreateProducts(products);
  }

  Future<List<ProductDto>> bulkUpdateProducts(List<ProductDto> products) async {
    return await _apiClient.bulkUpdateProducts(products);
  }
}
