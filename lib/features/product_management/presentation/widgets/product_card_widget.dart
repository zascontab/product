import 'package:flutter/material.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';

/// Reusable product card widget
/// Displays product information in a card format with actions
class ProductCardWidget extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const ProductCardWidget({
    Key? key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              _buildProductImage(context),
              const SizedBox(width: 16),

              // Product Info
              Expanded(
                child: _buildProductInfo(context, theme),
              ),

              // Actions Menu
              _buildActionsMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 80,
        color: theme.colorScheme.surfaceVariant,
        child: product.imageUrl != null && product.imageUrl!.isNotEmpty
            ? Image.network(
                product.imageUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderIcon(theme),
              )
            : _buildPlaceholderIcon(theme),
      ),
    );
  }

  Widget _buildPlaceholderIcon(ThemeData theme) {
    return Icon(
      Icons.inventory_2_outlined,
      size: 40,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  Widget _buildProductInfo(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Text(
          product.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Product Code
        Text(
          product.code,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),

        // Price and Stock Row
        Row(
          children: [
            // Price
            Text(
              '\$${product.salePrice.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),

            // Stock Indicator
            if (product.inventoryConfig.isManaged)
              _buildStockIndicator(context, theme),
          ],
        ),

        const SizedBox(height: 8),

        // Status Chips
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            if (!product.isActive)
              _buildStatusChip(
                'Inactive',
                Colors.grey,
                theme,
              ),
            if (product.inventoryConfig.isManaged &&
                product.inventoryConfig.currentStock <= 0)
              _buildStatusChip(
                'Out of Stock',
                Colors.red,
                theme,
              ),
            if (product.taxConfig.isIvaExempt)
              _buildStatusChip(
                'Tax Exempt',
                Colors.blue,
                theme,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockIndicator(BuildContext context, ThemeData theme) {
    final stock = product.inventoryConfig.currentStock;
    final minStock = product.inventoryConfig.minStock ?? 0;
    final isLowStock = stock <= minStock && stock > 0;
    final isOutOfStock = stock <= 0;

    Color statusColor;
    IconData icon;
    String text;

    if (isOutOfStock) {
      statusColor = Colors.red;
      icon = Icons.error_outline;
      text = 'Out of Stock';
    } else if (isLowStock) {
      statusColor = Colors.orange;
      icon = Icons.warning_amber_outlined;
      text = 'Low: $stock';
    } else {
      statusColor = Colors.green;
      icon = Icons.check_circle_outline;
      text = 'Stock: $stock';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: statusColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'duplicate':
            onDuplicate?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 12),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.content_copy_outlined, size: 20),
              SizedBox(width: 12),
              Text('Duplicate'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
