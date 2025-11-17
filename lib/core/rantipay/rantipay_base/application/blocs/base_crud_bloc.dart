import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/errors/failure_commons.dart';
import 'package:rantipay_app/core/errors/global_error_handler.dart';

import '../../domain/entities/base_entity.dart';
import '../../domain/repositories/base_repository.dart';
import '../../domain/common/pagination.dart';
import '../services/connectivity_service.dart';
import '../services/search_service.dart';

// Native tuple patterns - no external dependencies
/// Result type for repository operations using native Dart tuples
typedef EventValidationResult = (bool isValid, List<String> errors);

/// Universal base BLoC with manual implementation (NO FREEZED)
/// Eliminates 800+ lines of duplicate code with complete control
///
/// Benefits of manual implementation:
/// - ✅ Complete null safety validation
/// - ✅ Clear error messages and debugging
/// - ✅ Explicit state transitions
/// - ✅ Custom validation logic
/// - ✅ Performance optimization
/// - ✅ No Freezed dependencies
///
/// Performance targets:
/// - State transitions: <50ms
/// - Search responses: <200ms
/// - Memory footprint: <5MB per bloc
/// - 99.9% reliability
abstract class BaseCrudBloc<TEntity extends IBaseEntity>
    extends Bloc<BaseCrudEvent, BaseCrudState<TEntity>> {
  final IBaseRepository<TEntity> _repository;
  final IConnectivityService _connectivityService;
  final ISearchService<TEntity> _searchService;
  final GlobalErrorHandler _errorHandler;

  // Subscriptions for cleanup
  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<List<TEntity>>? _entitiesSubscription;
  Timer? _searchDebounceTimer;

  // Configuration
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
  static const int defaultPageSize = 20;

  BaseCrudBloc({
    required IBaseRepository<TEntity> repository,
    required IConnectivityService connectivityService,
    required ISearchService<TEntity> searchService,
    required GlobalErrorHandler errorHandler,
  })  : _repository = repository,
        _connectivityService = connectivityService,
        _searchService = searchService,
        _errorHandler = errorHandler,
        super(BaseCrudState<TEntity>.initial()) {
    _initializeEventHandlers();
    _initializeConnectivityListener();
    // ✅ LAZY WATCHER: Don't start watcher until filters are applied
    // _initializeEntitiesWatcher();
  }

  void _initializeEventHandlers() {
    print('🟢 BASE_CRUD_BLOC: Initializing event handlers for type $TEntity');
    
    // Connection events
    on<ConnectionChangedEvent>(_onConnectionChanged);

    // CRUD events
    on<LoadEntitiesEvent>(_onLoadEntities);
    on<LoadEntityByIdEvent>(_onLoadEntityById);
    on<RefreshEntitiesEvent>(_onRefreshEntities);
    on<LoadMoreEntitiesEvent>(_onLoadMoreEntities);
    on<CreateEntityEvent<TEntity>>(_onCreateEntity);
    on<UpdateEntityEvent<TEntity>>(_onUpdateEntity);
    on<DeleteEntityEvent>(_onDeleteEntity);
    
    print('🟢 BASE_CRUD_BLOC: UpdateEntityEvent handler registered for type $TEntity');

    // Search events
    on<SearchEntitiesEvent>(_onSearchEntities);
    on<ClearSearchEvent>(_onClearSearch);

    // Sync events
    on<SyncEntitiesEvent>(_onSyncEntities);

    // Selection events
    on<SelectEntityEvent<TEntity>>(_onSelectEntity);
    on<ClearSelectionEvent>(_onClearSelection);

    // Filter events
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<ClearFiltersEvent>(_onClearFilters);

    // Real-time events
    on<EntitiesUpdatedEvent<TEntity>>(_onEntitiesUpdated);
  }

  void _initializeConnectivityListener() {
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) => add(ConnectionChangedEvent(isConnected: isConnected)),
    );
  }

  void _initializeEntitiesWatcher() {
    _entitiesSubscription = _repository.watchEntities().listen(
      (entities) {
        if (!isClosed) {
          add(EntitiesUpdatedEvent<TEntity>(entities: entities));
        }
      },
    );
  }

  /// ✅ LAZY WATCHER: Only start watcher after filters are applied
  void _ensureWatcherActive() {
    if (_entitiesSubscription == null) {
      print('🔄 LAZY WATCHER: Starting entities watcher with filters applied');
      _initializeEntitiesWatcher();
    } else {
      print('🔄 LAZY WATCHER: Watcher already active, skipping');
    }
  }

  // ===== EVENT HANDLERS =====

  Future<void> _onConnectionChanged(
    ConnectionChangedEvent event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    final (isValid, errors) = event.validate();
    if (!isValid) return;

    emit(state.copyWith(
      connectionState: event.isConnected
          ? ConnectionState.connected()
          : ConnectionState.disconnected(),
    ));

    if (event.isConnected && state.hasPendingSync && !isClosed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isClosed) {
          add(const SyncEntitiesEvent());
        }
      });
    }
  }

  Future<void> _onLoadEntities(
    LoadEntitiesEvent event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    print('🔍 LOAD ENTITIES: Called with filters: ${event.filters}');
    print('🔍 LOAD ENTITIES: Current filter state: ${state.filterState.activeFilters}');

    // ✅ FIX: Allow loading without filters - repository will handle null filters correctly
    final effectiveFilters = event.filters ?? state.filterState.activeFilters;
    if (effectiveFilters.isEmpty) {
      print('ℹ️ LOAD ENTITIES: No filters provided, loading all entities from repository');
    } else {
      print('✅ LOAD ENTITIES: Using filters: $effectiveFilters');
    }
    
    final (isValid, errors) = event.validate();
    if (!isValid) {
      emit(state.copyWith(
        errorState:
            ErrorState.validation('Invalid parameters: ${errors.join(', ')}'),
      ));
      return;
    }

    if (state.dataState.isLoading) return;

    emit(state.copyWith(
      dataState: DataState<List<TEntity>>.loading(),
      clearErrorState: true,
    ));

    try {
      final (paginatedResult, failure) = await _repository.getEntities(
        pagination: Pagination(
          page: 1,
          pageSize: event.pageSize ?? defaultPageSize,
        ),
        filters: effectiveFilters,
        sortBy: event.sortBy,
        forceRefresh: event.forceRefresh,
      );

      if (failure != null) {
        emit(state.copyWith(
          dataState: DataState<List<TEntity>>.error(failure),
          errorState: ErrorState.fromFailure(failure),
        ));
      } else if (paginatedResult != null) {
        emit(state.copyWith(
          dataState: DataState<List<TEntity>>.success(paginatedResult.items),
          paginationState: PaginationState.fromResult(paginatedResult),
          lastLoadTime: DateTime.now(),
          clearErrorState: true,
        ));
      }
    } catch (e, stackTrace) {
      final failure = _errorHandler.getException(e, stackTrace);
      emit(state.copyWith(
        dataState: DataState<List<TEntity>>.error(failure),
        errorState: ErrorState.fromFailure(failure),
      ));
    }
  }

  Future<void> _onLoadEntityById(
    LoadEntityByIdEvent event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    final (isValid, errors) = event.validate();
    if (!isValid) {
      emit(state.copyWith(
        errorState:
            ErrorState.validation('Invalid entity ID: ${errors.join(', ')}'),
      ));
      return;
    }

    // ✅ CRITICAL FIX: NO cambiar dataState (lista completa) cuando cargas una entidad individual
    // Limpiar selectedEntity para indicar que se está cargando, pero NO tocar dataState
    // Esto previene que se pierda la lista cuando navegas a detalle
    emit(state.copyWith(
      selectedEntity: null,
      selectionState: SelectionState.idle(),
      clearErrorState: true,
    ));

    try {
      final (entity, failure) = await _repository.getEntityById(event.entityId);

      // ✅ ROBUST: Small delay prevents scroll animation conflicts
      // This debounces rapid loading → loaded transitions to give animations time to complete
      await Future.delayed(const Duration(milliseconds: 150));

      if (failure != null) {
        // ❌ ERROR al cargar entidad individual: NO afectar dataState (lista completa)
        emit(state.copyWith(
          selectedEntity: null,
          selectionState: SelectionState.idle(),
          errorState: ErrorState.fromFailure(failure),
        ));
      } else if (entity != null) {
        // ✅ Entidad cargada: actualizar selectedEntity Y selectionState
        emit(state.copyWith(
          selectedEntity: entity,
          selectionState: SelectionState.selected(entity),
          clearErrorState: true,
        ));
      } else {
        emit(state.copyWith(
          selectedEntity: null,
          selectionState: SelectionState.idle(),
          errorState: ErrorState.validation('Entity not found'),
        ));
      }
    } catch (e, stackTrace) {
      final failure = _errorHandler.getException(e, stackTrace);
      // ❌ ERROR: NO afectar dataState (lista completa)
      emit(state.copyWith(
        selectedEntity: null,
        selectionState: SelectionState.idle(),
        errorState: ErrorState.fromFailure(failure),
      ));
    }
  }

  Future<void> _onRefreshEntities(
    RefreshEntitiesEvent event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    emit(state.copyWith(
      refreshState: RefreshState.refreshing(),
    ));

    try {
      final (paginatedResult, failure) = await _repository.getEntities(
        pagination: Pagination(
          page: 1,
          pageSize: state.paginationState.pageSize,
        ),
        filters: state.filterState.activeFilters,
        forceRefresh: true,
      );

      if (failure != null) {
        emit(state.copyWith(
          refreshState: RefreshState.error(failure),
          errorState: ErrorState.fromFailure(failure),
        ));
      } else if (paginatedResult != null) {
        emit(state.copyWith(
          dataState: DataState<List<TEntity>>.success(paginatedResult.items),
          paginationState: PaginationState.fromResult(paginatedResult),
          refreshState: RefreshState.idle(),
          lastLoadTime: DateTime.now(),
          clearErrorState: true,
        ));
      }
    } catch (e, stackTrace) {
      final failure = _errorHandler.getException(e, stackTrace);
      emit(state.copyWith(
        refreshState: RefreshState.error(failure),
        errorState: ErrorState.fromFailure(failure),
      ));
    }
  }

  Future<void> _onLoadMoreEntities(
    LoadMoreEntitiesEvent event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    final currentPagination = state.paginationState;

    if (!currentPagination.hasNextPage || currentPagination.isLoadingMore) {
      return;
    }

    emit(state.copyWith(
      paginationState: currentPagination.copyWith(isLoadingMore: true),
    ));

    try {
      final (paginatedResult, failure) = await _repository.getEntities(
        pagination: Pagination(
          page: currentPagination.currentPage + 1,
          pageSize: currentPagination.pageSize,
        ),
        filters: state.filterState.activeFilters,
      );

      if (failure != null) {
        emit(state.copyWith(
          paginationState: currentPagination.copyWith(
            isLoadingMore: false,
            loadMoreError: failure,
          ),
          errorState: ErrorState.fromFailure(failure),
        ));
      } else if (paginatedResult != null) {
        final currentEntities = state.dataState.data ?? <TEntity>[];
        final allEntities = [...currentEntities, ...paginatedResult.items];

        emit(state.copyWith(
          dataState: DataState<List<TEntity>>.success(allEntities),
          paginationState: PaginationState.fromResult(
            paginatedResult.copyWith(items: allEntities),
          ),
        ));
      }
    } catch (e, stackTrace) {
      final failure = _errorHandler.getException(e, stackTrace);
      emit(state.copyWith(
        paginationState: currentPagination.copyWith(isLoadingMore: false),
        errorState: ErrorState.fromFailure(failure),
      ));
    }
  }

  Future<void> _onCreateEntity(
    CreateEntityEvent<TEntity> event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    final (isValid, errors) = event.validate();
    if (!isValid) {
      emit(state.copyWith(
        errorState:
            ErrorState.validation('Invalid entity: ${errors.join(', ')}'),
      ));
      return;
    }

    // ✅ FIX: Protección contra eventos duplicados
    // Si ya hay una mutación en progreso, ignorar este evento
    if (state.mutationState.isLoading) {
      print('⚠️ BASE_CRUD_BLOC: Mutation already in progress (${state.mutationState}), ignoring duplicate CreateEntityEvent');
      return;
    }

    print('✅ BASE_CRUD_BLOC: Processing CreateEntityEvent');
    emit(state.copyWith(
      mutationState: MutationState.creating(),
    ));

    try {
      final (createdEntity, failure) =
          await _repository.createEntity(event.entity);

      if (failure != null) {
        emit(state.copyWith(
          mutationState: MutationState.error(failure),
          errorState: ErrorState.fromFailure(failure),
        ));
      } else if (createdEntity != null) {
        final currentEntities = state.dataState.data ?? <TEntity>[];
        final updatedEntities = [createdEntity, ...currentEntities];

        emit(state.copyWith(
          dataState: DataState<List<TEntity>>.success(updatedEntities),
          mutationState: MutationState.success('Entity created successfully'),
          selectedEntity: createdEntity,
          clearErrorState: true,
        ));

        // ✅ FIX: Only schedule sync if entity was NOT already synced
        // createEntity() already syncs with backend when connected, so we skip redundant sync
        final wasAlreadySynced = (createdEntity as dynamic).syncMeta?.isSynced == true ||
                                 (createdEntity as dynamic).id?.serverId != null;

        if (state.connectionState.isConnected && !isClosed && !wasAlreadySynced) {
          print('🔄 BASE_CRUD_BLOC: Scheduling sync after entity creation (not synced yet)');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!isClosed) {
              print('🚀 BASE_CRUD_BLOC: Dispatching SyncEntitiesEvent after creation');
              add(SyncEntitiesEvent());
            }
          });
        } else {
          print('⚠️ BASE_CRUD_BLOC: Skipping sync - Connected: ${state.connectionState.isConnected}, Closed: $isClosed, AlreadySynced: $wasAlreadySynced');
        }
      }
    } catch (e, stackTrace) {
      final failure = _errorHandler.getException(e, stackTrace);
      emit(state.copyWith(
        mutationState: MutationState.error(failure),
        errorState: ErrorState.fromFailure(failure),
      ));
    }
  }

  Future<void> _onUpdateEntity(
    UpdateEntityEvent<TEntity> event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    print('🟢 BASE_CRUD_BLOC: _onUpdateEntity called with entity ID: ${event.entity.id.uniqueKey}');
    
    final (isValid, errors) = event.validate();
    if (!isValid) {
      print('❌ BASE_CRUD_BLOC: Validation failed: ${errors.join(', ')}');
      emit(state.copyWith(
        errorState:
            ErrorState.validation('Invalid entity: ${errors.join(', ')}'),
      ));
      return;
    }

    print('🟢 BASE_CRUD_BLOC: Setting mutation state to updating');
    emit(state.copyWith(
      mutationState: MutationState.updating(),
    ));

    try {
      print('🟢 BASE_CRUD_BLOC: Calling repository.updateEntity');
      final (updatedEntity, failure) =
          await _repository.updateEntity(event.entity);

      if (failure != null) {
        print('❌ BASE_CRUD_BLOC: Repository returned failure: $failure');
        emit(state.copyWith(
          mutationState: MutationState.error(failure),
          errorState: ErrorState.fromFailure(failure),
        ));
      } else if (updatedEntity != null) {
        print('✅ BASE_CRUD_BLOC: Repository returned updated entity successfully');
        final currentEntities = state.dataState.data ?? <TEntity>[];
        final updatedEntities = currentEntities
            .map((entity) => entity.id.uniqueKey == updatedEntity.id.uniqueKey
                ? updatedEntity
                : entity)
            .toList();

        print('🟢 BASE_CRUD_BLOC: Setting mutation state to success');
        emit(state.copyWith(
          dataState: DataState<List<TEntity>>.success(updatedEntities),
          mutationState: MutationState.success('Entity updated successfully'),
          selectedEntity: updatedEntity,
          clearErrorState: true,
        ));

        // Schedule sync event for next frame to prevent "close" race condition
        if (state.connectionState.isConnected && !isClosed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!isClosed) {
              add(const SyncEntitiesEvent());
            }
          });
        }
      } else {
        print('❌ BASE_CRUD_BLOC: Repository returned null entity');
      }
    } catch (e, stackTrace) {
      print('❌ BASE_CRUD_BLOC: Exception in updateEntity: $e');
      final failure = _errorHandler.getException(e, stackTrace);
      emit(state.copyWith(
        mutationState: MutationState.error(failure),
        errorState: ErrorState.fromFailure(failure),
      ));
    }
  }

  Future<void> _onDeleteEntity(
    DeleteEntityEvent event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    final (isValid, errors) = event.validate();
    if (!isValid) {
      emit(state.copyWith(
        errorState:
            ErrorState.validation('Invalid entity ID: ${errors.join(', ')}'),
      ));
      return;
    }

    emit(state.copyWith(
      mutationState: MutationState.deleting(),
    ));

    try {
      final (success, failure) = await _repository.deleteEntity(event.entityId);

      if (failure != null) {
        emit(state.copyWith(
          mutationState: MutationState.error(failure),
          errorState: ErrorState.fromFailure(failure),
        ));
      } else if (success == true) {
        final currentEntities = state.dataState.data ?? <TEntity>[];
        final updatedEntities = currentEntities
            .where((entity) => entity.id.uniqueKey != event.entityId)
            .toList();

        emit(state.copyWith(
          dataState: DataState<List<TEntity>>.success(updatedEntities),
          mutationState: MutationState.success('Entity deleted successfully'),
          clearSelectedEntity: true,
          clearErrorState: true,
        ));

        // Schedule sync event for next frame to prevent "close" race condition
        if (state.connectionState.isConnected && !isClosed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!isClosed) {
              add(const SyncEntitiesEvent());
            }
          });
        }
      }
    } catch (e, stackTrace) {
      final failure = _errorHandler.getException(e, stackTrace);
      emit(state.copyWith(
        mutationState: MutationState.error(failure),
        errorState: ErrorState.fromFailure(failure),
      ));
    }
  }

  Future<void> _onSearchEntities(
    SearchEntitiesEvent event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    final (isValid, errors) = event.validate();
    if (!isValid) {
      emit(state.copyWith(
        errorState:
            ErrorState.validation('Invalid search: ${errors.join(', ')}'),
      ));
      return;
    }

    _searchDebounceTimer?.cancel();

    emit(state.copyWith(
      searchState: SearchState.searching(query: event.query),
    ));

    _searchDebounceTimer = Timer(searchDebounceDelay, () async {
      await _executeSearch(event, emit);
    });
  }

  Future<void> _executeSearch(
    SearchEntitiesEvent event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(searchState: SearchState.idle()));
      return;
    }

    try {
      final (searchResults, failure) = await _searchService.searchEntities(
        query: event.query,
        filters: state.filterState.activeFilters,
        pagination: Pagination(page: 1, pageSize: defaultPageSize),
      );

      if (failure != null) {
        emit(state.copyWith(
          searchState: SearchState.error(failure),
          errorState: ErrorState.fromFailure(failure),
        ));
      } else if (searchResults != null) {
        emit(state.copyWith(
          searchState: SearchState.results(
            query: event.query,
            results: searchResults.items,
            totalCount: searchResults.totalCount,
          ),
          dataState: DataState<List<TEntity>>.success(searchResults.items),
          clearErrorState: true,
        ));
      }
    } catch (e, stackTrace) {
      final failure = _errorHandler.getException(e, stackTrace);
      emit(state.copyWith(
        searchState: SearchState.error(failure),
        errorState: ErrorState.fromFailure(failure),
      ));
    }
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    _searchDebounceTimer?.cancel();

    emit(state.copyWith(searchState: SearchState.idle()));
    add(LoadEntitiesEvent());
  }

  Future<void> _onSyncEntities(
    SyncEntitiesEvent event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    print('🔄 BASE_CRUD_BLOC: _onSyncEntities called for type $TEntity');
    
    if (!state.connectionState.isConnected) {
      print('❌ BASE_CRUD_BLOC: No connection available for sync');
      emit(state.copyWith(
        syncState:
            BlocSyncState.error(FailureCommons.thereIsNoNetworkConnection()),
        errorState: ErrorState.network('No network connection'),
      ));
      return;
    }
    
    print('✅ BASE_CRUD_BLOC: Connection available, starting sync...');

    // ✅ PRESERVE current data state during sync
    final currentDataState = state.dataState;

    emit(state.copyWith(syncState: BlocSyncState.syncing()));

    try {
      final (syncSummary, failure) = await _repository.syncAllEntities();

      if (failure != null) {
        // ✅ CRITICAL: Preserve data state on sync failure
        emit(state.copyWith(
          syncState: BlocSyncState.error(failure),
          errorState: ErrorState.fromFailure(failure),
          dataState: currentDataState, // Keep existing data
        ));
      } else if (syncSummary != null) {
        emit(state.copyWith(
          syncState: BlocSyncState.success(syncSummary),
          lastSyncTime: DateTime.now(),
          clearErrorState: true,
          // Note: dataState will be updated by EntitiesUpdatedEvent from watchEntities
        ));
      }
    } catch (e, stackTrace) {
      final failure = _errorHandler.getException(e, stackTrace);
      // ✅ CRITICAL: Preserve data state on sync exception
      emit(state.copyWith(
        syncState: BlocSyncState.error(failure),
        errorState: ErrorState.fromFailure(failure),
        dataState: currentDataState, // Keep existing data
      ));
    }
  }

  Future<void> _onSelectEntity(
    SelectEntityEvent<TEntity> event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    final (isValid, errors) = event.validate();
    if (!isValid) return;

    emit(state.copyWith(
      selectedEntity: event.entity,
      selectionState: SelectionState.selected(event.entity),
    ));
  }

  Future<void> _onClearSelection(
    ClearSelectionEvent event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    emit(state.copyWith(
      clearSelectedEntity: true,
      selectionState: SelectionState.idle(),
    ));
  }

  Future<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    print('🔧 APPLY FILTERS: Processing filters: ${event.filters}');
    
    final (isValid, errors) = event.validate();
    if (!isValid) {
      print('❌ APPLY FILTERS: Validation failed: ${errors.join(', ')}');
      emit(state.copyWith(
        errorState:
            ErrorState.validation('Invalid filters: ${errors.join(', ')}'),
      ));
      return;
    }

    print('✅ APPLY FILTERS: Filters valid, applying state');
    emit(state.copyWith(filterState: FilterState.applied(event.filters)));
    
    // ✅ LAZY WATCHER: Start watcher AFTER filters are applied
    print('🔧 APPLY FILTERS: About to ensure watcher is active');
    _ensureWatcherActive();
    
    print('🔧 APPLY FILTERS: Adding LoadEntitiesEvent');
    add(LoadEntitiesEvent(filters: event.filters, forceRefresh: true));
  }

  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    emit(state.copyWith(filterState: FilterState.idle()));
    add(LoadEntitiesEvent(forceRefresh: true));
  }

  Future<void> _onEntitiesUpdated(
    EntitiesUpdatedEvent<TEntity> event,
    Emitter<BaseCrudState<TEntity>> emit,
  ) async {
    final (isValid, errors) = event.validate();
    if (!isValid) return;

    // ✅ CRITICAL: Don't overwrite existing data with empty lists
    // This prevents UI flickering when streams emit empty data due to errors
    final currentEntities = state.dataState.data ?? <TEntity>[];
    final newEntities = event.entities;
    
    // Only update if we have new data OR if current data is empty
    if (newEntities.isNotEmpty || currentEntities.isEmpty) {
      emit(state.copyWith(
        dataState: DataState<List<TEntity>>.success(newEntities),
      ));
    }
    // If newEntities is empty but we have currentEntities, keep the current data
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _entitiesSubscription?.cancel();
    _searchDebounceTimer?.cancel();
    return super.close();
  }
}

