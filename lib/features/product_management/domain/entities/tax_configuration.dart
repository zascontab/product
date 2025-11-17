import 'package:freezed_annotation/freezed_annotation.dart';

part 'tax_configuration.freezed.dart';
part 'tax_configuration.g.dart';

/// Configuración de impuestos para productos
/// Maneja toda la información fiscal requerida por el SRI
@freezed
class TaxConfiguration with _$TaxConfiguration {
  const factory TaxConfiguration({
    /// Porcentaje de IVA (0%, 12%, 14%, 15%)
    @Default(15.0) double ivaRate,
    
    /// Porcentaje de retención en la fuente
    @Default(0.0) double retentionRate,
    
    /// Porcentaje de retención de IVA
    @Default(0.0) double ivaRetentionRate,
    
    /// Código de producto SRI
    required String sriProductCode,
    
    /// Código de IVA SRI (0, 2, 3, 6, 7)
    required String sriIvaCode,
    
    /// Exento de IVA
    @Default(false) bool isIvaExempt,
    
    /// Exento de retención
    @Default(false) bool isRetentionExempt,
    
    /// Sujeto a ICE (Impuesto a Consumos Especiales)
    @Default(false) bool isIceSubject,
    
    /// Porcentaje de ICE
    @Default(0.0) double iceRate,
    
    /// Código de ICE SRI
    String? sriIceCode,
    
    /// Código de retención SRI
    String? sriRetentionCode,
    
    /// Notas fiscales adicionales
    String? fiscalNotes,
    
    /// Fecha de última actualización fiscal
    DateTime? lastFiscalUpdate,
  }) = _TaxConfiguration;

  factory TaxConfiguration.fromJson(Map<String, dynamic> json) =>
      _$TaxConfigurationFromJson(json);
}

/// Configuración de precios para productos
@freezed
class PriceConfiguration with _$PriceConfiguration {
  const factory PriceConfiguration({
    /// Permite aplicar descuentos
    @Default(true) bool allowDiscount,
    
    /// Porcentaje máximo de descuento permitido
    @Default(100.0) double maxDiscountPercent,
    
    /// Precio mínimo permitido
    double? minPrice,
    
    /// Precio máximo permitido
    double? maxPrice,
    
    /// Tiene variantes de precio por cantidad
    @Default(false) bool hasPriceVariants,
    
    /// Lista de variantes de precio
    @Default([]) List<PriceVariant> variants,
    
    /// Permite precios negociables
    @Default(false) bool isNegotiable,
    
    /// Requiere aprobación para descuentos
    @Default(false) bool requiresDiscountApproval,
    
    /// Porcentaje de margen de ganancia
    double? profitMargin,
    
    /// Costo base del producto
    double? baseCost,
    
    /// Incluye impuestos en el precio mostrado
    @Default(true) bool priceIncludesTax,
    
    /// Moneda del precio
    @Default('USD') String currency,
    
    /// Configuración de redondeo
    @Default(PriceRounding.twoDecimals) PriceRounding rounding,
  }) = _PriceConfiguration;

  factory PriceConfiguration.fromJson(Map<String, dynamic> json) =>
      _$PriceConfigurationFromJson(json);
}

/// Variante de precio por cantidad o tipo de cliente
@freezed
class PriceVariant with _$PriceVariant {
  const factory PriceVariant({
    /// Nombre de la variante (ej: "Mayorista", "Minorista")
    required String name,
    
    /// Precio específico para esta variante
    required double price,
    
    /// Cantidad mínima para aplicar este precio
    @Default(1) int minQuantity,
    
    /// Cantidad máxima para aplicar este precio
    int? maxQuantity,
    
    /// Tipo de cliente para esta variante
    String? customerType,
    
    /// Descuento automático aplicado
    @Default(0.0) double automaticDiscount,
    
    /// Activa o inactiva
    @Default(true) bool isActive,
    
    /// Fecha de inicio de vigencia
    DateTime? validFrom,
    
    /// Fecha de fin de vigencia
    DateTime? validTo,
  }) = _PriceVariant;

  factory PriceVariant.fromJson(Map<String, dynamic> json) =>
      _$PriceVariantFromJson(json);
}

