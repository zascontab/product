
import 'package:rantipay_app/core/errors/failure_commons.dart';

import '../../domain/common/pagination.dart';

/// Native tuple patterns - no external dependencies
/// Result type for data source operations using native Dart tuples
typedef DataSourceResult<T> = (T? data, FailureCommons? error);

/// Base interface for local data sources
/// 
/// Provides consistent local database operations with:
/// - CRUD operations with tuple error handling
/// - Batch operations for performance
/// - Search and filtering capabilities
/// - Real-time data streaming
/// - Transaction support
abstract class ILocalDataSource<TModel> {
  
  // ===== CORE CRUD OPERATIONS =====
  
  /// Creates a new model in local storage
  /// Returns (model, error) tuple
  Future<DataSourceResult<TModel>> create(TModel model);
  
  /// Gets model by ID from local storage
  /// Returns (model, error) tuple
  Future<DataSourceResult<TModel>> getById(String id);
  
  /// Updates existing model in local storage
  /// Returns (model, error) tuple
  Future<DataSourceResult<TModel>> update(TModel model);
  
  /// Deletes model by ID from local storage
  /// Returns (success, error) tuple
  Future<DataSourceResult<bool>> delete(String id);
  
  // ===== BATCH OPERATIONS =====
  
  /// Creates multiple models in a batch
  /// Returns (models, error) tuple
  Future<DataSourceResult<List<TModel>>> createBatch(List<TModel> models);
  
  /// Updates multiple models in a batch
  /// Returns (models, error) tuple
  Future<DataSourceResult<List<TModel>>> updateBatch(List<TModel> models);
  
  /// Deletes multiple models by IDs
  /// Returns (success, error) tuple
  Future<DataSourceResult<bool>> deleteBatch(List<String> ids);
  
  // ===== QUERY OPERATIONS =====
  
  /// Gets all models with pagination and filtering
  /// Returns (paginated result, error) tuple
  Future<DataSourceResult<PaginatedResult<TModel>>> getAll({
    Pagination? pagination,
    Map<String, dynamic>? filters,
    List<String>? sortBy,
  });
  
  /// Searches models by query
  /// Returns (paginated result, error) tuple
  Future<DataSourceResult<PaginatedResult<TModel>>> search({
    required String query,
    Pagination? pagination,
    Map<String, dynamic>? filters,
  });
  
  /// Gets models by multiple IDs
  /// Returns (models, error) tuple
  Future<DataSourceResult<List<TModel>>> getByIds(List<String> ids);
  
  /// Counts models matching filters
  /// Returns (count, error) tuple
  Future<DataSourceResult<int>> count({
    Map<String, dynamic>? filters,
  });
  
  // ===== STREAM OPERATIONS =====
  
  /// Watches model changes by ID
  Stream<TModel?> watchById(String id);
  
  /// Watches all models with optional filtering
  Stream<List<TModel>> watchAll({
    Map<String, dynamic>? filters,
    List<String>? sortBy,
  });
  
  /// Watches count changes
  Stream<int> watchCount({
    Map<String, dynamic>? filters,
  });
  
  // ===== TRANSACTION OPERATIONS =====
  
  /// Executes operations in a transaction
  /// Returns (result, error) tuple
  Future<DataSourceResult<T>> transaction<T>(
    Future<T> Function() operation,
  );
  
  /// Executes read-only operations
  /// Returns (result, error) tuple
  Future<DataSourceResult<T>> readTransaction<T>(
    Future<T> Function() operation,
  );
  
  // ===== MAINTENANCE OPERATIONS =====
  
  /// Clears all data
  /// Returns (success, error) tuple
  Future<DataSourceResult<bool>> clear();
  
  /// Vacuums/optimizes the database
  /// Returns (success, error) tuple
  Future<DataSourceResult<bool>> vacuum();
  
  /// Gets database size in bytes
  /// Returns (size, error) tuple
  Future<DataSourceResult<int>> getDatabaseSize();
  
  /// Checks if model exists by ID
  /// Returns (exists, error) tuple
  Future<DataSourceResult<bool>> exists(String id);
  
  // ===== SYNC SUPPORT =====
  
  /// Gets models that need synchronization
  /// Returns (models, error) tuple
  Future<DataSourceResult<List<TModel>>> getPendingSync();
  
  /// Gets models modified after timestamp
  /// Returns (models, error) tuple
  Future<DataSourceResult<List<TModel>>> getModifiedAfter(DateTime timestamp);
  
  /// Gets models with specific sync status
  /// Returns (models, error) tuple
  Future<DataSourceResult<List<TModel>>> getBySyncStatus(String status);
  
  /// Marks models as synced
  /// Returns (success, error) tuple
  Future<DataSourceResult<bool>> markAsSynced(List<String> ids);
}

