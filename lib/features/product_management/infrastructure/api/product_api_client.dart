import 'package:dio/dio.dart';
import '../dtos/product_dto.dart';

/// API client for Product Management backend communication
/// Handles HTTP requests to Go backend API
class ProductApiClient {
  final Dio _dio;
  final String _baseUrl;

  ProductApiClient({
    required Dio dio,
    String baseUrl = '/api/v1/products',
  })  : _dio = dio,
        _baseUrl = baseUrl;

  // ========== CRUD Operations ==========

  /// Get all products with pagination
  Future<ProductListResponseDto> getProducts({
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (tenantId != null) queryParams['tenantId'] = tenantId;
      if (companyId != null) queryParams['companyId'] = companyId;

      final response = await _dio.get(
        _baseUrl,
        queryParameters: queryParams,
      );

      return ProductListResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get product by ID
  Future<ProductDto> getProductById(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/$id');
      return ProductDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new product
  Future<ProductDto> createProduct(ProductDto product) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: product.toJson(),
      );
      return ProductDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update existing product
  Future<ProductDto> updateProduct(String id, ProductDto product) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/$id',
        data: product.toJson(),
      );
      return ProductDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete product (soft delete)
  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('$_baseUrl/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== Search & Filter Operations ==========

  /// Search products by query
  Future<ProductListResponseDto> searchProducts({
    required String query,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
      };
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (tenantId != null) queryParams['tenantId'] = tenantId;
      if (companyId != null) queryParams['companyId'] = companyId;

      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: queryParams,
      );

      return ProductListResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get products by category
  Future<ProductListResponseDto> getProductsByCategory({
    required String category,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'category': category,
      };
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (tenantId != null) queryParams['tenantId'] = tenantId;
      if (companyId != null) queryParams['companyId'] = companyId;

      final response = await _dio.get(
        '$_baseUrl/filter',
        queryParameters: queryParams,
      );

      return ProductListResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get products by status
  Future<ProductListResponseDto> getProductsByStatus({
    required String status,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'status': status,
      };
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (tenantId != null) queryParams['tenantId'] = tenantId;
      if (companyId != null) queryParams['companyId'] = companyId;

      final response = await _dio.get(
        '$_baseUrl/filter',
        queryParameters: queryParams,
      );

      return ProductListResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get invoiceable products (active, with price, in stock)
  Future<ProductListResponseDto> getInvoiceableProducts({
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'invoiceable': true,
      };
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (tenantId != null) queryParams['tenantId'] = tenantId;
      if (companyId != null) queryParams['companyId'] = companyId;

      final response = await _dio.get(
        '$_baseUrl/invoiceable',
        queryParameters: queryParams,
      );

      return ProductListResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get low stock products
  Future<ProductListResponseDto> getLowStockProducts({
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (tenantId != null) queryParams['tenantId'] = tenantId;
      if (companyId != null) queryParams['companyId'] = companyId;

      final response = await _dio.get(
        '$_baseUrl/low-stock',
        queryParameters: queryParams,
      );

      return ProductListResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== Inventory Operations ==========

  /// Update product stock
  Future<ProductDto> updateStock({
    required String productId,
    required int newStock,
    String? reason,
  }) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/$productId/stock',
        data: {
          'newStock': newStock,
          if (reason != null) 'reason': reason,
        },
      );
      return ProductDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== Business Logic Operations ==========

  /// Find duplicate product
  Future<ProductDto?> findDuplicateProduct({
    required String name,
    required String category,
    String? brand,
    String? excludeId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'name': name,
        'category': category,
      };
      if (brand != null) queryParams['brand'] = brand;
      if (excludeId != null) queryParams['excludeId'] = excludeId;

      final response = await _dio.get(
        '$_baseUrl/check-duplicate',
        queryParameters: queryParams,
      );

      if (response.data == null) return null;
      return ProductDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleError(e);
    }
  }

  /// Validate product sale
  Future<Map<String, dynamic>> validateSale({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/$productId/validate-sale',
        data: {
          'quantity': quantity,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get product statistics
  Future<Map<String, dynamic>> getProductStats(String productId) async {
    try {
      final response = await _dio.get('$_baseUrl/$productId/stats');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== Batch Operations ==========

  /// Bulk create products
  Future<List<ProductDto>> bulkCreateProducts(List<ProductDto> products) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/bulk',
        data: {
          'products': products.map((p) => p.toJson()).toList(),
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((item) => ProductDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Bulk update products
  Future<List<ProductDto>> bulkUpdateProducts(List<ProductDto> products) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/bulk',
        data: {
          'products': products.map((p) => p.toJson()).toList(),
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((item) => ProductDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== Error Handling ==========

  /// Handle Dio errors and convert to domain exceptions
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timeout. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error';

        switch (statusCode) {
          case 400:
            return BadRequestException(message);
          case 401:
            return UnauthorizedException('Authentication required');
          case 403:
            return ForbiddenException('Access denied');
          case 404:
            return NotFoundException('Resource not found');
          case 409:
            return ConflictException(message);
          case 422:
            return ValidationException(message);
          case 500:
            return ServerException('Internal server error');
          default:
            return ServerException('Server error: $message');
        }

      case DioExceptionType.cancel:
        return RequestCancelledException('Request was cancelled');

      case DioExceptionType.connectionError:
        return NetworkException('No internet connection');

      default:
        return UnknownException('An unexpected error occurred');
    }
  }
}

// ========== Custom Exceptions ==========

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}

class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  @override
  String toString() => message;
}

class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);
  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}

class RequestCancelledException implements Exception {
  final String message;
  RequestCancelledException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class UnknownException implements Exception {
  final String message;
  UnknownException(this.message);
  @override
  String toString() => message;
}
