import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_entity.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_sync_meta_data.dart';

import 'product_enums.dart';
import 'tax_configuration.dart';

part 'product_entity.freezed.dart';
part 'product_entity.g.dart';

/// Entidad principal de producto para facturación electrónica
/// Sigue los patrones establecidos en RantiPay BaseEntity
@freezed
class ProductEntity with _$ProductEntity {
  const factory ProductEntity({
    // === IBaseEntity Implementation ===
    required EntityIdentifier id,
    required EntityMetadata metadata,
    required EntityStatus status,
    required SyncMetadata syncMeta,
    
    // === Información Básica ===
    /// Código interno único del producto
    required String code,
    
    /// Nombre comercial del producto
    required String name,
    
    /// Descripción detallada
    @Default('') String description,
    
    /// Código de barras (opcional)
    String? barcode,
    
    /// Marca del producto
    String? brand,
    
    /// Modelo del producto
    String? model,
    
    /// Categoría del producto
    @Default(ProductCategory.goods) ProductCategory category,
    
    /// Tipo de producto
    @Default(ProductType.physical) ProductType type,
    
    /// Estado del producto
    @Default(ProductStatus.active) ProductStatus productStatus,
    
    // === Información Fiscal (SRI) ===
    /// Configuración de impuestos
    required TaxConfiguration taxConfig,
    
    /// Código SRI oficial del producto
    String? sriProductCode,
    
    // === Precios ===
    /// Precio base sin impuestos
    required double basePrice,
    
    /// Precio de venta final (puede incluir impuestos)
    required double salePrice,
    
    /// Moneda del precio
    @Default('USD') String currency,
    
    /// Configuración de precios
    required PriceConfiguration priceConfig,
    
    // === Inventario ===
    /// Configuración de inventario
    required InventoryConfiguration inventoryConfig,
    
    // === Estado y Configuración ===
    /// Producto activo para ventas
    @Default(true) bool isActive,
    
    /// Es un servicio (no producto físico)
    @Default(false) bool isService,
    
    /// Fecha de última venta
    DateTime? lastSaleDate,
    
    /// Contador total de ventas
    @Default(0) int salesCount,
    
    /// Valor total vendido
    @Default(0.0) double totalSalesValue,
    
    // === Información Adicional ===
    /// Notas internas del producto
    String? notes,
    
    /// Etiquetas para búsqueda y categorización
    @Default([]) List<String> tags,
    
    /// Campos personalizados adicionales
    @Default({}) Map<String, dynamic> customFields,
    
    // === Información de Proveedor ===
    /// ID del proveedor principal
    String? supplierId,
    
    /// Código del producto del proveedor
    String? supplierProductCode,
    
    /// Costo de compra al proveedor
    double? supplierCost,
    
    // === Dimensiones y Peso (para productos físicos) ===
    /// Peso en kilogramos
    double? weight,
    
    /// Largo en centímetros
    double? length,
    
    /// Ancho en centímetros
    double? width,
    
    /// Alto en centímetros
    double? height,
    
    // === URLs e Imágenes ===
    /// URL de imagen principal
    String? imageUrl,
    
    /// URLs de imágenes adicionales
    @Default([]) List<String> additionalImages,
    
    /// URL de ficha técnica o documentación
    String? documentationUrl,
    
    // === Fechas Importantes ===
    /// Fecha de lanzamiento del producto
    DateTime? launchDate,
    
    /// Fecha de descontinuación
    DateTime? discontinuationDate,
    
    /// Fecha de última actualización de precio
    DateTime? lastPriceUpdate,
  }) = _ProductEntity;

  factory ProductEntity.fromJson(Map<String, dynamic> json) =>
      _$ProductEntityFromJson(json);
  