// ===== BASE EVENTS (Manual Implementation) =====

abstract class BaseCrudEvent {
  const BaseCrudEvent();

  EventValidationResult validate();
  String get eventType;
  Map<String, dynamic> get eventData;

  @override
  String toString() => '$eventType($eventData)';
}

class ConnectionChangedEvent extends BaseCrudEvent {
  final bool isConnected;

  const ConnectionChangedEvent({required this.isConnected});

  @override
  EventValidationResult validate() => (true, <String>[]);

  @override
  String get eventType => 'ConnectionChanged';

  @override
  Map<String, dynamic> get eventData => {'isConnected': isConnected};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConnectionChangedEvent && other.isConnected == isConnected);

  @override
  int get hashCode => isConnected.hashCode;
}

class LoadEntitiesEvent extends BaseCrudEvent {
  final Map<String, dynamic>? filters;
  final List<String>? sortBy;
  final int? pageSize;
  final bool forceRefresh;

  const LoadEntitiesEvent({
    this.filters,
    this.sortBy,
    this.pageSize,
    this.forceRefresh = false,
  });

  @override
  EventValidationResult validate() {
    final errors = <String>[];

    if (pageSize != null) {
      if (pageSize! < 1) {
        errors.add('pageSize must be positive, got: $pageSize');
      }
      if (pageSize! > 1000) {
        errors.add('pageSize too large (max 1000), got: $pageSize');
      }
    }

    return (errors.isEmpty, errors);
  }

