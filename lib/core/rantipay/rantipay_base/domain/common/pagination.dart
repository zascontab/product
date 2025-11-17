/// Pagination configuration for query operations
class Pagination {
  final int _page;
  final int _pageSize;
  final int? _offset;

  const Pagination._({
    required int page,
    required int pageSize,
    int? offset,
  })  : _page = page,
        _pageSize = pageSize,
        _offset = offset;

  /// Creates pagination with page and page size
  factory Pagination({
    required int page,
    required int pageSize,
  }) {
    if (page < 1) {
      throw ArgumentError('Page must be >= 1, got: $page');
    }
    if (pageSize < 1) {
      throw ArgumentError('Page size must be >= 1, got: $pageSize');
    }
    if (pageSize > 1000) {
      throw ArgumentError('Page size too large (max 1000), got: $pageSize');
    }

    return Pagination._(
      page: page,
      pageSize: pageSize,
      offset: (page - 1) * pageSize,
    );
  }

  /// Creates pagination with offset and limit
  factory Pagination.offset({
    required int offset,
    required int limit,
  }) {
    if (offset < 0) {
      throw ArgumentError('Offset must be >= 0, got: $offset');
    }
    if (limit < 1) {
      throw ArgumentError('Limit must be >= 1, got: $limit');
    }
    if (limit > 1000) {
      throw ArgumentError('Limit too large (max 1000), got: $limit');
    }

    final page = (offset ~/ limit) + 1;
    return Pagination._(
      page: page,
      pageSize: limit,
      offset: offset,
    );
  }

  /// Creates default pagination (page 1, 20 items)
  factory Pagination.defaultPagination() => Pagination(page: 1, pageSize: 20);

  /// Creates pagination for first page
  factory Pagination.firstPage({int pageSize = 20}) =>
      Pagination(page: 1, pageSize: pageSize);

  int get page => _page;
  int get pageSize => _pageSize;
  int get offset => _offset ?? ((_page - 1) * _pageSize);
  int get limit => _pageSize;

  bool get isFirstPage => _page == 1;

  /// Creates pagination for next page
  Pagination nextPage() => Pagination(page: _page + 1, pageSize: _pageSize);

  /// Creates pagination for previous page
  Pagination previousPage() {
    if (_page <= 1) {
      throw StateError('Cannot go to previous page from first page');
    }
    return Pagination(page: _page - 1, pageSize: _pageSize);
  }

  /// Creates pagination for specific page
  Pagination toPage(int page) => Pagination(page: page, pageSize: _pageSize);

  /// Creates pagination with different page size
  Pagination withPageSize(int pageSize) =>
      Pagination(page: 1, pageSize: pageSize);

  Pagination toJson() => Pagination(page: _page, pageSize: _pageSize);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pagination &&
        other._page == _page &&
        other._pageSize == _pageSize;
  }

  @override
  int get hashCode => Object.hash(_page, _pageSize);

  @override
  String toString() =>
      'Pagination(page: $_page, pageSize: $_pageSize, offset: $offset)';
}

/// Result container for paginated queries
class PaginatedResult<T> {
  final List<T> _items;
  final Pagination _pagination;
  final int _totalCount;
  final bool _hasNextPage;
  final bool _hasPreviousPage;
  final DateTime _fetchedAt;

  const PaginatedResult._({
    required List<T> items,
    required Pagination pagination,
    required int totalCount,
    required bool hasNextPage,
    required bool hasPreviousPage,
    required DateTime fetchedAt,
  })  : _items = items,
        _pagination = pagination,
        _totalCount = totalCount,
        _hasNextPage = hasNextPage,
        _hasPreviousPage = hasPreviousPage,
        _fetchedAt = fetchedAt;

  /// Creates paginated result
  factory PaginatedResult({
    required List<T> items,
    required Pagination pagination,
    required int totalCount,
  }) {
    ArgumentError.checkNotNull(items, 'items');
    ArgumentError.checkNotNull(pagination, 'pagination');

    if (totalCount < 0) {
      throw ArgumentError('Total count must be >= 0, got: $totalCount');
    }

    final totalPages =
        totalCount > 0 ? ((totalCount - 1) ~/ pagination.pageSize) + 1 : 0;
    final hasNextPage = pagination.page < totalPages;
    final hasPreviousPage = pagination.page > 1;

    return PaginatedResult._(
      items: List.unmodifiable(items),
      pagination: pagination,
      totalCount: totalCount,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
      fetchedAt: DateTime.now(),
    );
  }

