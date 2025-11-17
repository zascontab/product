// Native tuple patterns - no external dependencies
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_sync_meta_data.dart';

typedef ValidationResult = (bool isValid, List<String> errors);

/// Base entity interface that all entities must implement
/// Provides consistent patterns for:
/// - Unique identification (local/server IDs)
/// - Validation with clear error messages
/// - Cache key generation for performance
/// - Sync state tracking for offline-first architecture
abstract class IBaseEntity {
  /// Unique identifier for this entity
  EntityIdentifier get id;

  /// Entity metadata (timestamps, version, etc.)
  EntityMetadata get metadata;

  /// Current status of the entity
  EntityStatus get status;

  /// Synchronization metadata for offline support
  SyncMetadata get syncMeta;

  /// Validates the entity and returns detailed errors
  /// Returns (isValid, errors) tuple with specific validation failures
  ValidationResult validate();

  /// Generates cache key for this entity
  /// Used for efficient caching and retrieval
  String getCacheKey();

  /// Returns display name for this entity
  /// Used in UI components and error messages
  String getDisplayName();

  /// Checks if entity needs synchronization
  bool needsSync();

  /// Returns entity type for analytics and debugging
  String get entityType;
}

/// Universal entity identifier
/// Handles both local (offline) and server (online) IDs
class EntityIdentifier {
  final String? _localId;
  final String? _serverId;
  final String? _tempId;

  const EntityIdentifier._({
    String? localId,
    String? serverId,
    String? tempId,
  })  : _localId = localId,
        _serverId = serverId,
        _tempId = tempId;

  /// Creates identifier with local ID only (offline creation)
  factory EntityIdentifier.local(String localId) {
    if (localId.trim().isEmpty) {
      throw ArgumentError('Local ID cannot be empty');
    }
    return EntityIdentifier._(localId: localId);
  }

  factory EntityIdentifier.empty() =>
      EntityIdentifier._(localId: '', serverId: '', tempId: '');

