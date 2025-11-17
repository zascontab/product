
import 'package:rantipay_app/core/errors/failure_commons.dart';

import '../../domain/common/pagination.dart';

/// Native tuple patterns - no external dependencies
/// Result type for remote data source operations using native Dart tuples
typedef RemoteDataSourceResult<T> = (T? data, FailureCommons? error);

/// Base interface for remote data sources
///
/// Provides consistent remote API operations with:
/// - RESTful CRUD operations with tuple error handling
/// - GraphQL query support
/// - Batch operations for efficiency
/// - Search and filtering capabilities
/// - Upload/download operations
/// - Authentication and authorization
abstract class IRemoteDataSource<TModel> {
  // ===== CORE CRUD OPERATIONS =====

  /// Creates a new model on the server
  /// Returns (model, error) tuple
  Future<RemoteDataSourceResult<TModel>> create(TModel model);

  /// Gets model by ID from the server
  /// Returns (model, error) tuple
  Future<RemoteDataSourceResult<TModel>> getById(String id);

  /// Updates existing model on the server
  /// Returns (model, error) tuple
  Future<RemoteDataSourceResult<TModel>> update(TModel model);

  /// Deletes model by ID on the server
  /// Returns (success, error) tuple
  Future<RemoteDataSourceResult<bool>> delete(String id);

  // ===== BATCH OPERATIONS =====

  /// Creates multiple models in a batch
  /// Returns (models, error) tuple
  Future<RemoteDataSourceResult<List<TModel>>> createBatch(List<TModel> models);

  /// Updates multiple models in a batch
  /// Returns (models, error) tuple
  Future<RemoteDataSourceResult<List<TModel>>> updateBatch(List<TModel> models);

  /// Deletes multiple models by IDs
  /// Returns (success, error) tuple
  Future<RemoteDataSourceResult<bool>> deleteBatch(List<String> ids);

  // ===== QUERY OPERATIONS =====

  /// Gets all models with pagination and filtering
  /// Returns (paginated result, error) tuple
  Future<RemoteDataSourceResult<PaginatedResult<TModel>>> getAll({
    Pagination? pagination,
    Map<String, dynamic>? filters,
    List<String>? sortBy,
  });

  /// Searches models by query
  /// Returns (paginated result, error) tuple
  Future<RemoteDataSourceResult<PaginatedResult<TModel>>> search({
    required String query,
    Pagination? pagination,
    Map<String, dynamic>? filters,
  });

  /// Gets models by multiple IDs
  /// Returns (models, error) tuple
  Future<RemoteDataSourceResult<List<TModel>>> getByIds(List<String> ids);

  /// Counts models matching filters
  /// Returns (count, error) tuple
  Future<RemoteDataSourceResult<int>> count({
    Map<String, dynamic>? filters,
  });

  // ===== SYNCHRONIZATION OPERATIONS =====

  /// Gets models modified after timestamp
  /// Returns (models, error) tuple
  Future<RemoteDataSourceResult<List<TModel>>> getModifiedAfter(
      DateTime timestamp);

  /// Gets models with specific sync status
  /// Returns (models, error) tuple
  Future<RemoteDataSourceResult<List<TModel>>> getBySyncStatus(String status);

  /// Synchronizes models with conflict detection
  /// Returns (sync result, error) tuple
  Future<RemoteDataSourceResult<SyncResult<TModel>>> syncModels(
      List<TModel> models);

  // ===== FILE OPERATIONS =====

  /// Uploads file and returns URL
  /// Returns (file URL, error) tuple
  Future<RemoteDataSourceResult<String>> uploadFile({
    required String filePath,
    String? fileName,
    Map<String, String>? metadata,
  });

  /// Downloads file from URL
  /// Returns (local file path, error) tuple
  Future<RemoteDataSourceResult<String>> downloadFile({
    required String fileUrl,
    String? localPath,
  });

  /// Deletes file from server
  /// Returns (success, error) tuple
  Future<RemoteDataSourceResult<bool>> deleteFile(String fileUrl);

  // ===== HEALTH AND MONITORING =====

  /// Checks server health
  /// Returns (health status, error) tuple
  Future<RemoteDataSourceResult<ServerHealth>> getServerHealth();

  /// Pings server for connectivity
  /// Returns (response time ms, error) tuple
  Future<RemoteDataSourceResult<int>> ping();

  /// Gets API version information
  /// Returns (version info, error) tuple
  Future<RemoteDataSourceResult<ApiVersion>> getApiVersion();
}