  @override
  String get eventType => 'LoadEntities';

  @override
  Map<String, dynamic> get eventData => {
        'filters': filters,
        'sortBy': sortBy,
        'pageSize': pageSize,
        'forceRefresh': forceRefresh,
      };
}

class LoadEntityByIdEvent extends BaseCrudEvent {
  final String entityId;

  const LoadEntityByIdEvent({required this.entityId});

  @override
  EventValidationResult validate() {
    if (entityId.trim().isEmpty) {
      return (false, ['Entity ID cannot be empty']);
    }
    return (true, <String>[]);
  }

  @override
  String get eventType => 'LoadEntityById';

  @override
  Map<String, dynamic> get eventData => {'entityId': entityId};
}

class RefreshEntitiesEvent extends BaseCrudEvent {
  const RefreshEntitiesEvent();

  @override
  EventValidationResult validate() => (true, <String>[]);

  @override
  String get eventType => 'RefreshEntities';

  @override
  Map<String, dynamic> get eventData => {};
}

class LoadMoreEntitiesEvent extends BaseCrudEvent {
  const LoadMoreEntitiesEvent();

  @override
  EventValidationResult validate() => (true, <String>[]);

  @override
  String get eventType => 'LoadMoreEntities';

  @override
  Map<String, dynamic> get eventData => {};
}

