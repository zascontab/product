import 'package:rantipay_app/core/errors/failure_commons.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';



/// Repository interface for product management
/// Provides product-specific operations without extending base repository
/// to avoid IBaseEntity constraint issues with Freezed
abstract class IProductRepository {
  /// Get all entities
  Future<(List<ProductEntity>?, FailureCommons?)> getEntities({
    int? limit,
    int? offset,
  });

  /// Get entity by ID
  Future<(ProductEntity?, FailureCommons?)> getEntityById(String id);

  /// Create new entity
  Future<(ProductEntity?, FailureCommons?)> createEntity(ProductEntity entity);

  /// Update existing entity
  Future<(ProductEntity?, FailureCommons?)> updateEntity(ProductEntity entity);

  /// Delete entity
  Future<(bool, FailureCommons?)> deleteEntity(String id);

  /// Search products by name, code, or barcode
  Future<(List<ProductEntity>?, FailureCommons?)> searchProducts({
    required String query,
    int? limit,
    int? offset,
  });

  /// Find products by category
  Future<(List<ProductEntity>?, FailureCommons?)> getProductsByCategory(
    String category, {
    int? limit,
    int? offset,
  });

  /// Check if a product with same characteristics already exists
  Future<(ProductEntity?, FailureCommons?)> findDuplicateProduct({
    required String name,
    required String category,
    String? brand,
    String? excludeId,
  });

  /// Get products with low stock
  Future<(List<ProductEntity>?, FailureCommons?)> getLowStockProducts({
    int? limit,
    int? offset,
  });

  /// Update product stock
  Future<(ProductEntity?, FailureCommons?)> updateStock({
    required String productId,
    required int newStock,
    String? reason,
  });

  /// Get products by status
  Future<(List<ProductEntity>?, FailureCommons?)> getProductsByStatus(
    String status, {
    int? limit,
    int? offset,
  });

  /// Get products suitable for invoice line items
  /// (active products with proper pricing)
  Future<(List<ProductEntity>?, FailureCommons?)> getInvoiceableProducts({
    int? limit,
    int? offset,
  });

  /// Validate if product can be sold in specified quantity
  Future<(bool, List<String>)> validateSale({
    required String productId,
    required int quantity,
  });

  /// Get product sales statistics
  Future<(Map<String, dynamic>?, FailureCommons?)> getProductStats(
    String productId,
  );
}
