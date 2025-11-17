import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_entity.dart';

/// Synchronization metadata for offline-first architecture
class SyncMetadata {
  final SyncState _state;
  final DateTime? _lastSyncAt;
  final DateTime? _lastSyncAttemptAt;
  final int _syncRetryCount;
  final String? _syncError;
  final bool _hasConflict;
  final Map<String, dynamic>? _conflictData;

  const SyncMetadata._({
    required SyncState state,
    DateTime? lastSyncAt,
    DateTime? lastSyncAttemptAt,
    required int syncRetryCount,
    String? syncError,
    required bool hasConflict,
    Map<String, dynamic>? conflictData,
  })  : _state = state,
        _lastSyncAt = lastSyncAt,
        _lastSyncAttemptAt = lastSyncAttemptAt,
        _syncRetryCount = syncRetryCount,
        _syncError = syncError,
        _hasConflict = hasConflict,
        _conflictData = conflictData;

  factory SyncMetadata.notSynced() => SyncMetadata._(
        state: SyncState.notSynced,
        syncRetryCount: 0,
        hasConflict: false,
      );

  factory SyncMetadata.synced() => SyncMetadata._(
        state: SyncState.synced,
        lastSyncAt: DateTime.now(),
        syncRetryCount: 0,
        hasConflict: false,
      );

  factory SyncMetadata.pending() => SyncMetadata._(
        state: SyncState.pending,
        syncRetryCount: 0,
        hasConflict: false,
      );
  factory SyncMetadata.markAsFailed({
    required String error,
    required int retryCount,
  }) =>
      SyncMetadata._(
        state: SyncState.failed,
        lastSyncAttemptAt: DateTime.now(),
        syncRetryCount: retryCount,
        syncError: error,
        hasConflict: false,
      );

  factory SyncMetadata.conflict({
    required Map<String, dynamic> conflictData,
  }) =>
      SyncMetadata._(
        state: SyncState.conflict,
        lastSyncAttemptAt: DateTime.now(),
        syncRetryCount: 0,
        hasConflict: true,
        conflictData: conflictData,
      );

  factory SyncMetadata.fromJson(Map<String, dynamic> json) {
    final syncState = SyncState.values.firstWhere(
      (e) => e.name == json['state'],
      orElse: () => SyncState.notSynced,
    );

    return SyncMetadata._(
      state: syncState,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'])
          : null,
      lastSyncAttemptAt: json['lastSyncAttemptAt'] != null
          ? DateTime.parse(json['lastSyncAttemptAt'])
          : null,
      syncRetryCount: json['syncRetryCount'] ?? 0,
      syncError: json['syncError'],
      hasConflict: json['hasConflict'] ?? false,
      conflictData: json['conflictData'] != null
          ? Map<String, dynamic>.from(json['conflictData'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state.name,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'lastSyncAttemptAt': lastSyncAttemptAt?.toIso8601String(),
      'syncRetryCount': syncRetryCount,
      'syncError': syncError,
      'hasConflict': hasConflict,
      'conflictData': conflictData,
    };
  }

  SyncState get state => _state;
  DateTime? get lastSyncAt => _lastSyncAt;
  DateTime? get lastSyncAttemptAt => _lastSyncAttemptAt;
  int get syncRetryCount => _syncRetryCount;
  String? get syncError => _syncError;
  bool get hasConflict => _hasConflict;
  Map<String, dynamic>? get conflictData => _conflictData;

  bool get needsSync =>
      _state == SyncState.notSynced || _state == SyncState.pending;
  bool get canRetrySync => _state == SyncState.failed && _syncRetryCount < 3;
  bool get isSynced => _state == SyncState.synced;
  bool get isNew => _state == SyncState.notSynced;

  Duration? get timeSinceLastSync =>
      _lastSyncAt != null ? DateTime.now().difference(_lastSyncAt) : null;

  @override
  String toString() =>
      'SyncMetadata.${_state.name}${_syncError != null ? '($_syncError)' : ''}';
}