/// Base implementation with common HTTP/GraphQL functionality
abstract class BaseRemoteDataSource<TModel>
    implements IRemoteDataSource<TModel> {
  // Abstract methods for concrete implementations
  String get baseUrl;
  String get apiVersion;
  Map<String, String> get defaultHeaders;
  TModel fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(TModel model);
  String getModelId(TModel model);

  @override
  Future<RemoteDataSourceResult<TModel>> create(TModel model) async {
    try {
      final response = await post(
        '/models',
        body: toJson(model),
      );

      if (response.isSuccess) {
        final createdModel = fromJson(response.data);
        return (createdModel, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'create'));
    }
  }

  @override
  Future<RemoteDataSourceResult<TModel>> getById(String id) async {
    try {
      final response = await get('/models/$id');

      if (response.isSuccess) {
        final model = fromJson(response.data);
        return (model, null);
      } else if (response.statusCode == 404) {
        return (null, FailureCommons.dataNotFoundException());
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'getById'));
    }
  }

  @override
  Future<RemoteDataSourceResult<TModel>> update(TModel model) async {
    try {
      final id = getModelId(model);
      final response = await put(
        '/models/$id',
        body: toJson(model),
      );

      if (response.isSuccess) {
        final updatedModel = fromJson(response.data);
        return (updatedModel, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'update'));
    }
  }

  @override
  Future<RemoteDataSourceResult<bool>> delete(String id) async {
    try {
      final response = await deleteHttp('/models/$id');

      if (response.isSuccess) {
        return (true, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'delete'));
    }
  }

  @override
  Future<RemoteDataSourceResult<List<TModel>>> createBatch(
      List<TModel> models) async {
    try {
      final response = await post(
        '/models/batch',
        body: {
          'models': models.map(toJson).toList(),
        },
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data['models'] as List<dynamic>;
        final createdModels = data.map((json) => fromJson(json)).toList();
        return (createdModels, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'createBatch'));
    }
  }

  @override
  Future<RemoteDataSourceResult<PaginatedResult<TModel>>> getAll({
    Pagination? pagination,
    Map<String, dynamic>? filters,
    List<String>? sortBy,
  }) async {
    try {
      final queryParams = _buildQueryParams(
        pagination: pagination,
        filters: filters,
        sortBy: sortBy,
      );

      final response = await get('/models', queryParams: queryParams);

      if (response.isSuccess) {
        final List<dynamic> items = response.data['items'] as List<dynamic>;
        final models = items.map((json) => fromJson(json)).toList();

        final result = PaginatedResult<TModel>(
          items: models,
          pagination: _parsePagination(response.data['pagination']),
          totalCount: response.data['totalCount'] ?? models.length,
        );

        return (result, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'getAll'));
    }
  }

  @override
  Future<RemoteDataSourceResult<PaginatedResult<TModel>>> search({
    required String query,
    Pagination? pagination,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = _buildQueryParams(
        pagination: pagination,
        filters: {...(filters ?? {}), 'q': query},
      );

      final response = await get('/models/search', queryParams: queryParams);

      if (response.isSuccess) {
        final List<dynamic> items = response.data['items'] as List<dynamic>;
        final models = items.map((json) => fromJson(json)).toList();

        final result = PaginatedResult<TModel>(
          items: models,
          pagination: _parsePagination(response.data['pagination']),
          totalCount: response.data['totalCount'] ?? models.length,
        );

        return (result, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'search'));
    }
  }

  @override
  Future<RemoteDataSourceResult<List<TModel>>> getByIds(
      List<String> ids) async {
    try {
      final response = await post(
        '/models/by-ids',
        body: {'ids': ids},
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data['models'] as List<dynamic>;
        final models = data.map((json) => fromJson(json)).toList();
        return (models, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'getByIds'));
    }
  }

  @override
  Future<RemoteDataSourceResult<int>> count({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = filters != null
          ? Map<String, String>.from(
              filters.map((k, v) => MapEntry(k, v.toString())))
          : <String, String>{};

      final response = await get('/models/count', queryParams: queryParams);

      if (response.isSuccess) {
        final count = response.data['count'] as int;
        return (count, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'count'));
    }
  }

  @override
  Future<RemoteDataSourceResult<String>> uploadFile({
    required String filePath,
    String? fileName,
    Map<String, String>? metadata,
  }) async {
    try {
      final response = await uploadMultipart(
        '/files/upload',
        filePath: filePath,
        fileName: fileName,
        metadata: metadata,
      );

      if (response.isSuccess) {
        final fileUrl = response.data['fileUrl'] as String;
        return (fileUrl, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'uploadFile'));
    }
  }

  @override
  Future<RemoteDataSourceResult<ServerHealth>> getServerHealth() async {
    try {
      final response = await get('/health');

      if (response.isSuccess) {
        final health = ServerHealth.fromJson(response.data);
        return (health, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'getServerHealth'));
    }
  }

  @override
  Future<RemoteDataSourceResult<int>> ping() async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await get('/ping');
      stopwatch.stop();

      if (response.isSuccess) {
        return (stopwatch.elapsedMilliseconds, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'ping'));
    }
  }

  // Abstract methods for HTTP operations (to be implemented by concrete classes)
  Future<HttpResponse> get(String path, {Map<String, String>? queryParams});
  Future<HttpResponse> post(String path, {Map<String, dynamic>? body});
  Future<HttpResponse> put(String path, {Map<String, dynamic>? body});
  Future<HttpResponse> deleteHttp(String path);
  Future<HttpResponse> uploadMultipart(
    String path, {
    required String filePath,
    String? fileName,
    Map<String, String>? metadata,
  });

  // Helper methods
  Map<String, String> _buildQueryParams({
    Pagination? pagination,
    Map<String, dynamic>? filters,
    List<String>? sortBy,
  }) {
    final params = <String, String>{};

    if (pagination != null) {
      params['page'] = pagination.page.toString();
      params['offset'] = pagination.offset.toString();
      params['pageSize'] = pagination.pageSize.toString();
    }

    if (filters != null) {
      for (final entry in filters.entries) {
        params[entry.key] = entry.value.toString();
      }
    }

    if (sortBy != null && sortBy.isNotEmpty) {
      params['sortBy'] = sortBy.join(',');
    }

    return params;
  }

  Pagination _parsePagination(Map<String, dynamic>? data) {
    if (data == null) return Pagination.defaultPagination();

    return Pagination(
      page: data['page'] ?? 1,
      pageSize: data['pageSize'] ?? 20,
    );
  }

  FailureCommons _handleHttpError(HttpResponse response) {
    switch (response.statusCode) {
      case 400:
        return FailureCommons.create(response.message ?? 'Bad request');
      case 401:
        return FailureCommons.unauthorized();
      case 403:
        return FailureCommons.deviceNotAuthorized();
      case 404:
        return FailureCommons.dataNotFoundException();
      case 500:
        return FailureCommons.serverError();
      case 503:
        return FailureCommons.serverError();
      default:
        return FailureCommons.unexpected(
            response.message ?? 'HTTP ${response.statusCode}');
    }
  }

  FailureCommons _handleError(dynamic error, String operation) {
    if (error is FailureCommons) return error;
    return FailureCommons.unexpected(error);
  }

  // Default implementations for optional methods
  @override
  Future<RemoteDataSourceResult<List<TModel>>> updateBatch(
      List<TModel> models) async {
    try {
      final response = await put(
        '/models/batch',
        body: {
          'models': models.map(toJson).toList(),
        },
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data['models'] as List<dynamic>;
        final updatedModels = data.map((json) => fromJson(json)).toList();
        return (updatedModels, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'updateBatch'));
    }
  }

  @override
  Future<RemoteDataSourceResult<bool>> deleteBatch(List<String> ids) async {
    try {
      final response = await deleteHttp('/models/batch?ids=${ids.join(',')}');

      if (response.isSuccess) {
        return (true, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'deleteBatch'));
    }
  }

  @override
  Future<RemoteDataSourceResult<List<TModel>>> getModifiedAfter(
      DateTime timestamp) async {
    try {
      final response = await get(
        '/models/modified-after',
        queryParams: {'timestamp': timestamp.millisecondsSinceEpoch.toString()},
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data['models'] as List<dynamic>;
        final models = data.map((json) => fromJson(json)).toList();
        return (models, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'getModifiedAfter'));
    }
  }

  @override
  Future<RemoteDataSourceResult<List<TModel>>> getBySyncStatus(
      String status) async {
    try {
      final response = await get(
        '/models/by-sync-status',
        queryParams: {'status': status},
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data['models'] as List<dynamic>;
        final models = data.map((json) => fromJson(json)).toList();
        return (models, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'getBySyncStatus'));
    }
  }

  @override
  Future<RemoteDataSourceResult<SyncResult<TModel>>> syncModels(
      List<TModel> models) async {
    try {
      final response = await post(
        '/models/sync',
        body: {
          'models': models.map(toJson).toList(),
        },
      );

      if (response.isSuccess) {
        final syncResult = SyncResult<TModel>.fromJson(
          response.data,
          (json) => fromJson(json),
        );
        return (syncResult, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'syncModels'));
    }
  }

  @override
  Future<RemoteDataSourceResult<String>> downloadFile({
    required String fileUrl,
    String? localPath,
  }) async {
    try {
      final response = await downloadFileFromUrl(fileUrl, localPath);

      if (response.isSuccess) {
        final downloadedPath = response.data['filePath'] as String;
        return (downloadedPath, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'downloadFile'));
    }
  }

  @override
  Future<RemoteDataSourceResult<bool>> deleteFile(String fileUrl) async {
    try {
      final response = await deleteHttp('/files?url=$fileUrl');

      if (response.isSuccess) {
        return (true, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'deleteFile'));
    }
  }

  @override
  Future<RemoteDataSourceResult<ApiVersion>> getApiVersion() async {
    try {
      final response = await get('/version');

      if (response.isSuccess) {
        final version = ApiVersion.fromJson(response.data);
        return (version, null);
      } else {
        return (null, _handleHttpError(response));
      }
    } catch (e) {
      return (null, _handleError(e, 'getApiVersion'));
    }
  }

  // Abstract method for file download
  Future<HttpResponse> downloadFileFromUrl(String url, String? localPath);
}

