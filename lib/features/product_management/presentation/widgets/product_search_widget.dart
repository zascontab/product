import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rantipay_app/features/product_management/application/blocs/product_bloc.dart';
import 'package:rantipay_app/features/product_management/application/blocs/product_state.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';

/// Widget for searching and selecting products
/// Used in invoice creation and product management
class ProductSearchWidget extends StatefulWidget {
  final void Function(ProductEntity product)? onProductSelected;
  final String? hintText;
  final bool showCreateButton;

  const ProductSearchWidget({
    super.key,
    this.onProductSelected,
    this.hintText,
    this.showCreateButton = true,
  });

  @override
  State<ProductSearchWidget> createState() => _ProductSearchWidgetState();
}

class _ProductSearchWidgetState extends State<ProductSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load initial products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Simple debouncing with setState
    if (query.trim().isEmpty) {
      context.read<ProductBloc>().loadProducts();
    } else {
      context.read<ProductBloc>().searchProducts(query);
    }
  }

  void _onProductTap(ProductEntity product) {
    context.read<ProductBloc>().selectProduct(product);
    widget.onProductSelected?.call(product);
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Buscar productos...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<ProductBloc>().loadProducts();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: _onSearchChanged,
        ),
        
        const SizedBox(height: 8),
        
        // Create new product button
        if (widget.showCreateButton)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Crear nuevo producto'),
              onPressed: () {
                // TODO: Navigate to product creation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidad de creación en desarrollo'),
                  ),
                );
              },
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Products list
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state.isLoading && state.products.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              if (state.error != null && state.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar productos',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        onPressed: () {
                          context.read<ProductBloc>().loadProducts();
                        },
                      ),
                    ],
                  ),
                );
              }
              
              if (state.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay productos',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crea tu primer producto para comenzar',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return ProductListTile(
                    product: product,
                    onTap: () => _onProductTap(product),
                    isSelected: state.selectedProduct?.id.uniqueKey == product.id.uniqueKey,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// List tile for displaying product information
class ProductListTile extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final bool isSelected;

  const ProductListTile({
    super.key,
    required this.product,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer 
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            product.name.isNotEmpty ? product.name[0].toUpperCase() : 'P',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          product.getDisplayName(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${product.code}'),
            Text('Categoría: ${product.category.description}'),
            if (product.inventoryConfig.isManaged)
              Text('Stock: ${product.inventoryConfig.currentStock}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${product.salePrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (!product.isAvailableForSale)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'No disponible',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }
}