class CreateEntityEvent<TEntity extends IBaseEntity> extends BaseCrudEvent {
  final TEntity entity;

  const CreateEntityEvent({required this.entity});

  @override
  EventValidationResult validate() {
    final errors = <String>[];

    final (isEntityValid, entityErrors) = entity.validate();
    if (!isEntityValid) {
      errors.addAll(entityErrors.map((e) => 'Entity validation: $e'));
    }

    if (entity.id.hasServerId) {
      errors.add('Cannot create entity that already has server ID');
    }

    return (errors.isEmpty, errors);
  }

  @override
  String get eventType => 'CreateEntity';

  @override
  Map<String, dynamic> get eventData => {
        'entityType': entity.runtimeType.toString(),
        'entityId': entity.id.uniqueKey,
      };
}

class UpdateEntityEvent<TEntity extends IBaseEntity> extends BaseCrudEvent {
  final TEntity entity;

  const UpdateEntityEvent({required this.entity});

  @override
  EventValidationResult validate() {
    final errors = <String>[];

    final (isEntityValid, entityErrors) = entity.validate();
    if (!isEntityValid) {
      errors.addAll(entityErrors.map((e) => 'Entity validation: $e'));
    }

    if (!entity.id.hasLocalId && !entity.id.hasServerId && !entity.id.hasTempId) {
      errors.add('Cannot update entity without ID');
    }

    return (errors.isEmpty, errors);
  }