  factory EntityIdentifier.fromJson(Map<String, dynamic> json) {
    return EntityIdentifier._(
      localId: json['localId'],
      serverId: json['serverId'],
      tempId: json['tempId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'serverId': serverId,
      'tempId': tempId,
    };
  }

  /// Creates identifier with server ID only (synced entity)
  factory EntityIdentifier.server(String serverId) {
    if (serverId.trim().isEmpty) {
      throw ArgumentError('Server ID cannot be empty');
    }
    return EntityIdentifier._(serverId: serverId);
  }

  /// Creates identifier with both local and server IDs (mapped entity)
  factory EntityIdentifier.mapped({
    required String localId,
    required String serverId,
  }) {
    if (localId.trim().isEmpty) {
      throw ArgumentError('Local ID cannot be empty');
    }
    if (serverId.trim().isEmpty) {
      throw ArgumentError('Server ID cannot be empty');
    }
    return EntityIdentifier._(localId: localId, serverId: serverId);
  }

  /// Creates temporary identifier for unsaved entities
  factory EntityIdentifier.temp(String tempId) {
    if (tempId.trim().isEmpty) {
      throw ArgumentError('Temp ID cannot be empty');
    }
    return EntityIdentifier._(tempId: tempId);
  }

  /// Creates identifier from unique key (auto-detects type)
  factory EntityIdentifier.fromKey(String key) {
    if (key.startsWith('temp_')) {
      return EntityIdentifier.temp(key);
    } else if (key.startsWith('local_')) {
      return EntityIdentifier.local(key);
    } else {
      return EntityIdentifier.server(key);
    }
  }

  bool get hasLocalId => _localId != null;
  bool get hasServerId => _serverId != null;
  bool get hasTempId => _tempId != null;
  bool get isMapped => hasLocalId && hasServerId;
  bool get isPersisted => hasLocalId || hasServerId;

  String? get localId => _localId;
  String? get serverId => _serverId;
  String? get tempId => _tempId;

  /// Returns the most appropriate ID for operations
  String get uniqueKey {
    if (_serverId != null) return _serverId;
    if (_localId != null) return _localId;
    if (_tempId != null) return _tempId;
    throw StateError('EntityIdentifier has no valid ID');
  }

  /// Returns display ID for UI
  String get displayId => uniqueKey;

  /// Creates new identifier with server ID added (after sync)
  EntityIdentifier withServerId(String serverId) {
    if (serverId.trim().isEmpty) {
      throw ArgumentError('Server ID cannot be empty');
    }
    return EntityIdentifier._(
      localId: _localId,
      serverId: serverId,
      tempId: _tempId,
    );
  }

  /// Creates new identifier with local ID added
  EntityIdentifier withLocalId(String localId) {
    if (localId.trim().isEmpty) {
      throw ArgumentError('Local ID cannot be empty');
    }
    return EntityIdentifier._(
      localId: localId,
      serverId: _serverId,
      tempId: _tempId,
    );
  }

  EntityIdentifier copyWith({
    String? localId,
    String? serverId,
    String? tempId,
  }) {
    return EntityIdentifier._(
      localId: localId ?? _localId,
      serverId: serverId ?? _serverId,
      tempId: tempId ?? _tempId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntityIdentifier &&
        other._localId == _localId &&
        other._serverId == _serverId &&
        other._tempId == _tempId;
  }

  @override
  int get hashCode => Object.hash(_localId, _serverId, _tempId);

  @override
  String toString() =>
      'EntityIdentifier(unique: $uniqueKey, local: $_localId, server: $_serverId, temp: $_tempId)';
}

/// Entity metadata for lifecycle tracking
class EntityMetadata {
  final DateTime _createdAt;
  final DateTime _modifiedAt;
  final int _version;
  final String? _createdBy;
  final String? _modifiedBy;

  const EntityMetadata._({
    required DateTime createdAt,
    required DateTime modifiedAt,
    required int version,
    String? createdBy,
    String? modifiedBy,
  })  : _createdAt = createdAt,
        _modifiedAt = modifiedAt,
        _version = version,
        _createdBy = createdBy,
        _modifiedBy = modifiedBy;

  /// Creates metadata for new entity
  factory EntityMetadata.create({
    String? createdBy,
  }) {
    final now = DateTime.now();
    return EntityMetadata._(
      createdAt: now,
      modifiedAt: now,
      version: 1,
      createdBy: createdBy,
      modifiedBy: createdBy,
    );
  }

  factory EntityMetadata.empty() => EntityMetadata(
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        version: 1,
        createdBy: '',
        modifiedBy: '',
      );

  factory EntityMetadata.fromJson(Map<String, dynamic> json) {
    return EntityMetadata(
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
      version: json['version'] ?? 1,
      createdBy: json['createdBy'],
      modifiedBy: json['modifiedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'version': version,
      'createdBy': createdBy,
      'modifiedBy': modifiedBy,
    };
  }

  /// Creates metadata from existing data
  factory EntityMetadata({
    required DateTime createdAt,
    required DateTime modifiedAt,
    required int version,
    String? createdBy,
    String? modifiedBy,
  }) {
    if (version < 1) {
      throw ArgumentError('Version must be >= 1');
    }
    if (modifiedAt.isBefore(createdAt)) {
      throw ArgumentError('Modified time cannot be before created time');
    }
    return EntityMetadata._(
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      version: version,
      createdBy: createdBy,
      modifiedBy: modifiedBy,
    );
  }

  DateTime get createdAt => _createdAt;
  DateTime get modifiedAt => _modifiedAt;
  int get version => _version;
  String? get createdBy => _createdBy;
  String? get modifiedBy => _modifiedBy;

  /// Age of entity in duration
  Duration get age => DateTime.now().difference(_createdAt);

  /// Time since last modification
  Duration get timeSinceModified => DateTime.now().difference(_modifiedAt);

  /// Check if entity is stale (not modified recently)
  bool isStale({Duration threshold = const Duration(hours: 24)}) {
    return timeSinceModified > threshold;
  }

  /// Creates updated metadata for modification
  EntityMetadata updated({
    String? modifiedBy,
  }) {
    return EntityMetadata._(
      createdAt: _createdAt,
      modifiedAt: DateTime.now(),
      version: _version + 1,
      createdBy: _createdBy,
      modifiedBy: modifiedBy ?? _modifiedBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntityMetadata &&
        other._createdAt == _createdAt &&
        other._modifiedAt == _modifiedAt &&
        other._version == _version &&
        other._createdBy == _createdBy &&
        other._modifiedBy == _modifiedBy;
  }

  @override
  int get hashCode =>
      Object.hash(_createdAt, _modifiedAt, _version, _createdBy, _modifiedBy);

  /// Creates a copy with updated fields
  EntityMetadata copyWith({
    DateTime? createdAt,
    DateTime? modifiedAt,
    int? version,
    String? createdBy,
    String? modifiedBy,
  }) {
    return EntityMetadata._(
      createdAt: createdAt ?? _createdAt,
      modifiedAt: modifiedAt ?? _modifiedAt,
      version: version ?? _version,
      createdBy: createdBy ?? _createdBy,
      modifiedBy: modifiedBy ?? _modifiedBy,
    );
  }

  @override
  String toString() =>
      'EntityMetadata(version: $_version, created: $_createdAt, modified: $_modifiedAt)';
}

/// Entity status management
class EntityStatus {
  final EntityStatusType _type;
  final String? _reason;
  final DateTime? _changedAt;

  const EntityStatus._({
    required EntityStatusType type,
    String? reason,
    DateTime? changedAt,
  })  : _type = type,
        _reason = reason,
        _changedAt = changedAt;

  factory EntityStatus.draft() => EntityStatus._(
        type: EntityStatusType.draft,
        changedAt: DateTime.now(),
      );

  factory EntityStatus.active() => EntityStatus._(
        type: EntityStatusType.active,
        changedAt: DateTime.now(),
      );

  factory EntityStatus.archived({String? reason}) => EntityStatus._(
        type: EntityStatusType.archived,
        reason: reason,
        changedAt: DateTime.now(),
      );

  factory EntityStatus.deleted({String? reason}) => EntityStatus._(
        type: EntityStatusType.deleted,
        reason: reason,
        changedAt: DateTime.now(),
      );

  factory EntityStatus.suspended({required String reason}) => EntityStatus._(
        type: EntityStatusType.suspended,
        reason: reason,
        changedAt: DateTime.now(),
      );

  factory EntityStatus.fromJson(Map<String, dynamic> json) {
    final statusType = EntityStatusType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => EntityStatusType.active,
    );

    return EntityStatus._(
      type: statusType,
      reason: json['reason'],
      changedAt:
          json['changedAt'] != null ? DateTime.parse(json['changedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'reason': reason,
      'changedAt': changedAt?.toIso8601String(),
    };
  }

  EntityStatusType get type => _type;
  String? get reason => _reason;
  DateTime? get changedAt => _changedAt;

  bool get isDraft => _type == EntityStatusType.draft;
  bool get isActive => _type == EntityStatusType.active;
  bool get isArchived => _type == EntityStatusType.archived;
  bool get isDeleted => _type == EntityStatusType.deleted;
  bool get isSuspended => _type == EntityStatusType.suspended;
  bool get isVisible => isActive || isDraft;
  bool get canEdit => isActive || isDraft;

  @override
  String toString() =>
      'EntityStatus.${_type.name}${_reason != null ? '($_reason)' : ''}';
}

enum EntityStatusType { draft, active, archived, deleted, suspended }

enum SyncState { notSynced, pending, synced, failed, conflict }
