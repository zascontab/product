import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rantipay_app/features/product_management/application/blocs/product_bloc.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';
import 'package:rantipay_app/features/product_management/presentation/widgets/product_search_widget.dart';


/// Page for selecting products in invoice creation
/// Demonstrates the product search and selection functionality
class ProductSelectionPage extends StatelessWidget {
  static const String routeName = '/product-selection';

  const ProductSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<ProductBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seleccionar Producto'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: ProductSelectionView(),
        ),
      ),
    );
  }
}

/// Main view for product selection
class ProductSelectionView extends StatefulWidget {
  const ProductSelectionView({super.key});

  @override
  State<ProductSelectionView> createState() => _ProductSelectionViewState();
}

class _ProductSelectionViewState extends State<ProductSelectionView> {
  ProductEntity? selectedProduct;

  void _onProductSelected(ProductEntity product) {
    setState(() {
      selectedProduct = product;
    });

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Producto Seleccionado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Has seleccionado:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.getDisplayName(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Código: ${product.code}'),
                    Text('Categoría: ${product.category.description}'),
                    Text('Precio: \$${product.salePrice.toStringAsFixed(2)}'),
                    if (product.inventoryConfig.isManaged)
                      Text('Stock: ${product.inventoryConfig.currentStock}'),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar buscando'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(product); // Return selected product
            },
            child: const Text('Confirmar selección'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instructions
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seleccionar Producto',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Busca por nombre, código o código de barras. Si no encuentras el producto, puedes crear uno nuevo.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Search and selection
        Expanded(
          child: ProductSearchWidget(
            onProductSelected: _onProductSelected,
            hintText: 'Buscar productos por nombre, código o barcode...',
            showCreateButton: true,
          ),
        ),
        
        // Selected product display
        if (selectedProduct != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Último producto seleccionado:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedProduct!.getDisplayName(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  Text(
                    'Precio: \$${selectedProduct!.salePrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