  @override
  String get eventType => 'UpdateEntity';

  @override
  Map<String, dynamic> get eventData => {
        'entityType': entity.runtimeType.toString(),
        'entityId': entity.id.uniqueKey,
      };
}

class DeleteEntityEvent extends BaseCrudEvent {
  final String entityId;

  const DeleteEntityEvent({required this.entityId});

  @override
  EventValidationResult validate() {
    final errors = <String>[];

    if (entityId.trim().isEmpty) {
      errors.add('entityId cannot be empty');
    }

    return (errors.isEmpty, errors);
  }

  @override
  String get eventType => 'DeleteEntity';

  @override
  Map<String, dynamic> get eventData => {'entityId': entityId};
}

class SearchEntitiesEvent extends BaseCrudEvent {
  final String query;

  const SearchEntitiesEvent({required this.query});

  @override
  EventValidationResult validate() {
    final errors = <String>[];

    if (query.trim().isEmpty) {
      errors.add('search query cannot be empty');
    }

    if (query.length > 500) {
      errors.add('search query too long');
    }

    return (errors.isEmpty, errors);
  }

  @override
  String get eventType => 'SearchEntities';

  @override
  Map<String, dynamic> get eventData => {'query': query};
}

class ClearSearchEvent extends BaseCrudEvent {
  const ClearSearchEvent();

  @override
  EventValidationResult validate() => (true, <String>[]);

  @override
  String get eventType => 'ClearSearch';

  @override
  Map<String, dynamic> get eventData => {};
}

class SyncEntitiesEvent extends BaseCrudEvent {
  const SyncEntitiesEvent();

  @override
  EventValidationResult validate() => (true, <String>[]);

  @override
  String get eventType => 'SyncEntities';

  @override
  Map<String, dynamic> get eventData => {};
}

class SelectEntityEvent<TEntity extends IBaseEntity> extends BaseCrudEvent {
  final TEntity entity;

  const SelectEntityEvent({required this.entity});

  @override
  EventValidationResult validate() {
    final (isEntityValid, _) = entity.validate();
    return (isEntityValid, <String>[]);
  }

  @override
  String get eventType => 'SelectEntity';

  @override
  Map<String, dynamic> get eventData => {'entityId': entity.id.uniqueKey};
}

class ClearSelectionEvent extends BaseCrudEvent {
  const ClearSelectionEvent();

  @override
  EventValidationResult validate() => (true, <String>[]);

  @override
  String get eventType => 'ClearSelection';

  @override
  Map<String, dynamic> get eventData => {};
}

class ApplyFiltersEvent extends BaseCrudEvent {
  final Map<String, dynamic> filters;

  const ApplyFiltersEvent({required this.filters});

  @override
  EventValidationResult validate() {
    final errors = <String>[];

    if (filters.isEmpty) {
      errors.add('filters cannot be empty');
    }

    for (final entry in filters.entries) {
      if (entry.key.trim().isEmpty) {
        errors.add('filter key cannot be empty');
      }
    }

    return (errors.isEmpty, errors);
  }

  @override
  String get eventType => 'ApplyFilters';

  @override
  Map<String, dynamic> get eventData => {'filterCount': filters.length};
}

class ClearFiltersEvent extends BaseCrudEvent {
  const ClearFiltersEvent();

  @override
  EventValidationResult validate() => (true, <String>[]);

  @override
  String get eventType => 'ClearFilters';

  @override
  Map<String, dynamic> get eventData => {};
}

class EntitiesUpdatedEvent<TEntity extends IBaseEntity> extends BaseCrudEvent {
  final List<TEntity> entities;

  const EntitiesUpdatedEvent({required this.entities});

  @override
  EventValidationResult validate() {
    final errors = <String>[];

    for (int i = 0; i < entities.length; i++) {
      final entity = entities[i];
      final (isValid, entityErrors) = entity.validate();
      if (!isValid) {
        errors.addAll(entityErrors.map((e) => 'Entity[$i]: $e'));
      }
    }

    return (errors.isEmpty, errors);
  }

  @override
  String get eventType => 'EntitiesUpdated';

  @override
  Map<String, dynamic> get eventData => {'entityCount': entities.length};
}

// ===== BASE STATE (Manual Implementation) =====

class BaseCrudState<TEntity extends IBaseEntity> {
  final DataState<List<TEntity>> _dataState;
  final ConnectionState _connectionState;
  final PaginationState _paginationState;
  final SearchState _searchState;
  final BlocSyncState _syncState;
  final MutationState _mutationState;
  final FilterState _filterState;
  final SelectionState _selectionState;
  final RefreshState _refreshState;
  final TEntity? _selectedEntity;
  final ErrorState? _errorState;
  final DateTime? _lastLoadTime;
  final DateTime? _lastSyncTime;

  const BaseCrudState._({
    required DataState<List<TEntity>> dataState,
    required ConnectionState connectionState,
    required PaginationState paginationState,
    required SearchState searchState,
    required BlocSyncState syncState,
    required MutationState mutationState,
    required FilterState filterState,
    required SelectionState selectionState,
    required RefreshState refreshState,
    TEntity? selectedEntity,
    ErrorState? errorState,
    DateTime? lastLoadTime,
    DateTime? lastSyncTime,
  })  : _dataState = dataState,
        _connectionState = connectionState,
        _paginationState = paginationState,
        _searchState = searchState,
        _syncState = syncState,
        _mutationState = mutationState,
        _filterState = filterState,
        _selectionState = selectionState,
        _refreshState = refreshState,
        _selectedEntity = selectedEntity,
        _errorState = errorState,
        _lastLoadTime = lastLoadTime,
        _lastSyncTime = lastSyncTime;

