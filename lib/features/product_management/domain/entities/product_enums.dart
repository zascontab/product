/// Enums para el módulo de gestión de productos
/// Siguiendo los patrones establecidos en RantiPay
library;

enum ProductCategory {
  goods('goods', 'Bienes'),
  services('services', 'Servicios'),
  rawMaterials('raw_materials', 'Materias Primas'),
  supplies('supplies', 'Suministros'),
  digital('digital', 'Productos Digitales'),
  consumables('consumables', 'Consumibles');

  const ProductCategory(this.code, this.description);
  final String code;
  final String description;
  
  String get displayName => description;
}

enum ProductType {
  physical('physical', 'Producto Físico'),
  digital('digital', 'Producto Digital'),
  service('service', 'Servicio'),
  subscription('subscription', 'Suscripción'),
  combo('combo', 'Combo/Paquete'),
  variable('variable', 'Producto Variable');

  const ProductType(this.code, this.description);
  final String code;
  final String description;
  
  String get displayName => description;
}

enum ProductStatus {
  active('active', 'Activo'),
  inactive('inactive', 'Inactivo'),
  discontinued('discontinued', 'Descontinuado'),
  draft('draft', 'Borrador'),
  pending('pending', 'Pendiente de Aprobación');

  const ProductStatus(this.code, this.description);
  final String code;
  final String description;
  
  String get displayName => description;
}

enum StockStatus {
  inStock('in_stock', 'En Stock'),
  lowStock('low_stock', 'Stock Bajo'),
  outOfStock('out_of_stock', 'Sin Stock'),
  unlimited('unlimited', 'Ilimitado'),
  notManaged('not_managed', 'No Gestionado');

  const StockStatus(this.code, this.description);
  final String code;
  final String description;
  
  String get displayName => description;
}

enum PriceType {
  fixed('fixed', 'Precio Fijo'),
  variable('variable', 'Precio Variable'),
  negotiable('negotiable', 'Precio Negociable'),
  quote('quote', 'Bajo Cotización');

  const PriceType(this.code, this.description);
  final String code;
  final String description;
  
  String get displayName => description;
}

enum MovementType {
  sale('sale', 'Venta'),
  purchase('purchase', 'Compra'),
  adjustment('adjustment', 'Ajuste'),
  transfer('transfer', 'Transferencia'),
  damaged('damaged', 'Daño/Pérdida'),
  returned('returned', 'Devolución');

  const MovementType(this.code, this.description);
  final String code;
  final String description;
  
  String get displayName => description;
}

/// Extensiones para funcionalidades adicionales
extension ProductCategoryExtension on ProductCategory {
  bool get isPhysical => this == ProductCategory.goods || 
                        this == ProductCategory.rawMaterials || 
                        this == ProductCategory.supplies ||
                        this == ProductCategory.consumables;
  
  bool get requiresInventory => isPhysical;
  
  bool get isServiceBased => this == ProductCategory.services ||
                            this == ProductCategory.digital;
}

extension ProductTypeExtension on ProductType {
  bool get requiresShipping => this == ProductType.physical;
  
  bool get isDigitalDelivery => this == ProductType.digital ||
                               this == ProductType.subscription;
  
  bool get allowsInventoryManagement => this == ProductType.physical ||
                                       this == ProductType.combo;
}

extension ProductStatusExtension on ProductStatus {
  bool get isAvailableForSale => this == ProductStatus.active;
  
  bool get isVisible => this == ProductStatus.active ||
                       this == ProductStatus.inactive;
  
  bool get requiresApproval => this == ProductStatus.pending;
}