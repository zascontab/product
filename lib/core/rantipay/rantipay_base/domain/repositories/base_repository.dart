
import 'package:rantipay_app/core/errors/failure_commons.dart';

import '../entities/base_entity.dart';
import '../common/pagination.dart';

// Native tuple patterns - no external dependencies
/// Result type for repository operations using native Dart tuples
typedef RepositoryResult<T> = (T? data, FailureCommons? error);

/// Base repository interface that all repositories must implement
/// Provides consistent CRUD operations with:
/// - Offline-first architecture
/// - Automatic synchronization
/// - Conflict resolution
/// - Performance optimization
/// - Error handling with native tuples
abstract class IBaseRepository<TEntity extends IBaseEntity> {
  // ===== QUERY OPERATIONS =====

  /// Gets paginated list of entities
  /// Returns (result, error) tuple using native Dart patterns
  Future<RepositoryResult<PaginatedResult<TEntity>>> getEntities({
    Pagination? pagination,
    Map<String, dynamic>? filters,
    List<String>? sortBy,
    bool forceRefresh = false,
  });

  /// Gets single entity by ID
  /// Returns (entity, error) tuple using native Dart patterns
  Future<RepositoryResult<TEntity>> getEntityById(String id);

  /// Gets multiple entities by IDs
  /// Returns (entities, error) tuple using native Dart patterns
  Future<RepositoryResult<List<TEntity>>> getEntitiesByIds(List<String> ids);

  /// Searches entities with text query
  /// Returns (result, error) tuple using native Dart patterns
  Future<RepositoryResult<PaginatedResult<TEntity>>> searchEntities({
    required String query,
    Map<String, dynamic>? filters,
    Pagination? pagination,
  });

  /// Gets count of entities matching filters
  /// Returns (count, error) tuple using native Dart patterns
  Future<RepositoryResult<int>> getEntitiesCount({
    Map<String, dynamic>? filters,
  });

  // ===== MUTATION OPERATIONS =====

  /// Creates new entity
  /// Returns (entity, error) tuple using native Dart patterns
  Future<RepositoryResult<TEntity>> createEntity(TEntity entity);

  /// Updates existing entity
  /// Returns (entity, error) tuple using native Dart patterns
  Future<RepositoryResult<TEntity>> updateEntity(TEntity entity);

  /// Deletes entity by ID
  /// Returns (success, error) tuple using native Dart patterns
  Future<RepositoryResult<bool>> deleteEntity(String id);

  /// Batch operations for multiple entities
  /// Returns (results, error) tuple using native Dart patterns
  Future<RepositoryResult<BatchResult<TEntity>>> batchOperations(
    List<BatchOperation<TEntity>> operations,
  );

  // ===== SYNCHRONIZATION =====

  /// Syncs all pending entities with remote
  /// Returns (summary, error) tuple using native Dart patterns
  Future<RepositoryResult<SyncSummary>> syncAllEntities();

  /// Syncs specific entity with remote
  /// Returns (entity, error) tuple using native Dart patterns
  Future<RepositoryResult<TEntity>> syncEntity(String id);

  /// Gets entities pending synchronization
  /// Returns (entities, error) tuple using native Dart patterns
  Future<RepositoryResult<List<TEntity>>> getPendingSyncEntities();

  /// Resolves sync conflict for entity
  /// Returns (entity, error) tuple using native Dart patterns
  Future<RepositoryResult<TEntity>> resolveConflict({
    required String entityId,
    required ConflictResolution resolution,
    TEntity? resolvedEntity,
  });

  // ===== REAL-TIME OPERATIONS =====

  /// Stream of entity changes
  Stream<List<TEntity>> watchEntities({
    Map<String, dynamic>? filters,
  });

  /// Stream of specific entity changes
  Stream<TEntity?> watchEntity(String id);

  /// Stream of sync status changes
  Stream<SyncStatus> watchSyncStatus();

  // ===== CACHE MANAGEMENT =====

  /// Clears local cache
  /// Returns (success, error) tuple using native Dart patterns
  Future<RepositoryResult<bool>> clearCache();

  /// Gets cache statistics
  /// Returns (stats, error) tuple using native Dart patterns
  Future<RepositoryResult<CacheStats>> getCacheStats();

  /// Preloads entities into cache
  /// Returns (success, error) tuple using native Dart patterns
  Future<RepositoryResult<bool>> preloadEntities({
    Map<String, dynamic>? filters,
    int? limit,
  });

  // ===== TRANSACTION SUPPORT =====

  /// Executes operations in transaction
  /// Returns (result, error) tuple using native Dart patterns
  Future<RepositoryResult<T>> transaction<T>(
    Future<T> Function() operation,
  );

  // ===== HEALTH & DIAGNOSTICS =====

  /// Checks repository health
  /// Returns (status, error) tuple using native Dart patterns
  Future<RepositoryResult<HealthStatus>> checkHealth();

  /// Gets repository metrics
  /// Returns (metrics, error) tuple using native Dart patterns
  Future<RepositoryResult<RepositoryMetrics>> getMetrics();
}

/// Batch operation for multiple entities
class BatchOperation<TEntity extends IBaseEntity> {
  final BatchOperationType type;
  final TEntity? entity;
  final String? entityId;

  const BatchOperation._({
    required this.type,
    this.entity,
    this.entityId,
  });

  factory BatchOperation.create(TEntity entity) {
    ArgumentError.checkNotNull(entity, 'entity');
    return BatchOperation._(type: BatchOperationType.create, entity: entity);
  }

  factory BatchOperation.update(TEntity entity) {
    ArgumentError.checkNotNull(entity, 'entity');
    return BatchOperation._(type: BatchOperationType.update, entity: entity);
  }