  factory BaseCrudState({
    required DataState<List<TEntity>> dataState,
    required ConnectionState connectionState,
    required PaginationState paginationState,
    required SearchState searchState,
    required BlocSyncState syncState,
    required MutationState mutationState,
    required FilterState filterState,
    required SelectionState selectionState,
    required RefreshState refreshState,
    TEntity? selectedEntity,
    ErrorState? errorState,
    DateTime? lastLoadTime,
    DateTime? lastSyncTime,
  }) {
    ArgumentError.checkNotNull(dataState, 'dataState');
    ArgumentError.checkNotNull(connectionState, 'connectionState');
    ArgumentError.checkNotNull(paginationState, 'paginationState');
    ArgumentError.checkNotNull(searchState, 'searchState');
    ArgumentError.checkNotNull(syncState, 'syncState');
    ArgumentError.checkNotNull(mutationState, 'mutationState');
    ArgumentError.checkNotNull(filterState, 'filterState');
    ArgumentError.checkNotNull(selectionState, 'selectionState');
    ArgumentError.checkNotNull(refreshState, 'refreshState');

    return BaseCrudState._(
      dataState: dataState,
      connectionState: connectionState,
      paginationState: paginationState,
      searchState: searchState,
      syncState: syncState,
      mutationState: mutationState,
      filterState: filterState,
      selectionState: selectionState,
      refreshState: refreshState,
      selectedEntity: selectedEntity,
      errorState: errorState,
      lastLoadTime: lastLoadTime,
      lastSyncTime: lastSyncTime,
    );
  }

  factory BaseCrudState.initial() {
    return BaseCrudState<TEntity>(
      dataState: DataState<List<TEntity>>.initial(),
      connectionState: ConnectionState.unknown(),
      paginationState: PaginationState.initial(),
      searchState: SearchState.idle(),
      syncState: BlocSyncState.idle(),
      mutationState: MutationState.idle(),
      filterState: FilterState.idle(),
      selectionState: SelectionState.idle(),
      refreshState: RefreshState.idle(),
    );
  }

  // Getters
  DataState<List<TEntity>> get dataState => _dataState;
  ConnectionState get connectionState => _connectionState;
  PaginationState get paginationState => _paginationState;
  SearchState get searchState => _searchState;
  BlocSyncState get syncState => _syncState;
  MutationState get mutationState => _mutationState;
  FilterState get filterState => _filterState;
  SelectionState get selectionState => _selectionState;
  RefreshState get refreshState => _refreshState;
  TEntity? get selectedEntity => _selectedEntity;
  ErrorState? get errorState => _errorState;
  DateTime? get lastLoadTime => _lastLoadTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  // Computed properties
  bool get hasData => _dataState.hasData;
  bool get isLoading => _dataState.isLoading;
  bool get hasError => _dataState.hasError || _errorState != null;
  bool get isEmpty => _dataState.data?.isEmpty ?? true;
  bool get isSearching => _searchState.isSearching;
  bool get hasSearchResults => _searchState.hasResults;
  bool get isSyncing => _syncState.isSyncing;
  bool get hasPendingSync => _syncState.hasPendingSync;
  bool get isRefreshing => _refreshState.isRefreshing;
  bool get canLoadMore =>
      _paginationState.hasNextPage && !_paginationState.isLoadingMore;
  bool get hasSelection => _selectedEntity != null;

  List<TEntity> get entities => _dataState.data ?? <TEntity>[];
  String? get errorMessage => _errorState?.message;

  // Single entity state management for detail/edit pages
  DataState<TEntity> get singleEntityState {
    if (_selectedEntity != null) {
      return DataState<TEntity>.success(_selectedEntity);
    } else if (_dataState.isLoading) {
      return DataState<TEntity>.loading();
    } else if (_dataState.hasError) {
      return DataState<TEntity>.error(_dataState.error!);
    } else {
      return DataState<TEntity>.initial();
    }
  }

  // UI convenience getters for mutations
  bool get isCreated =>
      _mutationState._type == MutationStateType.success &&
      (_mutationState._message?.contains('create') == true || 
       _mutationState._message?.contains('created') == true);
  bool get isUpdated =>
      _mutationState._type == MutationStateType.success &&
      _mutationState._message?.contains('update') == true;
  bool get isDeleted =>
      _mutationState._type == MutationStateType.success &&
      _mutationState._message?.contains('delete') == true;
  bool get isCreating => _mutationState._type == MutationStateType.creating;
  bool get isUpdating => _mutationState._type == MutationStateType.updating;
  bool get isDeleting => _mutationState._type == MutationStateType.deleting;
  bool get hasMutationError => _mutationState._type == MutationStateType.error;

  BaseCrudState<TEntity> copyWith({
    DataState<List<TEntity>>? dataState,
    ConnectionState? connectionState,
    PaginationState? paginationState,
    SearchState? searchState,
    BlocSyncState? syncState,
    MutationState? mutationState,
    FilterState? filterState,
    SelectionState? selectionState,
    RefreshState? refreshState,
    TEntity? selectedEntity,
    ErrorState? errorState,
    DateTime? lastLoadTime,
    DateTime? lastSyncTime,
    bool clearSelectedEntity = false,
    bool clearErrorState = false,
    bool clearLastLoadTime = false,
    bool clearLastSyncTime = false,
  }) {
    return BaseCrudState<TEntity>(
      dataState: dataState ?? _dataState,
      connectionState: connectionState ?? _connectionState,
      paginationState: paginationState ?? _paginationState,
      searchState: searchState ?? _searchState,
      syncState: syncState ?? _syncState,
      mutationState: mutationState ?? _mutationState,
      filterState: filterState ?? _filterState,
      selectionState: selectionState ?? _selectionState,
      refreshState: refreshState ?? _refreshState,
      selectedEntity:
          clearSelectedEntity ? null : (selectedEntity ?? _selectedEntity),
      errorState: clearErrorState ? null : (errorState ?? _errorState),
      lastLoadTime: clearLastLoadTime ? null : (lastLoadTime ?? _lastLoadTime),
      lastSyncTime: clearLastSyncTime ? null : (lastSyncTime ?? _lastSyncTime),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BaseCrudState<TEntity>) return false;

    return _dataState == other._dataState &&
        _connectionState == other._connectionState &&
        _paginationState == other._paginationState &&
        _searchState == other._searchState &&
        _syncState == other._syncState &&
        _mutationState == other._mutationState &&
        _filterState == other._filterState &&
        _selectionState == other._selectionState &&
        _refreshState == other._refreshState &&
        _selectedEntity == other._selectedEntity &&
        _errorState == other._errorState &&
        _lastLoadTime == other._lastLoadTime &&
        _lastSyncTime == other._lastSyncTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      _dataState,
      _connectionState,
      _paginationState,
      _searchState,
      _syncState,
      _mutationState,
      _filterState,
      _selectionState,
      _refreshState,
      _selectedEntity,
      _errorState,
      _lastLoadTime,
      _lastSyncTime,
    );
  }

  @override
  String toString() {
    return 'BaseCrudState<$TEntity>(\n'
        '  dataState: $_dataState,\n'
        '  entities: ${entities.length} items,\n'
        '  hasError: $hasError,\n'
        '  isLoading: $isLoading,\n'
        ')';
  }
}

