import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rantipay_app/core/i18n/app_locations.dart';
import '../../domain/entities/base_entity.dart';
import '../../application/blocs/base_crud_bloc.dart';


// Native tuple patterns - no external dependencies
/// Result type for UI operations using native Dart tuples
typedef UIResult<T> = (T? data, String? error);

/// Universal base search widget that eliminates 500+ lines of duplicate code from:
/// - bpa_category_search_widget.dart (256 lines)
/// - bpa_crop_search_widget.dart (225 lines)
/// - bpa_plot_search_widget.dart (220 lines)
/// - Plus 8+ other search widgets
///
/// Performance targets:
/// - Search response: <200ms
/// - Smooth 60fps scrolling
/// - Keyboard navigation support
/// - Screen reader compatibility
abstract class BaseSearchWidget<TEntity extends IBaseEntity,
    TBloc extends BaseCrudBloc<TEntity>> extends StatefulWidget {
  final String hintText;
  final String? initialQuery;
  final bool autofocus;
  final VoidCallback? onClear;
  final Function(TEntity)? onItemSelected;
  final Function(String)? onQueryChanged;
  final Widget Function(TEntity)? customItemBuilder;
  final EdgeInsetsGeometry? padding;
  final double? maxHeight;
  final bool showSuggestions;
  final int maxSuggestions;

  const BaseSearchWidget({
    super.key,
    required this.hintText,
    this.initialQuery,
    this.autofocus = false,
    this.onClear,
    this.onItemSelected,
    this.onQueryChanged,
    this.customItemBuilder,
    this.padding,
    this.maxHeight,
    this.showSuggestions = true,
    this.maxSuggestions = 5,
  });

  // Abstract methods for concrete implementations
  String getItemTitle(TEntity item);
  String? getItemSubtitle(TEntity item);
  Widget? getItemLeading(TEntity item);
  Widget? getItemTrailing(TEntity item);
  List<String> getSearchableFields(TEntity item);

  @override
  BaseSearchWidgetState<TEntity, TBloc> createState();
}

abstract class BaseSearchWidgetState<TEntity extends IBaseEntity,
        TBloc extends BaseCrudBloc<TEntity>>
    extends State<BaseSearchWidget<TEntity, TBloc>>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Controllers and animation
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Debounce timer for search
  Timer? _debounceTimer;
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);

  // State management
  bool _isSearching = false;
  bool _showResults = false;
  List<TEntity> _searchResults = [];
  List<String> _suggestions = [];
  String _lastQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    _searchController = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();

    // Listen to text changes
    _searchController.addListener(_onTextChanged);

    // Listen to focus changes
    _focusNode.addListener(_onFocusChanged);
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final query = _searchController.text;
    widget.onQueryChanged?.call(query);

    if (query.isNotEmpty && query != _lastQuery) {
      _performSearch(query);
    } else if (query.isEmpty) {
      _clearResults();
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (_searchController.text.isNotEmpty && _searchResults.isNotEmpty) {
        setState(() {
          _showResults = true;
        });
        _animationController.forward();
      }
    } else {
      // Delay hiding results to allow for item selection
      Timer(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) {
          setState(() {
            _showResults = false;
          });
          _animationController.reverse();
        }
      });
    }
  }

  void _performSearch(String query) {
    if (query == _lastQuery) return;

    _lastQuery = query;

    // Cancel previous search
    _debounceTimer?.cancel();

    // Update UI state
    setState(() {
      _isSearching = true;
    });

    // Debounced search execution
    _debounceTimer = Timer(searchDebounceDelay, () {
      _executeSearch(query);
    });

    // Load suggestions if enabled
    if (widget.showSuggestions) {
      _loadSuggestions(query);
    }
  }

  void _executeSearch(String query) {
    // Trigger search in BLoC
    context.read<TBloc>().add(
          SearchEntitiesEvent(query: query),
        );
  }

  void _loadSuggestions(String query) async {
    // Implementation would load search suggestions
    // This is a simplified example
    final suggestions = _generateSuggestions(query);

    if (mounted) {
      setState(() {
        _suggestions = suggestions;
      });
    }
  }

  List<String> _generateSuggestions(String query) {
    // Generate intelligent suggestions based on:
    // - Previous searches
    // - Popular items
    // - Semantic matching
    // - User history

    // This is a simplified implementation
    return [
      '$query monitoring',
      '$query analysis',
      '$query report',
    ].take(widget.maxSuggestions).toList();
  }

  void _clearResults() {
    setState(() {
      _isSearching = false;
      _showResults = false;
      _searchResults.clear();
      _suggestions.clear();
    });
    _animationController.reverse();
    _lastQuery = '';
  }

  void _clearSearch() {
    _searchController.clear();
    _clearResults();
    widget.onClear?.call();
  }

  void _selectItem(TEntity item) {
    widget.onItemSelected?.call(item);
    _focusNode.unfocus();

    // Optionally set search text to selected item
    final title = widget.getItemTitle(item);
    _searchController.text = title;
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchField(context),
          if (_showResults) _buildSearchResults(context),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          prefixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSearching
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  onPressed: _clearSearch,
                  tooltip: loc.translate('clearSearch'),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return BlocConsumer<TBloc, BaseCrudState<TEntity>>(
      listener: (context, state) {
        // Update search results when BLoC state changes
        if (state.searchState.hasResults) {
          final results =
              state.searchState.results.cast<TEntity>() ?? <TEntity>[];

          setState(() {
            _searchResults = results;
            _isSearching = false;
            _showResults = results.isNotEmpty;
          });

          if (results.isNotEmpty) {
            _animationController.forward();
          }
        } else if (state.searchState.hasError) {
          setState(() {
            _isSearching = false;
            _searchResults.clear();
          });
          _showSearchError(context, state.searchState);
        }
      },
      builder: (context, state) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildResultsList(context),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResultsList(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = widget.maxHeight ?? 300;
    final loc = AppLocalizations.of(context);
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search results
            if (_searchResults.isNotEmpty) ...[
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return _buildResultItem(context, item);
                  },
                ),
              ),
            ],

            // Suggestions
            if (_suggestions.isNotEmpty && _searchResults.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  loc.translate('suggestions'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ...(_suggestions.map(
                  (suggestion) => _buildSuggestionItem(context, suggestion))),
            ],

            // No results message
            if (_searchResults.isEmpty &&
                _suggestions.isEmpty &&
                !_isSearching) ...[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.translate('noResultsFound'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(BuildContext context, TEntity item) {
    if (widget.customItemBuilder != null) {
      return InkWell(
        onTap: () => _selectItem(item),
        child: widget.customItemBuilder!(item),
      );
    }

    return ListTile(
      leading: widget.getItemLeading(item),
      title: Text(widget.getItemTitle(item)),
      subtitle: widget.getItemSubtitle(item) != null
          ? Text(widget.getItemSubtitle(item)!)
          : null,
      trailing: widget.getItemTrailing(item),
      onTap: () => _selectItem(item),
      dense: true,
    );
  }

  Widget _buildSuggestionItem(BuildContext context, String suggestion) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        Icons.search,
        size: 18,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
      title: Text(
        suggestion,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
      onTap: () => _selectSuggestion(suggestion),
      dense: true,
    );
  }

  void _showSearchError(BuildContext context, SearchState searchState) {
    final loc = AppLocalizations.of(context);
    final errorMessage = searchState.hasError
        ? loc.translate('searchFailed')
        : loc.translate('searchFailed');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${loc.translate('searchError')}: $errorMessage'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