/// HTTP response wrapper
class HttpResponse {
  final int statusCode;
  final Map<String, dynamic> data;
  final String? message;

  const HttpResponse({
    required this.statusCode,
    required this.data,
    this.message,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Sync result for batch operations
class SyncResult<T> {
  final List<T> created;
  final List<T> updated;
  final List<String> deleted;
  final List<ConflictInfo<T>> conflicts;
  final List<ErrorInfo> errors;

  const SyncResult({
    required this.created,
    required this.updated,
    required this.deleted,
    required this.conflicts,
    required this.errors,
  });

  factory SyncResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return SyncResult<T>(
      created:
          (json['created'] as List? ?? []).map((e) => fromJsonT(e)).toList(),
      updated:
          (json['updated'] as List? ?? []).map((e) => fromJsonT(e)).toList(),
      deleted: (json['deleted'] as List? ?? []).cast<String>(),
      conflicts: (json['conflicts'] as List? ?? [])
          .map((e) => ConflictInfo<T>.fromJson(e, fromJsonT))
          .toList(),
      errors: (json['errors'] as List? ?? [])
          .map((e) => ErrorInfo.fromJson(e))
          .toList(),
    );
  }
}

/// Conflict information
class ConflictInfo<T> {
  final String id;
  final T localVersion;
  final T serverVersion;
  final String conflictType;

  const ConflictInfo({
    required this.id,
    required this.localVersion,
    required this.serverVersion,
    required this.conflictType,
  });

  factory ConflictInfo.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ConflictInfo<T>(
      id: json['id'],
      localVersion: fromJsonT(json['localVersion']),
      serverVersion: fromJsonT(json['serverVersion']),
      conflictType: json['conflictType'],
    );
  }
}

/// Error information
class ErrorInfo {
  final String id;
  final String error;
  final String? details;