  /// Creates empty result
  factory PaginatedResult.empty({
    Pagination? pagination,
  }) =>
      PaginatedResult(
        items: <T>[],
        pagination: pagination ?? Pagination.defaultPagination(),
        totalCount: 0,
      );

  List<T> get items => _items;
  Pagination get pagination => _pagination;
  int get totalCount => _totalCount;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;
  DateTime get fetchedAt => _fetchedAt;

  int get currentPage => _pagination.page;
  int get pageSize => _pagination.pageSize;
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  /// Total number of pages
  int get totalPages =>
      _totalCount > 0 ? ((_totalCount - 1) ~/ pageSize) + 1 : 0;

  /// Current page items range (e.g., "1-20 of 100")
  String get itemsRange {
    if (isEmpty) return '0 of $_totalCount';

    final start = _pagination.offset + 1;
    final end = _pagination.offset + itemCount;
    return '$start-$end of $_totalCount';
  }

  /// Age of this result
  Duration get age => DateTime.now().difference(_fetchedAt);

  /// Check if result is stale
  bool isStale({Duration threshold = const Duration(minutes: 5)}) {
    return age > threshold;
  }

  /// Creates new result with additional items (for infinite scroll)
  PaginatedResult<T> copyWith({
    List<T>? items,
    Pagination? pagination,
    int? totalCount,
  }) {
    return PaginatedResult(
      items: items ?? _items,
      pagination: pagination ?? _pagination,
      totalCount: totalCount ?? _totalCount,
    );
  }

  /// Merges with another result (for combining pages)
  PaginatedResult<T> mergeWith(PaginatedResult<T> other) {
    final allItems = [..._items, ...other._items];
    final newPagination = other._pagination;

    return PaginatedResult(
      items: allItems,
      pagination: newPagination,
      totalCount: other._totalCount,
    );
  }

  /// Maps items to different type
  PaginatedResult<R> map<R>(R Function(T) mapper) {
    return PaginatedResult<R>(
      items: _items.map(mapper).toList(),
      pagination: _pagination,
      totalCount: _totalCount,
    );
  }

  /// Filters items
  PaginatedResult<T> where(bool Function(T) predicate) {
    final filteredItems = _items.where(predicate).toList();
    return PaginatedResult<T>(
      items: filteredItems,
      pagination: _pagination,
      totalCount: filteredItems.length,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginatedResult<T> &&
        _listEquals(other._items, _items) &&
        other._pagination == _pagination &&
        other._totalCount == _totalCount;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(_items),
        _pagination,
        _totalCount,
      );

  @override
  String toString() =>
      'PaginatedResult<$T>(items: $itemCount, page: $currentPage, total: $_totalCount)';
}

/// Query options for filtering and sorting
class QueryOptions {
  final Map<String, dynamic>? _filters;
  final List<SortOption>? _sortBy;
  final List<String>? _includeFields;
  final List<String>? _excludeFields;
  final bool _includeDeleted;
  final bool _includeArchived;

  const QueryOptions._({
    Map<String, dynamic>? filters,
    List<SortOption>? sortBy,
    List<String>? includeFields,
    List<String>? excludeFields,
    required bool includeDeleted,
    required bool includeArchived,
  })  : _filters = filters,
        _sortBy = sortBy,
        _includeFields = includeFields,
        _excludeFields = excludeFields,
        _includeDeleted = includeDeleted,
        _includeArchived = includeArchived;

