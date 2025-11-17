import 'package:flutter/material.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';

/// Product detail page showing comprehensive product information
class ProductDetailPage extends StatelessWidget {
  final ProductEntity product;

  const ProductDetailPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/products/${product.id.uniqueKey}/edit',
                arguments: product,
              );
            },
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(context),
            tooltip: 'More',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            _buildProductImage(context),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Code
                  _buildHeader(theme),
                  const SizedBox(height: 16),

                  // Status Badges
                  _buildStatusBadges(theme),
                  const SizedBox(height: 24),

                  // Basic Information
                  _buildSection(
                    theme,
                    'Basic Information',
                    Icons.info_outline,
                    [
                      _buildInfoRow(theme, 'Code', product.code),
                      _buildInfoRow(theme, 'Category', product.category.name),
                      _buildInfoRow(theme, 'Type', product.type.name),
                      if (product.brand != null)
                        _buildInfoRow(theme, 'Brand', product.brand!),
                      if (product.model != null)
                        _buildInfoRow(theme, 'Model', product.model!),
                      if (product.barcode != null)
                        _buildInfoRow(theme, 'Barcode', product.barcode!),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pricing
                  _buildSection(
                    theme,
                    'Pricing',
                    Icons.attach_money,
                    [
                      _buildInfoRow(
                        theme,
                        'Base Price',
                        '\$${product.basePrice.toStringAsFixed(2)}',
                      ),
                      _buildInfoRow(
                        theme,
                        'Sale Price',
                        '\$${product.salePrice.toStringAsFixed(2)}',
                        highlight: true,
                      ),
                      _buildInfoRow(
                        theme,
                        'Currency',
                        product.currency,
                      ),
                      _buildInfoRow(
                        theme,
                        'Price with Taxes',
                        '\$${product.getPriceWithTaxes().toStringAsFixed(2)}',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tax Configuration
                  _buildSection(
                    theme,
                    'Tax Configuration',
                    Icons.receipt_long,
                    [
                      _buildInfoRow(
                        theme,
                        'IVA Rate',
                        '${product.taxConfig.ivaRate}%',
                      ),
                      _buildInfoRow(
                        theme,
                        'SRI IVA Code',
                        product.taxConfig.sriIvaCode,
                      ),
                      _buildInfoRow(
                        theme,
                        'SRI Product Code',
                        product.taxConfig.sriProductCode,
                      ),
                      if (product.taxConfig.isIvaExempt)
                        _buildInfoRow(
                          theme,
                          'IVA Exempt',
                          'Yes',
                          highlight: true,
                        ),
                      if (product.taxConfig.iceRate > 0)
                        _buildInfoRow(
                          theme,
                          'ICE Rate',
                          '${product.taxConfig.iceRate}%',
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Inventory
                  if (product.inventoryConfig.isManaged)
                    _buildSection(
                      theme,
                      'Inventory',
                      Icons.inventory_2,
                      [
                        _buildInfoRow(
                          theme,
                          'Current Stock',
                          '${product.inventoryConfig.currentStock} ${product.inventoryConfig.unitOfMeasure ?? "units"}',
                          highlight: true,
                        ),
                        if (product.inventoryConfig.minStock != null)
                          _buildInfoRow(
                            theme,
                            'Min Stock',
                            '${product.inventoryConfig.minStock}',
                          ),
                        if (product.inventoryConfig.maxStock != null)
                          _buildInfoRow(
                            theme,
                            'Max Stock',
                            '${product.inventoryConfig.maxStock}',
                          ),
                        if (product.inventoryConfig.reorderPoint != null)
                          _buildInfoRow(
                            theme,
                            'Reorder Point',
                            '${product.inventoryConfig.reorderPoint}',
                          ),
                        _buildInfoRow(
                          theme,
                          'Allow Negative Stock',
                          product.inventoryConfig.allowNegativeStock ? 'Yes' : 'No',
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Sales Statistics
                  _buildSection(
                    theme,
                    'Sales Statistics',
                    Icons.analytics,
                    [
                      _buildInfoRow(
                        theme,
                        'Total Sales',
                        '${product.salesCount}',
                      ),
                      _buildInfoRow(
                        theme,
                        'Total Revenue',
                        '\$${product.totalSalesValue.toStringAsFixed(2)}',
                      ),
                      if (product.lastSaleDate != null)
                        _buildInfoRow(
                          theme,
                          'Last Sale',
                          _formatDate(product.lastSaleDate!),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Dimensions (if applicable)
                  if (product.weight != null ||
                      product.length != null ||
                      product.width != null ||
                      product.height != null)
                    _buildSection(
                      theme,
                      'Dimensions & Weight',
                      Icons.straighten,
                      [
                        if (product.weight != null)
                          _buildInfoRow(theme, 'Weight', '${product.weight} kg'),
                        if (product.length != null)
                          _buildInfoRow(theme, 'Length', '${product.length} cm'),
                        if (product.width != null)
                          _buildInfoRow(theme, 'Width', '${product.width} cm'),
                        if (product.height != null)
                          _buildInfoRow(theme, 'Height', '${product.height} cm'),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Description
                  if (product.description.isNotEmpty)
                    _buildSection(
                      theme,
                      'Description',
                      Icons.description,
                      [
                        Text(
                          product.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Additional Info
                  _buildSection(
                    theme,
                    'Additional Information',
                    Icons.more_horiz,
                    [
                      _buildInfoRow(
                        theme,
                        'Created',
                        _formatDate(product.metadata.createdAt),
                      ),
                      _buildInfoRow(
                        theme,
                        'Last Updated',
                        _formatDate(product.metadata.modifiedAt),
                      ),
                      _buildInfoRow(
                        theme,
                        'Version',
                        '${product.metadata.version}',
                      ),
                      if (product.notes != null && product.notes!.isNotEmpty)
                        _buildInfoRow(theme, 'Notes', product.notes!),
                    ],
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 250,
      color: theme.colorScheme.surfaceVariant,
      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
          ? Image.network(
              product.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholderImage(theme),
            )
          : _buildPlaceholderImage(theme),
    );
  }

  Widget _buildPlaceholderImage(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 120,
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.code,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadges(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(
          theme,
          product.isActive ? 'Active' : 'Inactive',
          product.isActive ? Colors.green : Colors.grey,
        ),
        if (product.isService)
          _buildBadge(theme, 'Service', Colors.blue),
        if (product.inventoryConfig.isManaged)
          _buildBadge(
            theme,
            product.stockStatus.name,
            product.stockStatus == StockStatus.inStock
                ? Colors.green
                : product.stockStatus == StockStatus.lowStock
                    ? Colors.orange
                    : Colors.red,
          ),
        if (product.taxConfig.isIvaExempt)
          _buildBadge(theme, 'Tax Exempt', Colors.purple),
      ],
    );
  }

  Widget _buildBadge(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                color: highlight ? theme.colorScheme.primary : null,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement duplicate
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement print
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement delete
              },
            ),
          ],
        ),
      ),
    );
  }
}