/// Base implementation with common functionality
abstract class BaseLocalDataSource<TModel> implements ILocalDataSource<TModel> {
  
  // Abstract methods for concrete implementations
  String getModelId(TModel model);
  String get tableName;
  Map<String, dynamic> toMap(TModel model);
  TModel fromMap(Map<String, dynamic> map);
  
  @override
  Future<DataSourceResult<TModel>> create(TModel model) async {
    try {
      await transaction(() async {
        final map = toMap(model);
        await insertMap(map);
      });
      return (model, null);
    } catch (e) {
      return (null, _handleError(e, 'create'));
    }
  }
  
  @override
  Future<DataSourceResult<TModel>> getById(String id) async {
    try {
      final map = await getMapById(id);
      if (map == null) {
        return (null, FailureCommons.dataNotFoundException());
      }
      final model = fromMap(map);
      return (model, null);
    } catch (e) {
      return (null, _handleError(e, 'getById'));
    }
  }
  
  @override
  Future<DataSourceResult<TModel>> update(TModel model) async {
    try {
      await transaction(() async {
        final map = toMap(model);
        final id = getModelId(model);
        await updateMap(id, map);
      });
      return (model, null);
    } catch (e) {
      return (null, _handleError(e, 'update'));
    }
  }
  
  @override
  Future<DataSourceResult<bool>> delete(String id) async {
    try {
      await transaction(() async {
        await deleteById(id);
      });
      return (true, null);
    } catch (e) {
      return (null, _handleError(e, 'delete'));
    }
  }
  
  @override
  Future<DataSourceResult<List<TModel>>> createBatch(List<TModel> models) async {
    try {
      await transaction(() async {
        for (final model in models) {
          final map = toMap(model);
          await insertMap(map);
        }
      });
      return (models, null);
    } catch (e) {
      return (null, _handleError(e, 'createBatch'));
    }
  }
  
  @override
  Future<DataSourceResult<PaginatedResult<TModel>>> getAll({
    Pagination? pagination,
    Map<String, dynamic>? filters,
    List<String>? sortBy,
  }) async {
    try {
      final maps = await getAllMaps(
        pagination: pagination,
        filters: filters,
        sortBy: sortBy,
      );
      
      final models = maps.map(fromMap).toList();
      final totalCount = await countMaps(filters: filters);
      
      final result = PaginatedResult<TModel>(
        items: models,
        pagination: pagination ?? Pagination.defaultPagination(),
        totalCount: totalCount,
      );
      
      return (result, null);
    } catch (e) {
      return (null, _handleError(e, 'getAll'));
    }
  }
  
  @override
  Future<DataSourceResult<PaginatedResult<TModel>>> search({
    required String query,
    Pagination? pagination,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final maps = await searchMaps(
        query: query,
        pagination: pagination,
        filters: filters,
      );
      
      final models = maps.map(fromMap).toList();
      final totalCount = await countSearchMaps(query: query, filters: filters);
      
      final result = PaginatedResult<TModel>(
        items: models,
        pagination: pagination ?? Pagination.defaultPagination(),
        totalCount: totalCount,
      );
      
      return (result, null);
    } catch (e) {
      return (null, _handleError(e, 'search'));
    }
  }
  
  @override
  Stream<TModel?> watchById(String id) {
    return watchMapById(id)
        .map((map) => map != null ? fromMap(map) : null);
  }
  
  @override
  Stream<List<TModel>> watchAll({
    Map<String, dynamic>? filters,
    List<String>? sortBy,
  }) {
    return watchAllMaps(filters: filters, sortBy: sortBy)
        .map((maps) => maps.map(fromMap).toList());
  }
  
  @override
  Future<DataSourceResult<bool>> clear() async {
    try {
      await clearTable();
      return (true, null);
    } catch (e) {
      return (null, _handleError(e, 'clear'));
    }
  }
  
  @override
  Future<DataSourceResult<bool>> exists(String id) async {
    try {
      final exists = await checkExists(id);
      return (exists, null);
    } catch (e) {
      return (null, _handleError(e, 'exists'));
    }
  }
  
  // Abstract methods for database-specific implementations
  Future<void> insertMap(Map<String, dynamic> map);
  Future<Map<String, dynamic>?> getMapById(String id);
  Future<void> updateMap(String id, Map<String, dynamic> map);
  Future<void> deleteById(String id);
  Future<List<Map<String, dynamic>>> getAllMaps({
    Pagination? pagination,
    Map<String, dynamic>? filters,
    List<String>? sortBy,
  });
  Future<List<Map<String, dynamic>>> searchMaps({
    required String query,
    Pagination? pagination,
    Map<String, dynamic>? filters,
  });
  Future<int> countMaps({Map<String, dynamic>? filters});
  Future<int> countSearchMaps({
    required String query,
    Map<String, dynamic>? filters,
  });
  Stream<Map<String, dynamic>?> watchMapById(String id);
  Stream<List<Map<String, dynamic>>> watchAllMaps({
    Map<String, dynamic>? filters,
    List<String>? sortBy,
  });
  Future<void> clearTable();
  Future<bool> checkExists(String id);
  