  const ErrorInfo({
    required this.id,
    required this.error,
    this.details,
  });

  factory ErrorInfo.fromJson(Map<String, dynamic> json) {
    return ErrorInfo(
      id: json['id'],
      error: json['error'],
      details: json['details'],
    );
  }
}

/// Server health information
class ServerHealth {
  final bool isHealthy;
  final String version;
  final DateTime timestamp;
  final Map<String, dynamic> services;

  const ServerHealth({
    required this.isHealthy,
    required this.version,
    required this.timestamp,
    required this.services,
  });

  factory ServerHealth.fromJson(Map<String, dynamic> json) {
    return ServerHealth(
      isHealthy: json['isHealthy'],
      version: json['version'],
      timestamp: DateTime.parse(json['timestamp']),
      services: json['services'] ?? {},
    );
  }
}

/// API version information
class ApiVersion {
  final String version;
  final String buildNumber;
  final DateTime buildDate;
  final List<String> supportedVersions;

  const ApiVersion({
    required this.version,
    required this.buildNumber,
    required this.buildDate,
    required this.supportedVersions,
  });

  factory ApiVersion.fromJson(Map<String, dynamic> json) {
    return ApiVersion(
      version: json['version'],
      buildNumber: json['buildNumber'],
      buildDate: DateTime.parse(json['buildDate']),
      supportedVersions: (json['supportedVersions'] as List).cast<String>(),
    );
  }
}