  /// Factorías para crear productos típicos
  factory ProductEntity.createService({
    required String code,
    required String name,
    required double price,
    String description = '',
    TaxConfiguration? taxConfig,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return ProductEntity(
      id: EntityIdentifier.temp('product_service_$now'),
      metadata: EntityMetadata.create(),
      status: EntityStatus.active(),
      syncMeta: SyncMetadata.notSynced(),
      code: code,
      name: name,
      description: description,
      category: ProductCategory.services,
      type: ProductType.service,
      isService: true,
      basePrice: price,
      salePrice: price,
      taxConfig: taxConfig ?? TaxConfiguration(
        sriProductCode: 'SRV001',
        sriIvaCode: '4', // IVA 15%
      ),
      priceConfig: PriceConfiguration(),
      inventoryConfig: InventoryConfiguration(isManaged: false),
    );
  }
  
  factory ProductEntity.createPhysicalProduct({
    required String code,
    required String name,
    required double price,
    String description = '',
    int initialStock = 0,
    TaxConfiguration? taxConfig,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return ProductEntity(
      id: EntityIdentifier.temp('product_physical_$now'),
      metadata: EntityMetadata.create(),
      status: EntityStatus.active(),
      syncMeta: SyncMetadata.notSynced(),
      code: code,
      name: name,
      description: description,
      category: ProductCategory.goods,
      type: ProductType.physical,
      isService: false,
      basePrice: price,
      salePrice: price,
      taxConfig: taxConfig ?? TaxConfiguration(
        sriProductCode: 'PROD001',
        sriIvaCode: '4', // IVA 15%
      ),
      priceConfig: PriceConfiguration(),
      inventoryConfig: InventoryConfiguration(
        currentStock: initialStock,
        isManaged: true,
      ),
    );
  }
}

/// Extensiones para funcionalidades del producto
extension ProductEntityExtensions on ProductEntity {
  /// Genera un código único si no existe
  String get uniqueKey => id.uniqueKey;
  
  /// Obtiene el nombre para mostrar en la UI
  String get displayName {
    if (brand != null && brand!.isNotEmpty) {
      return '$brand $name';
    }
    return name;
  }
  
  /// Obtiene el precio con impuestos
  double getPriceWithTaxes() {
    return taxConfig.calculateTotalWithTaxes(basePrice);
  }
  
  /// Obtiene el precio sin impuestos
  double getPriceWithoutTaxes() {
    return taxConfig.calculateBaseFromTotal(salePrice);
  }
  
  /// Verifica si el producto está disponible para venta
  bool get isAvailableForSale {
    if (!isActive || productStatus != ProductStatus.active) return false;
    if (inventoryConfig.isManaged && inventoryConfig.currentStock <= 0) {
      return inventoryConfig.allowNegativeStock;
    }
    return true;
  }
  
  /// Obtiene el estado del stock
  StockStatus get stockStatus {
    if (!inventoryConfig.isManaged) return StockStatus.notManaged;
    
    final stock = inventoryConfig.currentStock;
    final minStock = inventoryConfig.minStock;
    
    if (stock <= 0) return StockStatus.outOfStock;
    if (minStock != null && stock <= minStock) return StockStatus.lowStock;
    return StockStatus.inStock;
  }
  
  /// Valida si se puede vender una cantidad específica
  bool canSell(int quantity) {
    if (!isAvailableForSale) return false;
    if (!inventoryConfig.isManaged) return true;
    
    final availableStock = inventoryConfig.currentStock;
    if (availableStock >= quantity) return true;
    
    return inventoryConfig.allowNegativeStock;
  }
  
  /// Calcula el precio para una cantidad específica
  double getPriceForQuantity(int quantity) {
    return priceConfig.getPriceForQuantity(salePrice, quantity);
  }
  
  /// Aplica descuento si está permitido
  double applyDiscount(double discountPercent) {
    if (!priceConfig.allowDiscount) return salePrice;
    if (discountPercent > priceConfig.maxDiscountPercent) {
      discountPercent = priceConfig.maxDiscountPercent;
    }
    
    final discountedPrice = salePrice * (1 - discountPercent / 100);
    return priceConfig.applyRounding(discountedPrice);
  }
  
  /// Verifica si necesita reposición de stock
  bool get needsRestock {
    if (!inventoryConfig.isManaged) return false;
    
    final reorderPoint = inventoryConfig.reorderPoint;
    if (reorderPoint != null) {
      return inventoryConfig.currentStock <= reorderPoint;
    }
    
    final minStock = inventoryConfig.minStock;
    if (minStock != null) {
      return inventoryConfig.currentStock <= minStock;
    }
    
    return inventoryConfig.currentStock <= 0;
  }
  
  /// Genera etiquetas automáticas para búsqueda
  List<String> generateSearchTags() {
    final autoTags = <String>[];
    
    // Agregar nombre dividido en palabras
    autoTags.addAll(name.toLowerCase().split(' '));
    
    // Agregar marca si existe
    if (brand != null && brand!.isNotEmpty) {
      autoTags.add(brand!.toLowerCase());
    }
    
    // Agregar modelo si existe
    if (model != null && model!.isNotEmpty) {
      autoTags.add(model!.toLowerCase());
    }
    
    // Agregar categoría
    autoTags.add(category.code);
    
    // Agregar tipo
    autoTags.add(type.code);
    
    // Agregar código
    autoTags.add(code.toLowerCase());
    
    // Agregar código de barras si existe
    if (barcode != null && barcode!.isNotEmpty) {
      autoTags.add(barcode!);
    }
    
    // Combinar con tags personalizados
    autoTags.addAll(tags.map((tag) => tag.toLowerCase()));
    
    // Remover duplicados y vacíos
    return autoTags.where((tag) => tag.isNotEmpty).toSet().toList();
  }
  
  /// Valida la integridad del producto
  List<String> validate() {
    final errors = <String>[];
    
    if (code.trim().isEmpty) {
      errors.add('El código del producto es obligatorio');
    }
    
    if (name.trim().isEmpty) {
      errors.add('El nombre del producto es obligatorio');
    }
    
    if (basePrice <= 0) {
      errors.add('El precio base debe ser mayor a 0');
    }
    
    if (salePrice <= 0) {
      errors.add('El precio de venta debe ser mayor a 0');
    }
    
    if (!priceConfig.isPriceValid(salePrice)) {
      errors.add('El precio de venta está fuera del rango permitido');
    }
    
    if (inventoryConfig.isManaged) {
      if (inventoryConfig.minStock != null && 
          inventoryConfig.maxStock != null &&
          inventoryConfig.minStock! > inventoryConfig.maxStock!) {
        errors.add('El stock mínimo no puede ser mayor al stock máximo');
      }
    }
    
    return errors;
  }
}

/// Implementación de métodos tipo IBaseEntity para ProductEntity
extension ProductEntityBaseImplementation on ProductEntity {
  /// Validates the product entity
  ValidationResult validate() {
    final errors = <String>[];
    
    if (code.trim().isEmpty) {
      errors.add('El código del producto es obligatorio');
    }
    
    if (name.trim().isEmpty) {
      errors.add('El nombre del producto es obligatorio');
    }
    
    if (basePrice <= 0) {
      errors.add('El precio base debe ser mayor a 0');
    }
    
    if (salePrice <= 0) {
      errors.add('El precio de venta debe ser mayor a 0');
    }
    
    if (!priceConfig.isPriceValid(salePrice)) {
      errors.add('El precio de venta está fuera del rango permitido');
    }
    
    if (inventoryConfig.isManaged) {
      if (inventoryConfig.minStock != null && 
          inventoryConfig.maxStock != null &&
          inventoryConfig.minStock! > inventoryConfig.maxStock!) {
        errors.add('El stock mínimo no puede ser mayor al stock máximo');
      }
    }
    
    return (errors.isEmpty, errors);
  }
  
  /// Gets cache key for this entity
  String getCacheKey() => '${entityType}_${id.uniqueKey}';
  
  /// Gets display name for this entity
  String getDisplayName() {
    if (brand != null && brand!.isNotEmpty) {
      return '$brand $name';
    }
    return name;
  }
  
  /// Checks if entity needs synchronization
  bool needsSync() => syncMeta.needsSync;
  
  /// Gets entity type
  String get entityType => 'product';

  /// Additional validation method (backwards compatibility)
  ValidationResult baseValidate() => validate();
}