/// Configuración de inventario
@freezed
class InventoryConfiguration with _$InventoryConfiguration {
  const factory InventoryConfiguration({
    /// Se gestiona inventario para este producto
    @Default(true) bool isManaged,
    
    /// Stock actual
    @Default(0) int currentStock,
    
    /// Stock mínimo (alerta de reposición)
    int? minStock,
    
    /// Stock máximo recomendado
    int? maxStock,
    
    /// Punto de reorden
    int? reorderPoint,
    
    /// Cantidad de reorden
    int? reorderQuantity,
    
    /// Unidad de medida
    @Default('unidad') String unit,
    
    /// Permite stock negativo
    @Default(false) bool allowNegativeStock,
    
    /// Ubicación en almacén
    String? storageLocation,
    
    /// Código de ubicación
    String? locationCode,
    
    /// Rastrea número de serie
    @Default(false) bool trackSerialNumber,
    
    /// Rastrea número de lote
    @Default(false) bool trackBatchNumber,
    
    /// Fecha de última actualización de stock
    DateTime? lastStockUpdate,
    
    /// Notas de inventario
    String? inventoryNotes,
  }) = _InventoryConfiguration;

  factory InventoryConfiguration.fromJson(Map<String, dynamic> json) =>
      _$InventoryConfigurationFromJson(json);
}

/// Configuración de redondeo de precios
enum PriceRounding {
  noRounding('none', 'Sin redondeo'),
  oneDecimal('one', 'Un decimal'),
  twoDecimals('two', 'Dos decimales'),
  nearestFive('five', 'Al cinco más cercano'),
  nearestTen('ten', 'Al diez más cercano');

  const PriceRounding(this.code, this.description);
  final String code;
  final String description;
}

/// Extensiones para cálculos de impuestos
extension TaxCalculations on TaxConfiguration {
  /// Calcula el IVA de un monto base
  double calculateIva(double baseAmount) {
    if (isIvaExempt) return 0.0;
    return baseAmount * (ivaRate / 100);
  }
  
  /// Calcula la retención de un monto base
  double calculateRetention(double baseAmount) {
    if (isRetentionExempt) return 0.0;
    return baseAmount * (retentionRate / 100);
  }
  
  /// Calcula el ICE de un monto base
  double calculateIce(double baseAmount) {
    if (!isIceSubject) return 0.0;
    return baseAmount * (iceRate / 100);
  }
  
  /// Calcula el total con impuestos
  double calculateTotalWithTaxes(double baseAmount) {
    final iva = calculateIva(baseAmount);
    final ice = calculateIce(baseAmount);
    return baseAmount + iva + ice;
  }
  
  /// Calcula el monto sin impuestos desde un total
  double calculateBaseFromTotal(double totalAmount) {
    final divisor = 1 + (ivaRate / 100) + (iceRate / 100);
    return totalAmount / divisor;
  }
}

/// Extensiones para cálculos de precios
extension PriceCalculations on PriceConfiguration {
  /// Aplica redondeo según configuración
  double applyRounding(double price) {
    switch (rounding) {
      case PriceRounding.noRounding:
        return price;
      case PriceRounding.oneDecimal:
        return double.parse(price.toStringAsFixed(1));
      case PriceRounding.twoDecimals:
        return double.parse(price.toStringAsFixed(2));
      case PriceRounding.nearestFive:
        return (price / 5).round() * 5.0;
      case PriceRounding.nearestTen:
        return (price / 10).round() * 10.0;
    }
  }
  
  /// Valida si un precio está dentro del rango permitido
  bool isPriceValid(double price) {
    if (minPrice != null && price < minPrice!) return false;
    if (maxPrice != null && price > maxPrice!) return false;
    return true;
  }
  
  /// Obtiene el precio para una cantidad específica
  double getPriceForQuantity(double basePrice, int quantity) {
    if (!hasPriceVariants) return basePrice;
    
    // Buscar la variante que corresponde a la cantidad
    PriceVariant? applicableVariant;
    for (final variant in variants) {
      if (!variant.isActive) continue;
      if (quantity >= variant.minQuantity) {
        if (variant.maxQuantity == null || quantity <= variant.maxQuantity!) {
          applicableVariant = variant;
        }
      }
    }
    
    return applicableVariant?.price ?? basePrice;
  }
}