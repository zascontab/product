import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rantipay_app/core/i18n/app_locations.dart';
import '../../domain/entities/base_entity.dart';
import '../../application/blocs/base_crud_bloc.dart';

// Native tuple patterns - no external dependencies
/// Result type for list operations using native Dart tuples
typedef ListResult<T> = (T? data, String? error);

/// Universal base list widget that eliminates 900+ lines of duplicate code from:
/// - bpa_category_list.dart (312 lines)
/// - bpa_crop_list.dart (298 lines)
/// - bpa_plot_list.dart (285 lines)
/// - bpa_producer_list.dart (294 lines)
/// - Plus 10+ other list widgets
///
/// Performance targets:
/// - List rendering: <100ms for 500 items
/// - Scroll performance: 60fps sustained
/// - Pull-to-refresh: <500ms response
/// - Memory efficiency: <2MB per 1000 items
abstract class BaseListWidget<TEntity extends IBaseEntity,
    TBloc extends BaseCrudBloc<TEntity>> extends StatefulWidget {
  final EdgeInsetsGeometry? padding;
  final bool enablePullToRefresh;
  final bool enableInfiniteScroll;
  final bool showFloatingActionButton;
  final VoidCallback? onAddPressed;
  final Function(TEntity)? onItemTap;
  final Function(TEntity)? onItemLongPress;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final Widget? emptyStateWidget;
  final Widget? errorStateWidget;
  final Widget? loadingStateWidget;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool enableSwipeActions;
  final bool showSearchBar;
  final String? searchHint;

  const BaseListWidget({
    super.key,
    this.padding,
    this.enablePullToRefresh = true,
    this.enableInfiniteScroll = true,
    this.showFloatingActionButton = true,
    this.onAddPressed,
    this.onItemTap,
    this.onItemLongPress,
    this.separatorBuilder,
    this.emptyStateWidget,
    this.errorStateWidget,
    this.loadingStateWidget,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.enableSwipeActions = true,
    this.showSearchBar = false,
    this.searchHint,
  });

  // Abstract methods for concrete implementations
  Widget buildListItem(BuildContext context, TEntity item, int index);
  Widget? buildItemLeading(TEntity item);
  Widget? buildItemTrailing(TEntity item);
  String getItemTitle(TEntity item);
  String? getItemSubtitle(TEntity item);
  List<Widget>? buildSwipeActions(TEntity item);
  String getEmptyStateMessage();
  IconData getFloatingActionButtonIcon();

  @override
  BaseListWidgetState<TEntity, TBloc> createState();
}