  factory QueryOptions({
    Map<String, dynamic>? filters,
    List<SortOption>? sortBy,
    List<String>? includeFields,
    List<String>? excludeFields,
    bool includeDeleted = false,
    bool includeArchived = false,
  }) {
    // Validate filters
    if (filters != null) {
      for (final entry in filters.entries) {
        if (entry.key.trim().isEmpty) {
          throw ArgumentError('Filter key cannot be empty');
        }
      }
    }

    // Validate field lists
    if (includeFields != null) {
      for (final field in includeFields) {
        if (field.trim().isEmpty) {
          throw ArgumentError('Include field cannot be empty');
        }
      }
    }

    if (excludeFields != null) {
      for (final field in excludeFields) {
        if (field.trim().isEmpty) {
          throw ArgumentError('Exclude field cannot be empty');
        }
      }
    }

    return QueryOptions._(
      filters: filters != null ? Map.unmodifiable(filters) : null,
      sortBy: sortBy != null ? List.unmodifiable(sortBy) : null,
      includeFields:
          includeFields != null ? List.unmodifiable(includeFields) : null,
      excludeFields:
          excludeFields != null ? List.unmodifiable(excludeFields) : null,
      includeDeleted: includeDeleted,
      includeArchived: includeArchived,
    );
  }

  /// Creates options with only active entities
  factory QueryOptions.activeOnly() => QueryOptions(
        includeDeleted: false,
        includeArchived: false,
      );

  /// Creates options including archived entities
  factory QueryOptions.withArchived() => QueryOptions(
        includeDeleted: false,
        includeArchived: true,
      );

  /// Creates options including all entities
  factory QueryOptions.includeAll() => QueryOptions(
        includeDeleted: true,
        includeArchived: true,
      );

  Map<String, dynamic>? get filters => _filters;
  List<SortOption>? get sortBy => _sortBy;
  List<String>? get includeFields => _includeFields;
  List<String>? get excludeFields => _excludeFields;
  bool get includeDeleted => _includeDeleted;
  bool get includeArchived => _includeArchived;

  bool get hasFilters => _filters != null && _filters.isNotEmpty;
  bool get hasSorting => _sortBy != null && _sortBy.isNotEmpty;
  bool get hasFieldSelection =>
      _includeFields != null || _excludeFields != null;

  /// Creates new options with additional filter
  QueryOptions withFilter(String key, dynamic value) {
    final newFilters = Map<String, dynamic>.from(_filters ?? {});
    newFilters[key] = value;

    return QueryOptions(
      filters: newFilters,
      sortBy: _sortBy?.toList(),
      includeFields: _includeFields?.toList(),
      excludeFields: _excludeFields?.toList(),
      includeDeleted: _includeDeleted,
      includeArchived: _includeArchived,
    );
  }

  /// Creates new options with additional sort
  QueryOptions withSort(SortOption sort) {
    final newSorts = List<SortOption>.from(_sortBy ?? []);
    newSorts.add(sort);

    return QueryOptions(
      filters: _filters != null ? Map.from(_filters) : null,
      sortBy: newSorts,
      includeFields: _includeFields?.toList(),
      excludeFields: _excludeFields?.toList(),
      includeDeleted: _includeDeleted,
      includeArchived: _includeArchived,
    );
  }

  @override
  String toString() =>
      'QueryOptions(filters: ${_filters?.length ?? 0}, sorts: ${_sortBy?.length ?? 0})';
}

/// Sort option for query results
class SortOption {
  final String _field;
  final SortDirection _direction;

  const SortOption._({
    required String field,
    required SortDirection direction,
  })  : _field = field,
        _direction = direction;

  factory SortOption({
    required String field,
    SortDirection direction = SortDirection.ascending,
  }) {
    if (field.trim().isEmpty) {
      throw ArgumentError('Sort field cannot be empty');
    }
    return SortOption._(field: field, direction: direction);
  }

  factory SortOption.ascending(String field) =>
      SortOption(field: field, direction: SortDirection.ascending);
  factory SortOption.descending(String field) =>
      SortOption(field: field, direction: SortDirection.descending);

  String get field => _field;
  SortDirection get direction => _direction;

  bool get isAscending => _direction == SortDirection.ascending;
  bool get isDescending => _direction == SortDirection.descending;

  /// Creates sort option with opposite direction
  SortOption reversed() =>
      SortOption(field: _field, direction: _direction.opposite);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SortOption &&
        other._field == _field &&
        other._direction == _direction;
  }

  @override
  int get hashCode => Object.hash(_field, _direction);

  @override
  String toString() => 'SortOption($_field ${_direction.name})';
}

enum SortDirection {
  ascending,
  descending;

  SortDirection get opposite => this == ascending ? descending : ascending;
}

// Helper function for list equality
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;

  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
