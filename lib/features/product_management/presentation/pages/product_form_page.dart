import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_entity.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_sync_meta_data.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';
import 'package:rantipay_app/features/product_management/domain/entities/tax_configuration.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_enums.dart';

/// Product create/edit form page
/// Handles both creation and editing of products
class ProductFormPage extends StatefulWidget {
  final ProductEntity? product; // null for create, non-null for edit

  const ProductFormPage({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _notesController = TextEditingController();

  ProductCategory _selectedCategory = ProductCategory.goods;
  ProductType _selectedType = ProductType.physical;
  bool _isService = false;
  bool _isActive = true;
  bool _manageInventory = false;
  bool _allowNegativeStock = false;
  String _unitOfMeasure = 'unit';

  // Tax configuration
  double _ivaRate = 15.0; // Updated to 15%
  String _sriIvaCode = '4'; // Code for 15%
  String _sriProductCode = '';
  bool _isIvaExempt = false;
  double _iceRate = 0.0;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _basePriceController.dispose();
    _salePriceController.dispose();
    _currentStockController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _reorderPointController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadProductData() {
    if (widget.product != null) {
      final product = widget.product!;
      _codeController.text = product.code;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _barcodeController.text = product.barcode ?? '';
      _brandController.text = product.brand ?? '';
      _modelController.text = product.model ?? '';
      _basePriceController.text = product.basePrice.toString();
      _salePriceController.text = product.salePrice.toString();
      _currentStockController.text = product.inventoryConfig.currentStock.toString();
      _minStockController.text = product.inventoryConfig.minStock?.toString() ?? '';
      _maxStockController.text = product.inventoryConfig.maxStock?.toString() ?? '';
      _reorderPointController.text = product.inventoryConfig.reorderPoint?.toString() ?? '';
      _notesController.text = product.notes ?? '';

      _selectedCategory = product.category;
      _selectedType = product.type;
      _isService = product.isService;
      _isActive = product.isActive;
      _manageInventory = product.inventoryConfig.isManaged;
      _allowNegativeStock = product.inventoryConfig.allowNegativeStock;
      _unitOfMeasure = product.inventoryConfig.unitOfMeasure ?? 'unit';

      _ivaRate = product.taxConfig.ivaRate;
      _sriIvaCode = product.taxConfig.sriIvaCode;
      _sriProductCode = product.taxConfig.sriProductCode;
      _isIvaExempt = product.taxConfig.isIvaExempt;
      _iceRate = product.taxConfig.iceRate;
    } else {
      // Generate default code for new product
      _codeController.text = 'PROD${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final product = _buildProductEntity();

      // TODO: Call BLoC to save product
      // if (widget.product == null) {
      //   context.read<ProductBloc>().createProduct(product);
      // } else {
      //   context.read<ProductBloc>().updateProduct(product);
      // }

      if (mounted) {
        Navigator.of(context).pop(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product == null
                  ? 'Product created successfully'
                  : 'Product updated successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  ProductEntity _buildProductEntity() {
    return ProductEntity(
      id: widget.product?.id ?? EntityIdentifier.temp('product_${DateTime.now().millisecondsSinceEpoch}'),
      metadata: widget.product?.metadata ?? EntityMetadata.create(),
      status: widget.product?.status ?? EntityStatus.active(),
      syncMeta: widget.product?.syncMeta ?? SyncMetadata.notSynced(),
      code: _codeController.text,
      name: _nameController.text,
      description: _descriptionController.text,
      barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
      brand: _brandController.text.isEmpty ? null : _brandController.text,
      model: _modelController.text.isEmpty ? null : _modelController.text,
      category: _selectedCategory,
      type: _selectedType,
      productStatus: _isActive ? ProductStatus.active : ProductStatus.inactive,
      basePrice: double.tryParse(_basePriceController.text) ?? 0.0,
      salePrice: double.tryParse(_salePriceController.text) ?? 0.0,
      currency: 'USD',
      taxConfig: TaxConfiguration(
        ivaRate: _ivaRate,
        sriIvaCode: _sriIvaCode,
        sriProductCode: _sriProductCode,
        isIvaExempt: _isIvaExempt,
        iceRate: _iceRate,
        retentionRate: 0.0,
        ivaRetentionRate: 0.0,
        isRetentionExempt: false,
        iceCode: null,
      ),
      priceConfig: PriceConfiguration(),
      inventoryConfig: InventoryConfiguration(
        isManaged: _manageInventory,
        currentStock: int.tryParse(_currentStockController.text) ?? 0,
        minStock: int.tryParse(_minStockController.text),
        maxStock: int.tryParse(_maxStockController.text),
        reorderPoint: int.tryParse(_reorderPointController.text),
        allowNegativeStock: _allowNegativeStock,
        unitOfMeasure: _unitOfMeasure,
      ),
      isActive: _isActive,
      isService: _isService,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      tags: [],
      customFields: {},
      lastSaleDate: widget.product?.lastSaleDate,
      salesCount: widget.product?.salesCount ?? 0,
      totalSalesValue: widget.product?.totalSalesValue ?? 0.0,
      supplierId: widget.product?.supplierId,
      supplierProductCode: widget.product?.supplierProductCode,
      supplierCost: widget.product?.supplierCost,
      weight: widget.product?.weight,
      length: widget.product?.length,
      width: widget.product?.width,
      height: widget.product?.height,
      imageUrl: widget.product?.imageUrl,
      additionalImages: widget.product?.additionalImages ?? [],
      documentationUrl: widget.product?.documentationUrl,
      launchDate: widget.product?.launchDate,
      discontinuationDate: widget.product?.discontinuationDate,
      lastPriceUpdate: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Create Product'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProduct,
              child: const Text('SAVE'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information Section
            _buildSectionTitle(theme, 'Basic Information', Icons.info_outline),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _codeController,
              label: 'Product Code',
              hint: 'e.g., PROD001',
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Product code is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Product Name',
              hint: 'e.g., Laptop Dell Inspiron 15',
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Product name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Product description',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _brandController,
                    label: 'Brand',
                    hint: 'e.g., Dell',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _modelController,
                    label: 'Model',
                    hint: 'e.g., Inspiron 15',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _barcodeController,
              label: 'Barcode',
              hint: 'EAN/UPC',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            // Category & Type Section
            _buildSectionTitle(theme, 'Category & Type', Icons.category),
            const SizedBox(height: 12),
            _buildDropdown<ProductCategory>(
              label: 'Category',
              value: _selectedCategory,
              items: ProductCategory.values,
              itemLabel: (cat) => cat.name,
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown<ProductType>(
              label: 'Product Type',
              value: _selectedType,
              items: ProductType.values,
              itemLabel: (type) => type.name,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _isService = value == ProductType.service;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Is Service'),
              subtitle: const Text('Product is a service, not a physical item'),
              value: _isService,
              onChanged: (value) {
                setState(() => _isService = value);
              },
            ),
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Product is available for sale'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),

            const SizedBox(height: 24),

            // Pricing Section
            _buildSectionTitle(theme, 'Pricing', Icons.attach_money),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _basePriceController,
                    label: 'Base Price',
                    hint: '0.00',
                    required: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixText: '\$ ',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Base price is required';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Invalid price';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _salePriceController,
                    label: 'Sale Price',
                    hint: '0.00',
                    required: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixText: '\$ ',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Sale price is required';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Invalid price';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tax Configuration Section
            _buildSectionTitle(theme, 'Tax Configuration', Icons.receipt_long),
            const SizedBox(height: 12),
            _buildDropdown<double>(
              label: 'IVA Rate',
              value: _ivaRate,
              items: const [0.0, 12.0, 14.0, 15.0],
              itemLabel: (rate) => '${rate.toInt()}%',
              onChanged: (value) {
                setState(() {
                  _ivaRate = value!;
                  // Map rate to SRI code
                  _sriIvaCode = _mapIvaRateToCode(value);
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: TextEditingController(text: _sriProductCode),
              label: 'SRI Product Code',
              hint: 'SRI classification code',
              onChanged: (value) => _sriProductCode = value,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('IVA Exempt'),
              subtitle: const Text('Product is exempt from IVA tax'),
              value: _isIvaExempt,
              onChanged: (value) {
                setState(() => _isIvaExempt = value);
              },
            ),

            const SizedBox(height: 24),

            // Inventory Section
            _buildSectionTitle(theme, 'Inventory', Icons.inventory_2),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Manage Inventory'),
              subtitle: const Text('Track stock levels for this product'),
              value: _manageInventory,
              onChanged: (value) {
                setState(() => _manageInventory = value);
              },
            ),
            if (_manageInventory) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _currentStockController,
                label: 'Current Stock',
                hint: '0',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_manageInventory && (value == null || value.isEmpty)) {
                    return 'Stock quantity is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _minStockController,
                      label: 'Min Stock',
                      hint: 'Optional',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _maxStockController,
                      label: 'Max Stock',
                      hint: 'Optional',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _reorderPointController,
                label: 'Reorder Point',
                hint: 'Optional',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Unit of Measure',
                value: _unitOfMeasure,
                items: const ['unit', 'kg', 'lb', 'liter', 'gallon', 'meter', 'piece'],
                itemLabel: (unit) => unit,
                onChanged: (value) {
                  setState(() => _unitOfMeasure = value!);
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Allow Negative Stock'),
                subtitle: const Text('Allow sales when stock is below zero'),
                value: _allowNegativeStock,
                onChanged: (value) {
                  setState(() => _allowNegativeStock = value);
                },
              ),
            ],

            const SizedBox(height: 24),

            // Notes Section
            _buildSectionTitle(theme, 'Additional Notes', Icons.notes),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _notesController,
              label: 'Internal Notes',
              hint: 'Add any additional notes',
              maxLines: 3,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? prefixText,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixText: prefixText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  String _mapIvaRateToCode(double rate) {
    switch (rate.toInt()) {
      case 0:
        return '0';
      case 12:
        return '2';
      case 14:
        return '3';
      case 15:
        return '4';
      default:
        return '4'; // Default to 15%
    }
  }
}