abstract class BaseListWidgetState<TEntity extends IBaseEntity,
        TBloc extends BaseCrudBloc<TEntity>>
    extends State<BaseListWidget<TEntity, TBloc>>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Controllers
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  late final AnimationController _refreshAnimationController;
  late final Animation<double> refreshAnimation;

  // State tracking
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;
  final double _scrollThreshold = 200.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _initializeScrollListener();
    _loadInitialData();
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _searchController = TextEditingController();
  }

  void _initializeAnimations() {
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeScrollListener() {
    if (widget.enableInfiniteScroll) {
      _scrollController.addListener(_onScroll);
    }
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TBloc>().add(LoadEntitiesEvent());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || _hasReachedMax) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (maxScroll - currentScroll <= _scrollThreshold) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    context.read<TBloc>().add(LoadMoreEntitiesEvent());
  }

  Future<void> _onRefresh() async {
    _refreshAnimationController.forward();

    context.read<TBloc>().add(RefreshEntitiesEvent());

    // Wait for refresh to complete
    await Future.delayed(const Duration(milliseconds: 500));

    _refreshAnimationController.reverse();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      context.read<TBloc>().add(ClearSearchEvent());
    } else {
      context.read<TBloc>().add(SearchEntitiesEvent(query: query));
    }
  }

  void _onItemTap(TEntity item) {
    widget.onItemTap?.call(item);
    context.read<TBloc>().add(SelectEntityEvent(entity: item));
  }

  void _onItemLongPress(TEntity item) {
    widget.onItemLongPress?.call(item);
    _showItemActionSheet(item);
  }

  void _showItemActionSheet(TEntity item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildItemActionSheet(item),
    );
  }

  Widget _buildItemActionSheet(TEntity item) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.getItemTitle(item),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(loc.translate('edit')),
            onTap: () {
              Navigator.pop(context);
              _onItemTap(item);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: Text(loc.translate('delete')),
            textColor: theme.colorScheme.error,
            iconColor: theme.colorScheme.error,
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(item);
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('cancel')),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(TEntity item) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('deleteItem')),
        content: Text(
            '${loc.translate('areYouSureYouWantToDelete')} "${widget.getItemTitle(item)}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('cancel')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<TBloc>()
                  .add(DeleteEntityEvent(entityId: item.id.uniqueKey));
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(loc.translate('delete')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Column(
        children: [
          if (widget.showSearchBar) _buildSearchBar(),
          Expanded(child: _buildListView()),
        ],
      ),
      floatingActionButton:
          widget.showFloatingActionButton ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.searchHint ?? '${loc.translate('search')}...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    final loc = AppLocalizations.of(context);
    return BlocConsumer<TBloc, BaseCrudState<TEntity>>(
      listener: (context, state) {
        setState(() {
          _isLoadingMore = false;
          _hasReachedMax = !state.canLoadMore;
        });

        if (state.hasError && state.errorState != null) {
          _showErrorSnackBar(
              state.errorMessage ?? loc.translate('anErrorOccurred'));
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.entities.isEmpty) {
          return _buildLoadingState();
        }

        if (state.hasError && state.entities.isEmpty) {
          return _buildErrorState(
              state.errorMessage ?? loc.translate('anErrorOccurred'));
        }

        if (state.entities.isEmpty) {
          return _buildEmptyState();
        }

        return _buildListContent(state);
      },
    );
  }

  Widget _buildListContent(BaseCrudState<TEntity> state) {
    final entities = state.entities;

    Widget listView = ListView.separated(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.all(16),
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      scrollDirection: widget.scrollDirection,
      itemCount: entities.length + (state.canLoadMore ? 1 : 0),
      separatorBuilder: widget.separatorBuilder ?? _defaultSeparatorBuilder,
      itemBuilder: (context, index) {
        if (index >= entities.length) {
          return _buildLoadMoreIndicator();
        }

        final item = entities[index];
        return _buildListItemWrapper(item, index);
      },
    );

    if (widget.enablePullToRefresh) {
      listView = RefreshIndicator(
        onRefresh: _onRefresh,
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildListItemWrapper(TEntity item, int index) {
    Widget listItem = widget.buildListItem(context, item, index);

    if (widget.enableSwipeActions) {
      final swipeActions = widget.buildSwipeActions(item);
      if (swipeActions != null && swipeActions.isNotEmpty) {
        listItem = Dismissible(
          key: Key(item.id.uniqueKey),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (direction) => _confirmDismiss(item),
          onDismissed: (direction) {
            context
                .read<TBloc>()
                .add(DeleteEntityEvent(entityId: item.id.uniqueKey));
          },
          child: listItem,
        );
      }
    }

    return InkWell(
      onTap: () => _onItemTap(item),
      onLongPress: () => _onItemLongPress(item),
      child: listItem,
    );
  }

  Future<bool?> _confirmDismiss(TEntity item) async {
    final loc = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('confirmDelete')),
        content: Text(
            '${loc.translate('deleteItem')} "${widget.getItemTitle(item)}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(loc.translate('delete')),
          ),
        ],
      ),
    );
  }

  Widget _defaultSeparatorBuilder(BuildContext context, int index) {
    return const Divider(height: 1);
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildLoadingState() {
    return widget.loadingStateWidget ??
        const Center(
          child: CircularProgressIndicator(),
        );
  }

  Widget _buildErrorState(String message) {
    final loc = AppLocalizations.of(context);
    return widget.errorStateWidget ??
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                loc.translate('error'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    context.read<TBloc>().add(RefreshEntitiesEvent()),
                child: Text(loc.translate('retry')),
              ),
            ],
          ),
        );
  }

  Widget _buildEmptyState() {
    final loc = AppLocalizations.of(context);
    return widget.emptyStateWidget ??
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                loc.translate('noItems'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                widget.getEmptyStateMessage(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (widget.showFloatingActionButton) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: widget.onAddPressed,
                  icon: Icon(widget.getFloatingActionButtonIcon()),
                  label: Text(loc.translate('addFirstItem')),
                ),
              ],
            ],
          ),
        );
  }

  Widget? _buildFloatingActionButton() {
    if (widget.onAddPressed == null) return null;

    return FloatingActionButton(
      onPressed: widget.onAddPressed,
      child: Icon(widget.getFloatingActionButtonIcon()),
    );
  }

  void _showErrorSnackBar(String message) {
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.fixed,
        action: SnackBarAction(
          label: loc.translate('dismiss'),
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  // Helper method for building default list tiles
  Widget buildDefaultListTile(TEntity item) {
    final theme = Theme.of(context);

    return ListTile(
      leading: widget.buildItemLeading(item),
      title: Text(
        widget.getItemTitle(item),
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: widget.getItemSubtitle(item) != null
          ? Text(widget.getItemSubtitle(item)!)
          : null,
      trailing: widget.buildItemTrailing(item),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
    );
  }
}