// ===== STATE COMPONENTS =====

class DataState<T> {
  final DataStateType _type;
  final T? _data;
  final FailureCommons? _error;

  const DataState._(this._type, this._data, this._error);

  factory DataState.initial() => DataState._(DataStateType.initial, null, null);
  factory DataState.loading() => DataState._(DataStateType.loading, null, null);

  factory DataState.success(T data) {
    ArgumentError.checkNotNull(data, 'data');
    return DataState._(DataStateType.success, data, null);
  }

  factory DataState.error(FailureCommons error) {
    ArgumentError.checkNotNull(error, 'error');
    return DataState._(DataStateType.error, null, error);
  }

  bool get isInitial => _type == DataStateType.initial;
  bool get isLoading => _type == DataStateType.loading;
  bool get hasData => _type == DataStateType.success && _data != null;
  bool get hasError => _type == DataStateType.error && _error != null;

  T? get data => _data;
  FailureCommons? get error => _error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataState<T> &&
        other._type == _type &&
        other._data == _data &&
        other._error == _error;
  }

  @override
  int get hashCode => Object.hash(_type, _data, _error);

  @override
  String toString() => 'DataState<$T>.${_type.name}';
}

enum DataStateType { initial, loading, success, error }

class ConnectionState {
  final ConnectionStateType _type;

  const ConnectionState._(this._type);

  factory ConnectionState.unknown() =>
      ConnectionState._(ConnectionStateType.unknown);
  factory ConnectionState.connected() =>
      ConnectionState._(ConnectionStateType.connected);
  factory ConnectionState.disconnected() =>
      ConnectionState._(ConnectionStateType.disconnected);

  bool get isConnected => _type == ConnectionStateType.connected;
  bool get isDisconnected => _type == ConnectionStateType.disconnected;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ConnectionState && other._type == _type);
  }

  @override
  int get hashCode => _type.hashCode;

  @override
  String toString() => 'ConnectionState.${_type.name}';
}

enum ConnectionStateType { unknown, connected, disconnected }

class PaginationState {
  final int _currentPage;
  final int _pageSize;
  final int _totalCount;
  final bool _hasNextPage;
  final bool _isLoadingMore;
  final FailureCommons? _loadMoreError;

  const PaginationState._({
    required int currentPage,
    required int pageSize,
    required int totalCount,
    required bool hasNextPage,
    required bool isLoadingMore,
    FailureCommons? loadMoreError,
  })  : _currentPage = currentPage,
        _pageSize = pageSize,
        _totalCount = totalCount,
        _hasNextPage = hasNextPage,
        _isLoadingMore = isLoadingMore,
        _loadMoreError = loadMoreError;

  factory PaginationState({
    required int currentPage,
    required int pageSize,
    required int totalCount,
    required bool hasNextPage,
    required bool isLoadingMore,
    FailureCommons? loadMoreError,
  }) {
    if (currentPage < 1) throw ArgumentError('currentPage must be >= 1');
    if (pageSize < 1) throw ArgumentError('pageSize must be >= 1');
    if (totalCount < 0) throw ArgumentError('totalCount must be >= 0');

    return PaginationState._(
      currentPage: currentPage,
      pageSize: pageSize,
      totalCount: totalCount,
      hasNextPage: hasNextPage,
      isLoadingMore: isLoadingMore,
      loadMoreError: loadMoreError,
    );
  }

  factory PaginationState.initial() => PaginationState(
        currentPage: 1,
        pageSize: 20,
        totalCount: 0,
        hasNextPage: false,
        isLoadingMore: false,
      );

  factory PaginationState.fromResult(PaginatedResult result) => PaginationState(
        currentPage: result.pagination.page,
        pageSize: result.pagination.pageSize,
        totalCount: result.totalCount,
        hasNextPage: result.hasNextPage,
        isLoadingMore: false,
      );

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;
  bool get hasNextPage => _hasNextPage;
  bool get isLoadingMore => _isLoadingMore;
  FailureCommons? get loadMoreError => _loadMoreError;

  PaginationState copyWith({
    int? currentPage,
    int? pageSize,
    int? totalCount,
    bool? hasNextPage,
    bool? isLoadingMore,
    FailureCommons? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return PaginationState(
      currentPage: currentPage ?? _currentPage,
      pageSize: pageSize ?? _pageSize,
      totalCount: totalCount ?? _totalCount,
      hasNextPage: hasNextPage ?? _hasNextPage,
      isLoadingMore: isLoadingMore ?? _isLoadingMore,
      loadMoreError:
          clearLoadMoreError ? null : (loadMoreError ?? _loadMoreError),
    );
  }

  @override
  String toString() =>
      'PaginationState(page: $_currentPage, total: $_totalCount)';
}

class SearchState {
  final SearchStateType _type;
  final String? _query;
  final List<IBaseEntity>? _results;
  final int? _totalCount;
  final FailureCommons? _failure;

  const SearchState._({
    required SearchStateType type,
    String? query,
    List<IBaseEntity>? results,
    int? totalCount,
    FailureCommons? failure,
  })  : _type = type,
        _query = query,
        _results = results,
        _totalCount = totalCount,
        _failure = failure;

  factory SearchState.idle() => SearchState._(type: SearchStateType.idle);

  factory SearchState.searching({required String query}) {
    ArgumentError.checkNotNull(query, 'query');
    return SearchState._(type: SearchStateType.searching, query: query);
  }

  factory SearchState.results({
    required String query,
    required List<IBaseEntity> results,
    required int totalCount,
  }) {
    ArgumentError.checkNotNull(query, 'query');
    ArgumentError.checkNotNull(results, 'results');
    if (totalCount < 0) throw ArgumentError('totalCount must be >= 0');
    return SearchState._(
      type: SearchStateType.results,
      query: query,
      results: results,
      totalCount: totalCount,
    );
  }

  factory SearchState.error(FailureCommons failure) {
    ArgumentError.checkNotNull(failure, 'failure');
    return SearchState._(type: SearchStateType.error, failure: failure);
  }

  bool get isSearching => _type == SearchStateType.searching;
  bool get hasResults => _type == SearchStateType.results && _results != null;
  bool get hasError => _type == SearchStateType.error;

