import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rantipay_app/features/product_management/application/blocs/product_bloc.dart';
import 'package:rantipay_app/features/product_management/application/blocs/product_state.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_chips_widget.dart';
import '../widgets/product_list_skeleton.dart';

/// Main product list page with search, filters, and pagination
class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedCategory;
  String? _selectedStatus;
  bool _showOnlyLowStock = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    context.read<ProductBloc>().loadProducts();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9) {
        // Load more when scrolled to 90%
        // TODO: Implement pagination
      }
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _loadProducts();
    } else {
      context.read<ProductBloc>().searchProducts(query);
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      if (filter == _selectedCategory) {
        _selectedCategory = null;
      } else if (filter == _selectedStatus) {
        _selectedStatus = null;
      } else if (filter == 'low_stock') {
        _showOnlyLowStock = !_showOnlyLowStock;
      } else if (['active', 'inactive'].contains(filter)) {
        _selectedStatus = filter == _selectedStatus ? null : filter;
      } else {
        _selectedCategory = filter == _selectedCategory ? null : filter;
      }
    });

    // Apply filters
    _applyFilters();
  }

  void _applyFilters() {
    if (_showOnlyLowStock) {
      context.read<ProductBloc>().getLowStockProducts();
    } else if (_selectedCategory != null) {
      context.read<ProductBloc>().getProductsByCategory(_selectedCategory!);
    } else {
      _loadProducts();
    }
  }

  void _navigateToCreate() {
    // TODO: Navigate to create page
    Navigator.of(context).pushNamed('/products/create');
  }

  void _navigateToEdit(ProductEntity product) {
    // TODO: Navigate to edit page
    Navigator.of(context).pushNamed(
      '/products/${product.id.uniqueKey}/edit',
      arguments: product,
    );
  }

  void _navigateToDetail(ProductEntity product) {
    // TODO: Navigate to detail page
    Navigator.of(context).pushNamed(
      '/products/${product.id.uniqueKey}',
      arguments: product,
    );
  }

  void _confirmDelete(ProductEntity product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted ${product.name}')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _duplicateProduct(ProductEntity product) {
    // TODO: Implement duplicate
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicating ${product.name}...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Filter Chips
          _buildFilterChips(),

          // Product List
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const Center(
                    child: Text('Pull to refresh'),
                  ),
                  loading: (query) => const ProductListSkeleton(),
                  success: (products, selectedProduct) {
                    if (products.isEmpty) {
                      return EmptyStateWidget(
                        title: 'No Products Found',
                        message: _searchController.text.isNotEmpty
                            ? 'Try adjusting your search or filters'
                            : 'Create your first product to get started',
                        actionLabel: 'Create Product',
                        onActionPressed: _navigateToCreate,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _loadProducts(),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: products.length,
                        padding: const EdgeInsets.only(bottom: 80),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCardWidget(
                            product: product,
                            onTap: () => _navigateToDetail(product),
                            onEdit: () => _navigateToEdit(product),
                            onDelete: () => _confirmDelete(product),
                            onDuplicate: () => _duplicateProduct(product),
                          );
                        },
                      ),
                    );
                  },
                  failure: (failure) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load products',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          failure.message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _loadProducts,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                  search: (query, products, selectedProduct) {
                    if (products.isEmpty) {
                      return EmptyStateWidget(
                        title: 'No Results',
                        message: 'No products found for "$query"',
                        icon: Icons.search_off,
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: products.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCardWidget(
                          product: product,
                          onTap: () => _navigateToDetail(product),
                          onEdit: () => _navigateToEdit(product),
                          onDelete: () => _confirmDelete(product),
                          onDuplicate: () => _duplicateProduct(product),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.add),
        label: const Text('New Product'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
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
        ),
        onChanged: (query) {
          // Debounce search
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_searchController.text == query) {
              _onSearchChanged(query);
            }
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      FilterChipData(
        label: 'Electronics',
        value: 'electronics',
        isSelected: _selectedCategory == 'electronics',
        icon: Icons.devices,
      ),
      FilterChipData(
        label: 'Services',
        value: 'services',
        isSelected: _selectedCategory == 'services',
        icon: Icons.miscellaneous_services,
      ),
      FilterChipData(
        label: 'Food',
        value: 'food',
        isSelected: _selectedCategory == 'food',
        icon: Icons.restaurant,
      ),
      FilterChipData(
        label: 'Active',
        value: 'active',
        isSelected: _selectedStatus == 'active',
        icon: Icons.check_circle,
      ),
      FilterChipData(
        label: 'Inactive',
        value: 'inactive',
        isSelected: _selectedStatus == 'inactive',
        icon: Icons.block,
      ),
      FilterChipData(
        label: 'Low Stock',
        value: 'low_stock',
        isSelected: _showOnlyLowStock,
        icon: Icons.warning_amber,
      ),
    ];

    return FilterChipsWidget(
      filters: filters,
      onFilterSelected: _onFilterChanged,
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Name (A-Z)'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sort
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Price (Low to High)'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sort
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date Created (Newest)'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sort
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Stock Level'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sort
              },
            ),
          ],
        ),
      ),
    );
  }
}