  factory BatchOperation.delete(String entityId) {
    ArgumentError.checkNotNull(entityId, 'entityId');
    if (entityId.trim().isEmpty) {
      throw ArgumentError('entityId cannot be empty');
    }
    return BatchOperation._(
        type: BatchOperationType.delete, entityId: entityId);
  }

  @override
  String toString() => 'BatchOperation.${type.name}';
}

enum BatchOperationType { create, update, delete }

/// Result of batch operations
class BatchResult<TEntity extends IBaseEntity> {
  final List<TEntity> succeeded;
  final List<BatchFailure<TEntity>> failed;
  final Duration processingTime;

  const BatchResult({
    required this.succeeded,
    required this.failed,
    required this.processingTime,
  });

  int get successCount => succeeded.length;
  int get failureCount => failed.length;
  int get totalCount => successCount + failureCount;
  bool get hasFailures => failed.isNotEmpty;
  double get successRate => totalCount > 0 ? successCount / totalCount : 0.0;

  @override
  String toString() =>
      'BatchResult(succeeded: $successCount, failed: $failureCount)';
}

/// Batch operation failure
class BatchFailure<TEntity extends IBaseEntity> {
  final BatchOperation<TEntity> operation;
  final FailureCommons failure;

  const BatchFailure({
    required this.operation,
    required this.failure,
  });

  @override
  String toString() =>
      'BatchFailure(${operation.type.name}: ${failure.toString()})';
}

/// Sync summary for tracking synchronization progress
class SyncSummary {
  final int entitiesCreated;
  final int entitiesUpdated;
  final int entitiesDeleted;
  final int conflictsResolved;
  final int errorsEncountered;
  final DateTime syncStartedAt;
  final DateTime syncCompletedAt;
  final Duration syncDuration;
  final List<String> failedEntityIds;

  const SyncSummary({
    required this.entitiesCreated,
    required this.entitiesUpdated,
    required this.entitiesDeleted,
    required this.conflictsResolved,
    required this.errorsEncountered,
    required this.syncStartedAt,
    required this.syncCompletedAt,
    required this.syncDuration,
    required this.failedEntityIds,
  });

  int get totalEntitiesProcessed =>
      entitiesCreated + entitiesUpdated + entitiesDeleted;
  bool get hasErrors => errorsEncountered > 0;
  bool get hasConflicts => conflictsResolved > 0;
  bool get isSuccessful => errorsEncountered == 0;

  @override
  String toString() =>
      'SyncSummary(created: $entitiesCreated, updated: $entitiesUpdated, deleted: $entitiesDeleted)';
}

/// Conflict resolution strategy
enum ConflictResolution {
  useLocal, // Keep local version
  useRemote, // Use remote version
  merge, // Merge both versions
  manual, // Manual resolution required
}

/// Sync status information
class SyncStatus {
  final bool isSyncing;
  final int pendingCount;
  final int conflictCount;
  final DateTime? lastSyncAt;
  final String? currentOperation;
  final double? progress;

  const SyncStatus({
    required this.isSyncing,
    required this.pendingCount,
    required this.conflictCount,
    this.lastSyncAt,
    this.currentOperation,
    this.progress,
  });

  bool get hasPendingSync => pendingCount > 0;
  bool get hasConflicts => conflictCount > 0;
  bool get needsAttention => hasConflicts;

  @override
  String toString() =>
      'SyncStatus(syncing: $isSyncing, pending: $pendingCount, conflicts: $conflictCount)';
}

/// Cache statistics for performance monitoring
class CacheStats {
  final int totalEntries;
  final int hitCount;
  final int missCount;
  final double hitRatio;
  final int memoryUsageBytes;
  final DateTime lastCleanupAt;

  const CacheStats({
    required this.totalEntries,
    required this.hitCount,
    required this.missCount,
    required this.hitRatio,
    required this.memoryUsageBytes,
    required this.lastCleanupAt,
  });

  int get totalRequests => hitCount + missCount;
  double get memoryUsageMB => memoryUsageBytes / (1024 * 1024);

  @override
  String toString() =>
      'CacheStats(entries: $totalEntries, hit ratio: ${(hitRatio * 100).toStringAsFixed(1)}%)';
}

/// Repository health status
class HealthStatus {
  final bool isHealthy;
  final List<String> issues;
  final Map<String, dynamic> metrics;
  final DateTime checkedAt;

  const HealthStatus({
    required this.isHealthy,
    required this.issues,
    required this.metrics,
    required this.checkedAt,
  });

  bool get hasIssues => issues.isNotEmpty;
  int get issueCount => issues.length;

  @override
  String toString() => 'HealthStatus(healthy: $isHealthy, issues: $issueCount)';
}

/// Repository performance metrics
class RepositoryMetrics {
  final Map<String, int> operationCounts;
  final Map<String, double> averageResponseTimes;
  final Map<String, int> errorCounts;
  final DateTime collectionStartedAt;
  final DateTime lastUpdatedAt;

  const RepositoryMetrics({
    required this.operationCounts,
    required this.averageResponseTimes,
    required this.errorCounts,
    required this.collectionStartedAt,
    required this.lastUpdatedAt,
  });

  Duration get collectionDuration =>
      lastUpdatedAt.difference(collectionStartedAt);
  int get totalOperations =>
      operationCounts.values.fold(0, (sum, count) => sum + count);
  int get totalErrors =>
      errorCounts.values.fold(0, (sum, count) => sum + count);
  double get errorRate =>
      totalOperations > 0 ? totalErrors / totalOperations : 0.0;

  @override
  String toString() =>
      'RepositoryMetrics(operations: $totalOperations, errors: $totalErrors, error rate: ${(errorRate * 100).toStringAsFixed(2)}%)';
}