  // Helper method for error handling
  FailureCommons _handleError(dynamic error, String operation) {
    if (error is FailureCommons) return error;
    return FailureCommons.unexpected(error);
  }
  
  // Default implementations for optional methods
  @override
  Future<DataSourceResult<List<TModel>>> updateBatch(List<TModel> models) async {
    try {
      await transaction(() async {
        for (final model in models) {
          final map = toMap(model);
          final id = getModelId(model);
          await updateMap(id, map);
        }
      });
      return (models, null);
    } catch (e) {
      return (null, _handleError(e, 'updateBatch'));
    }
  }
  
  @override
  Future<DataSourceResult<bool>> deleteBatch(List<String> ids) async {
    try {
      await transaction(() async {
        for (final id in ids) {
          await deleteById(id);
        }
      });
      return (true, null);
    } catch (e) {
      return (null, _handleError(e, 'deleteBatch'));
    }
  }
  
  @override
  Future<DataSourceResult<List<TModel>>> getByIds(List<String> ids) async {
    try {
      final models = <TModel>[];
      for (final id in ids) {
        final map = await getMapById(id);
        if (map != null) {
          models.add(fromMap(map));
        }
      }
      return (models, null);
    } catch (e) {
      return (null, _handleError(e, 'getByIds'));
    }
  }
  
  @override
  Future<DataSourceResult<int>> count({Map<String, dynamic>? filters}) async {
    try {
      final count = await countMaps(filters: filters);
      return (count, null);
    } catch (e) {
      return (null, _handleError(e, 'count'));
    }
  }
  
  @override
  Stream<int> watchCount({Map<String, dynamic>? filters}) {
    return watchAllMaps(filters: filters).map((maps) => maps.length);
  }
  
  @override
  Future<DataSourceResult<T>> transaction<T>(Future<T> Function() operation) async {
    try {
      final result = await executeTransaction(operation);
      return (result, null);
    } catch (e) {
      return (null, _handleError(e, 'transaction'));
    }
  }
  
  @override
  Future<DataSourceResult<T>> readTransaction<T>(Future<T> Function() operation) async {
    try {
      final result = await executeReadTransaction(operation);
      return (result, null);
    } catch (e) {
      return (null, _handleError(e, 'readTransaction'));
    }
  }
  
  @override
  Future<DataSourceResult<bool>> vacuum() async {
    try {
      await performVacuum();
      return (true, null);
    } catch (e) {
      return (null, _handleError(e, 'vacuum'));
    }
  }
  
  @override
  Future<DataSourceResult<int>> getDatabaseSize() async {
    try {
      final size = await calculateDatabaseSize();
      return (size, null);
    } catch (e) {
      return (null, _handleError(e, 'getDatabaseSize'));
    }
  }
  
  @override
  Future<DataSourceResult<List<TModel>>> getPendingSync() async {
    try {
      final maps = await getAllMaps(
        filters: {'sync_status': 'pending'},
      );
      final models = maps.map(fromMap).toList();
      return (models, null);
    } catch (e) {
      return (null, _handleError(e, 'getPendingSync'));
    }
  }
  
  @override
  Future<DataSourceResult<List<TModel>>> getModifiedAfter(DateTime timestamp) async {
    try {
      final maps = await getAllMaps(
        filters: {'modified_after': timestamp.millisecondsSinceEpoch},
      );
      final models = maps.map(fromMap).toList();
      return (models, null);
    } catch (e) {
      return (null, _handleError(e, 'getModifiedAfter'));
    }
  }
  
  @override
  Future<DataSourceResult<List<TModel>>> getBySyncStatus(String status) async {
    try {
      final maps = await getAllMaps(
        filters: {'sync_status': status},
      );
      final models = maps.map(fromMap).toList();
      return (models, null);
    } catch (e) {
      return (null, _handleError(e, 'getBySyncStatus'));
    }
  }
  
  @override
  Future<DataSourceResult<bool>> markAsSynced(List<String> ids) async {
    try {
      await transaction(() async {
        for (final id in ids) {
          await updateMap(id, {
            'sync_status': 'synced',
            'synced_at': DateTime.now().millisecondsSinceEpoch,
          });
        }
      });
      return (true, null);
    } catch (e) {
      return (null, _handleError(e, 'markAsSynced'));
    }
  }
  
  // Abstract methods for transaction support
  Future<T> executeTransaction<T>(Future<T> Function() operation);
  Future<T> executeReadTransaction<T>(Future<T> Function() operation);
  Future<void> performVacuum();
  Future<int> calculateDatabaseSize();
}