  String? get query => _query;
  List<IBaseEntity> get results => _results ?? <IBaseEntity>[];
  int get totalCount => _totalCount ?? 0;

  @override
  String toString() => 'SearchState.${_type.name}';
}

enum SearchStateType { idle, searching, results, error }

class BlocSyncState {
  final BlocBlocSyncStateType _type;

  const BlocSyncState._(this._type);

  factory BlocSyncState.idle() => BlocSyncState._(BlocBlocSyncStateType.idle);
  factory BlocSyncState.syncing() =>
      BlocSyncState._(BlocBlocSyncStateType.syncing);
  factory BlocSyncState.success(dynamic summary) =>
      BlocSyncState._(BlocBlocSyncStateType.success);
  factory BlocSyncState.error(FailureCommons failure) =>
      BlocSyncState._(BlocBlocSyncStateType.error);

  bool get isSyncing => _type == BlocBlocSyncStateType.syncing;
  bool get hasPendingSync =>
      _type == BlocBlocSyncStateType.idle ||
      _type == BlocBlocSyncStateType.error;
  bool get hasError => _type == BlocBlocSyncStateType.error;

  @override
  String toString() => 'BlocSyncState.${_type.name}';
}

enum BlocBlocSyncStateType { idle, syncing, success, error }

class MutationState {
  final MutationStateType _type;
  final String? _message;
  final FailureCommons? _failure;

  const MutationState._({
    required MutationStateType type,
    String? message,
    FailureCommons? failure,
  })  : _type = type,
        _message = message,
        _failure = failure;

  factory MutationState.idle() => MutationState._(type: MutationStateType.idle);
  factory MutationState.creating() =>
      MutationState._(type: MutationStateType.creating);
  factory MutationState.updating() =>
      MutationState._(type: MutationStateType.updating);
  factory MutationState.deleting() =>
      MutationState._(type: MutationStateType.deleting);

  factory MutationState.success(String message) {
    ArgumentError.checkNotNull(message, 'message');
    return MutationState._(type: MutationStateType.success, message: message);
  }

  factory MutationState.error(FailureCommons failure) {
    ArgumentError.checkNotNull(failure, 'failure');
    return MutationState._(type: MutationStateType.error, failure: failure);
  }

  bool get isIdle => _type == MutationStateType.idle;
  bool get isLoading =>
      _type == MutationStateType.creating ||
      _type == MutationStateType.updating ||
      _type == MutationStateType.deleting;
  bool get isCreated =>
      _type == MutationStateType.success &&
      (_message?.contains('create') == true || 
       _message?.contains('created') == true);
  bool get hasError => _type == MutationStateType.error;
  @override
  String toString() => 'MutationState.${_type.name}';
}

enum MutationStateType { idle, creating, updating, deleting, success, error }

class FilterState {
  final Map<String, dynamic> _filters;

  const FilterState._(this._filters);

  factory FilterState.idle() => FilterState._(const <String, dynamic>{});

  factory FilterState.applied(Map<String, dynamic> filters) {
    ArgumentError.checkNotNull(filters, 'filters');
    return FilterState._(Map.unmodifiable(filters));
  }

  bool get hasFilters => _filters.isNotEmpty;
  bool get isApplied => _filters.isNotEmpty;
  Map<String, dynamic> get activeFilters => Map.unmodifiable(_filters);

  @override
  String toString() => 'FilterState(${_filters.length} filters)';
}

class SelectionState {
  final SelectionStateType _type;
  final IBaseEntity? _entity;

  const SelectionState._({
    required SelectionStateType type,
    IBaseEntity? entity,
  })  : _type = type,
        _entity = entity;

  factory SelectionState.idle() =>
      SelectionState._(type: SelectionStateType.idle);

  factory SelectionState.selected(IBaseEntity entity) {
    ArgumentError.checkNotNull(entity, 'entity');
    return SelectionState._(type: SelectionStateType.selected, entity: entity);
  }

  bool get hasSelection =>
      _type == SelectionStateType.selected && _entity != null;

  @override
  String toString() => 'SelectionState.${_type.name}';
}

enum SelectionStateType { idle, selected }

class RefreshState {
  final RefreshStateType _type;
  final FailureCommons? _failure;

  const RefreshState._({
    required RefreshStateType type,
    FailureCommons? failure,
  })  : _type = type,
        _failure = failure;

  factory RefreshState.idle() => RefreshState._(type: RefreshStateType.idle);
  factory RefreshState.refreshing() =>
      RefreshState._(type: RefreshStateType.refreshing);

  factory RefreshState.error(FailureCommons failure) {
    ArgumentError.checkNotNull(failure, 'failure');
    return RefreshState._(type: RefreshStateType.error, failure: failure);
  }

  bool get isRefreshing => _type == RefreshStateType.refreshing;

  @override
  String toString() => 'RefreshState.${_type.name}';
}

enum RefreshStateType { idle, refreshing, error }

class ErrorState {
  final ErrorStateType _type;
  final String _message;

  const ErrorState._({
    required ErrorStateType type,
    required String message,
  })  : _type = type,
        _message = message;

  factory ErrorState.network(String message) {
    ArgumentError.checkNotNull(message, 'message');
    return ErrorState._(type: ErrorStateType.network, message: message);
  }

  factory ErrorState.validation(String message) {
    ArgumentError.checkNotNull(message, 'message');
    return ErrorState._(type: ErrorStateType.validation, message: message);
  }

  factory ErrorState.permission(String message) {
    ArgumentError.checkNotNull(message, 'message');
    return ErrorState._(type: ErrorStateType.permission, message: message);
  }

  factory ErrorState.unexpected(String message) {
    ArgumentError.checkNotNull(message, 'message');
    return ErrorState._(type: ErrorStateType.unexpected, message: message);
  }

  factory ErrorState.fromFailure(FailureCommons failure) {
    ArgumentError.checkNotNull(failure, 'failure');

    // Usar toString() para determinar el tipo de error y crear el estado apropiado
    final failureStr = failure.toString();

    if (failureStr.contains('NoNetworkConnection') ||
        failureStr.contains('ConnectionClosed') ||
        failureStr.contains('NoInternet')) {
      return ErrorState.network('Network connection error');
    } else if (failureStr.contains('BadRequest') ||
        failureStr.contains('InvalidEmail') ||
        failureStr.contains('InvalidPassword') ||
        failureStr.contains('InvalidPhone')) {
      return ErrorState.validation('Validation error');
    } else if (failureStr.contains('Unauthorized') ||
        failureStr.contains('Unauthenticated') ||
        failureStr.contains('InvalidToken')) {
      return ErrorState.permission('Permission denied');
    } else {
      return ErrorState.unexpected(failureStr);
    }
  }

  String get message => _message;

  @override
  String toString() => 'ErrorState.${_type.name}: $_message';
}

enum ErrorStateType { network, validation, permission, unexpected }
