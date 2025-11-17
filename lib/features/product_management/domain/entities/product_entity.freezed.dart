// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductEntity _$ProductEntityFromJson(Map<String, dynamic> json) {
  return _ProductEntity.fromJson(json);
}

/// @nodoc
mixin _$ProductEntity {
// === IBaseEntity Implementation ===
  EntityIdentifier get id => throw _privateConstructorUsedError;
  EntityMetadata get metadata => throw _privateConstructorUsedError;
  EntityStatus get status => throw _privateConstructorUsedError;
  SyncMetadata get syncMeta =>
      throw _privateConstructorUsedError; // === Información Básica ===
  /// Código interno único del producto
  String get code => throw _privateConstructorUsedError;

  /// Nombre comercial del producto
  String get name => throw _privateConstructorUsedError;

  /// Descripción detallada
  String get description => throw _privateConstructorUsedError;

  /// Código de barras (opcional)
  String? get barcode => throw _privateConstructorUsedError;

  /// Marca del producto
  String? get brand => throw _privateConstructorUsedError;

  /// Modelo del producto
  String? get model => throw _privateConstructorUsedError;

  /// Categoría del producto
  ProductCategory get category => throw _privateConstructorUsedError;

  /// Tipo de producto
  ProductType get type => throw _privateConstructorUsedError;

  /// Estado del producto
  ProductStatus get productStatus =>
      throw _privateConstructorUsedError; // === Información Fiscal (SRI) ===
  /// Configuración de impuestos
  TaxConfiguration get taxConfig => throw _privateConstructorUsedError;

  /// Código SRI oficial del producto
  String? get sriProductCode =>
      throw _privateConstructorUsedError; // === Precios ===
  /// Precio base sin impuestos
  double get basePrice => throw _privateConstructorUsedError;

  /// Precio de venta final (puede incluir impuestos)
  double get salePrice => throw _privateConstructorUsedError;

  /// Moneda del precio
  String get currency => throw _privateConstructorUsedError;

  /// Configuración de precios
  PriceConfiguration get priceConfig =>
      throw _privateConstructorUsedError; // === Inventario ===
  /// Configuración de inventario
  InventoryConfiguration get inventoryConfig =>
      throw _privateConstructorUsedError; // === Estado y Configuración ===
  /// Producto activo para ventas
  bool get isActive => throw _privateConstructorUsedError;

  /// Es un servicio (no producto físico)
  bool get isService => throw _privateConstructorUsedError;

  /// Fecha de última venta
  DateTime? get lastSaleDate => throw _privateConstructorUsedError;

  /// Contador total de ventas
  int get salesCount => throw _privateConstructorUsedError;

  /// Valor total vendido
  double get totalSalesValue =>
      throw _privateConstructorUsedError; // === Información Adicional ===
  /// Notas internas del producto
  String? get notes => throw _privateConstructorUsedError;

  /// Etiquetas para búsqueda y categorización
  List<String> get tags => throw _privateConstructorUsedError;

  /// Campos personalizados adicionales
  Map<String, dynamic> get customFields =>
      throw _privateConstructorUsedError; // === Información de Proveedor ===
  /// ID del proveedor principal
  String? get supplierId => throw _privateConstructorUsedError;

  /// Código del producto del proveedor
  String? get supplierProductCode => throw _privateConstructorUsedError;

  /// Costo de compra al proveedor
  double? get supplierCost =>
      throw _privateConstructorUsedError; // === Dimensiones y Peso (para productos físicos) ===
  /// Peso en kilogramos
  double? get weight => throw _privateConstructorUsedError;

  /// Largo en centímetros
  double? get length => throw _privateConstructorUsedError;

  /// Ancho en centímetros
  double? get width => throw _privateConstructorUsedError;

  /// Alto en centímetros
  double? get height =>
      throw _privateConstructorUsedError; // === URLs e Imágenes ===
  /// URL de imagen principal
  String? get imageUrl => throw _privateConstructorUsedError;

  /// URLs de imágenes adicionales
  List<String> get additionalImages => throw _privateConstructorUsedError;

  /// URL de ficha técnica o documentación
  String? get documentationUrl =>
      throw _privateConstructorUsedError; // === Fechas Importantes ===
  /// Fecha de lanzamiento del producto
  DateTime? get launchDate => throw _privateConstructorUsedError;

  /// Fecha de descontinuación
  DateTime? get discontinuationDate => throw _privateConstructorUsedError;

  /// Fecha de última actualización de precio
  DateTime? get lastPriceUpdate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProductEntityCopyWith<ProductEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductEntityCopyWith<$Res> {
  factory $ProductEntityCopyWith(
          ProductEntity value, $Res Function(ProductEntity) then) =
      _$ProductEntityCopyWithImpl<$Res, ProductEntity>;
  @useResult
  $Res call(
      {EntityIdentifier id,
      EntityMetadata metadata,
      EntityStatus status,
      SyncMetadata syncMeta,
      String code,
      String name,
      String description,
      String? barcode,
      String? brand,
      String? model,
      ProductCategory category,
      ProductType type,
      ProductStatus productStatus,
      TaxConfiguration taxConfig,
      String? sriProductCode,
      double basePrice,
      double salePrice,
      String currency,
      PriceConfiguration priceConfig,
      InventoryConfiguration inventoryConfig,
      bool isActive,
      bool isService,
      DateTime? lastSaleDate,
      int salesCount,
      double totalSalesValue,
      String? notes,
      List<String> tags,
      Map<String, dynamic> customFields,
      String? supplierId,
      String? supplierProductCode,
      double? supplierCost,
      double? weight,
      double? length,
      double? width,
      double? height,
      String? imageUrl,
      List<String> additionalImages,
      String? documentationUrl,
      DateTime? launchDate,
      DateTime? discontinuationDate,
      DateTime? lastPriceUpdate});

  $TaxConfigurationCopyWith<$Res> get taxConfig;
  $PriceConfigurationCopyWith<$Res> get priceConfig;
  $InventoryConfigurationCopyWith<$Res> get inventoryConfig;
}

/// @nodoc
class _$ProductEntityCopyWithImpl<$Res, $Val extends ProductEntity>
    implements $ProductEntityCopyWith<$Res> {
  _$ProductEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? metadata = null,
    Object? status = null,
    Object? syncMeta = null,
    Object? code = null,
    Object? name = null,
    Object? description = null,
    Object? barcode = freezed,
    Object? brand = freezed,
    Object? model = freezed,
    Object? category = null,
    Object? type = null,
    Object? productStatus = null,
    Object? taxConfig = null,
    Object? sriProductCode = freezed,
    Object? basePrice = null,
    Object? salePrice = null,
    Object? currency = null,
    Object? priceConfig = null,
    Object? inventoryConfig = null,
    Object? isActive = null,
    Object? isService = null,
    Object? lastSaleDate = freezed,
    Object? salesCount = null,
    Object? totalSalesValue = null,
    Object? notes = freezed,
    Object? tags = null,
    Object? customFields = null,
    Object? supplierId = freezed,
    Object? supplierProductCode = freezed,
    Object? supplierCost = freezed,
    Object? weight = freezed,
    Object? length = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? imageUrl = freezed,
    Object? additionalImages = null,
    Object? documentationUrl = freezed,
    Object? launchDate = freezed,
    Object? discontinuationDate = freezed,
    Object? lastPriceUpdate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as EntityIdentifier,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as EntityMetadata,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EntityStatus,
      syncMeta: null == syncMeta
          ? _value.syncMeta
          : syncMeta // ignore: cast_nullable_to_non_nullable
              as SyncMetadata,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategory,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProductType,
      productStatus: null == productStatus
          ? _value.productStatus
          : productStatus // ignore: cast_nullable_to_non_nullable
              as ProductStatus,
      taxConfig: null == taxConfig
          ? _value.taxConfig
          : taxConfig // ignore: cast_nullable_to_non_nullable
              as TaxConfiguration,
      sriProductCode: freezed == sriProductCode
          ? _value.sriProductCode
          : sriProductCode // ignore: cast_nullable_to_non_nullable
              as String?,
      basePrice: null == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as double,
      salePrice: null == salePrice
          ? _value.salePrice
          : salePrice // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      priceConfig: null == priceConfig
          ? _value.priceConfig
          : priceConfig // ignore: cast_nullable_to_non_nullable
              as PriceConfiguration,
      inventoryConfig: null == inventoryConfig
          ? _value.inventoryConfig
          : inventoryConfig // ignore: cast_nullable_to_non_nullable
              as InventoryConfiguration,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isService: null == isService
          ? _value.isService
          : isService // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSaleDate: freezed == lastSaleDate
          ? _value.lastSaleDate
          : lastSaleDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      salesCount: null == salesCount
          ? _value.salesCount
          : salesCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalSalesValue: null == totalSalesValue
          ? _value.totalSalesValue
          : totalSalesValue // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      customFields: null == customFields
          ? _value.customFields
          : customFields // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      supplierId: freezed == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierProductCode: freezed == supplierProductCode
          ? _value.supplierProductCode
          : supplierProductCode // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierCost: freezed == supplierCost
          ? _value.supplierCost
          : supplierCost // ignore: cast_nullable_to_non_nullable
              as double?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      length: freezed == length
          ? _value.length
          : length // ignore: cast_nullable_to_non_nullable
              as double?,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalImages: null == additionalImages
          ? _value.additionalImages
          : additionalImages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      documentationUrl: freezed == documentationUrl
          ? _value.documentationUrl
          : documentationUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      launchDate: freezed == launchDate
          ? _value.launchDate
          : launchDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      discontinuationDate: freezed == discontinuationDate
          ? _value.discontinuationDate
          : discontinuationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPriceUpdate: freezed == lastPriceUpdate
          ? _value.lastPriceUpdate
          : lastPriceUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TaxConfigurationCopyWith<$Res> get taxConfig {
    return $TaxConfigurationCopyWith<$Res>(_value.taxConfig, (value) {
      return _then(_value.copyWith(taxConfig: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PriceConfigurationCopyWith<$Res> get priceConfig {
    return $PriceConfigurationCopyWith<$Res>(_value.priceConfig, (value) {
      return _then(_value.copyWith(priceConfig: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $InventoryConfigurationCopyWith<$Res> get inventoryConfig {
    return $InventoryConfigurationCopyWith<$Res>(_value.inventoryConfig,
        (value) {
      return _then(_value.copyWith(inventoryConfig: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductEntityImplCopyWith<$Res>
    implements $ProductEntityCopyWith<$Res> {
  factory _$$ProductEntityImplCopyWith(
          _$ProductEntityImpl value, $Res Function(_$ProductEntityImpl) then) =
      __$$ProductEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {EntityIdentifier id,
      EntityMetadata metadata,
      EntityStatus status,
      SyncMetadata syncMeta,
      String code,
      String name,
      String description,
      String? barcode,
      String? brand,
      String? model,
      ProductCategory category,
      ProductType type,
      ProductStatus productStatus,
      TaxConfiguration taxConfig,
      String? sriProductCode,
      double basePrice,
      double salePrice,
      String currency,
      PriceConfiguration priceConfig,
      InventoryConfiguration inventoryConfig,
      bool isActive,
      bool isService,
      DateTime? lastSaleDate,
      int salesCount,
      double totalSalesValue,
      String? notes,
      List<String> tags,
      Map<String, dynamic> customFields,
      String? supplierId,
      String? supplierProductCode,
      double? supplierCost,
      double? weight,
      double? length,
      double? width,
      double? height,
      String? imageUrl,
      List<String> additionalImages,
      String? documentationUrl,
      DateTime? launchDate,
      DateTime? discontinuationDate,
      DateTime? lastPriceUpdate});

  @override
  $TaxConfigurationCopyWith<$Res> get taxConfig;
  @override
  $PriceConfigurationCopyWith<$Res> get priceConfig;
  @override
  $InventoryConfigurationCopyWith<$Res> get inventoryConfig;
}

/// @nodoc
class __$$ProductEntityImplCopyWithImpl<$Res>
    extends _$ProductEntityCopyWithImpl<$Res, _$ProductEntityImpl>
    implements _$$ProductEntityImplCopyWith<$Res> {
  __$$ProductEntityImplCopyWithImpl(
      _$ProductEntityImpl _value, $Res Function(_$ProductEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? metadata = null,
    Object? status = null,
    Object? syncMeta = null,
    Object? code = null,
    Object? name = null,
    Object? description = null,
    Object? barcode = freezed,
    Object? brand = freezed,
    Object? model = freezed,
    Object? category = null,
    Object? type = null,
    Object? productStatus = null,
    Object? taxConfig = null,
    Object? sriProductCode = freezed,
    Object? basePrice = null,
    Object? salePrice = null,
    Object? currency = null,
    Object? priceConfig = null,
    Object? inventoryConfig = null,
    Object? isActive = null,
    Object? isService = null,
    Object? lastSaleDate = freezed,
    Object? salesCount = null,
    Object? totalSalesValue = null,
    Object? notes = freezed,
    Object? tags = null,
    Object? customFields = null,
    Object? supplierId = freezed,
    Object? supplierProductCode = freezed,
    Object? supplierCost = freezed,
    Object? weight = freezed,
    Object? length = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? imageUrl = freezed,
    Object? additionalImages = null,
    Object? documentationUrl = freezed,
    Object? launchDate = freezed,
    Object? discontinuationDate = freezed,
    Object? lastPriceUpdate = freezed,
  }) {
    return _then(_$ProductEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as EntityIdentifier,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as EntityMetadata,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EntityStatus,
      syncMeta: null == syncMeta
          ? _value.syncMeta
          : syncMeta // ignore: cast_nullable_to_non_nullable
              as SyncMetadata,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ProductCategory,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProductType,
      productStatus: null == productStatus
          ? _value.productStatus
          : productStatus // ignore: cast_nullable_to_non_nullable
              as ProductStatus,
      taxConfig: null == taxConfig
          ? _value.taxConfig
          : taxConfig // ignore: cast_nullable_to_non_nullable
              as TaxConfiguration,
      sriProductCode: freezed == sriProductCode
          ? _value.sriProductCode
          : sriProductCode // ignore: cast_nullable_to_non_nullable
              as String?,
      basePrice: null == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as double,
      salePrice: null == salePrice
          ? _value.salePrice
          : salePrice // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      priceConfig: null == priceConfig
          ? _value.priceConfig
          : priceConfig // ignore: cast_nullable_to_non_nullable
              as PriceConfiguration,
      inventoryConfig: null == inventoryConfig
          ? _value.inventoryConfig
          : inventoryConfig // ignore: cast_nullable_to_non_nullable
              as InventoryConfiguration,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isService: null == isService
          ? _value.isService
          : isService // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSaleDate: freezed == lastSaleDate
          ? _value.lastSaleDate
          : lastSaleDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      salesCount: null == salesCount
          ? _value.salesCount
          : salesCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalSalesValue: null == totalSalesValue
          ? _value.totalSalesValue
          : totalSalesValue // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      customFields: null == customFields
          ? _value._customFields
          : customFields // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      supplierId: freezed == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierProductCode: freezed == supplierProductCode
          ? _value.supplierProductCode
          : supplierProductCode // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierCost: freezed == supplierCost
          ? _value.supplierCost
          : supplierCost // ignore: cast_nullable_to_non_nullable
              as double?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      length: freezed == length
          ? _value.length
          : length // ignore: cast_nullable_to_non_nullable
              as double?,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      additionalImages: null == additionalImages
          ? _value._additionalImages
          : additionalImages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      documentationUrl: freezed == documentationUrl
          ? _value.documentationUrl
          : documentationUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      launchDate: freezed == launchDate
          ? _value.launchDate
          : launchDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      discontinuationDate: freezed == discontinuationDate
          ? _value.discontinuationDate
          : discontinuationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPriceUpdate: freezed == lastPriceUpdate
          ? _value.lastPriceUpdate
          : lastPriceUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductEntityImpl implements _ProductEntity {
  const _$ProductEntityImpl(
      {required this.id,
      required this.metadata,
      required this.status,
      required this.syncMeta,
      required this.code,
      required this.name,
      this.description = '',
      this.barcode,
      this.brand,
      this.model,
      this.category = ProductCategory.goods,
      this.type = ProductType.physical,
      this.productStatus = ProductStatus.active,
      required this.taxConfig,
      this.sriProductCode,
      required this.basePrice,
      required this.salePrice,
      this.currency = 'USD',
      required this.priceConfig,
      required this.inventoryConfig,
      this.isActive = true,
      this.isService = false,
      this.lastSaleDate,
      this.salesCount = 0,
      this.totalSalesValue = 0.0,
      this.notes,
      final List<String> tags = const [],
      final Map<String, dynamic> customFields = const {},
      this.supplierId,
      this.supplierProductCode,
      this.supplierCost,
      this.weight,
      this.length,
      this.width,
      this.height,
      this.imageUrl,
      final List<String> additionalImages = const [],
      this.documentationUrl,
      this.launchDate,
      this.discontinuationDate,
      this.lastPriceUpdate})
      : _tags = tags,
        _customFields = customFields,
        _additionalImages = additionalImages;

  factory _$ProductEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductEntityImplFromJson(json);

// === IBaseEntity Implementation ===
  @override
  final EntityIdentifier id;
  @override
  final EntityMetadata metadata;
  @override
  final EntityStatus status;
  @override
  final SyncMetadata syncMeta;
// === Información Básica ===
  /// Código interno único del producto
  @override
  final String code;

  /// Nombre comercial del producto
  @override
  final String name;

  /// Descripción detallada
  @override
  @JsonKey()
  final String description;

  /// Código de barras (opcional)
  @override
  final String? barcode;

  /// Marca del producto
  @override
  final String? brand;

  /// Modelo del producto
  @override
  final String? model;

  /// Categoría del producto
  @override
  @JsonKey()
  final ProductCategory category;

  /// Tipo de producto
  @override
  @JsonKey()
  final ProductType type;

  /// Estado del producto
  @override
  @JsonKey()
  final ProductStatus productStatus;
// === Información Fiscal (SRI) ===
  /// Configuración de impuestos
  @override
  final TaxConfiguration taxConfig;

  /// Código SRI oficial del producto
  @override
  final String? sriProductCode;
// === Precios ===
  /// Precio base sin impuestos
  @override
  final double basePrice;

  /// Precio de venta final (puede incluir impuestos)
  @override
  final double salePrice;

  /// Moneda del precio
  @override
  @JsonKey()
  final String currency;

  /// Configuración de precios
  @override
  final PriceConfiguration priceConfig;
// === Inventario ===
  /// Configuración de inventario
  @override
  final InventoryConfiguration inventoryConfig;
// === Estado y Configuración ===
  /// Producto activo para ventas
  @override
  @JsonKey()
  final bool isActive;

  /// Es un servicio (no producto físico)
  @override
  @JsonKey()
  final bool isService;

  /// Fecha de última venta
  @override
  final DateTime? lastSaleDate;

  /// Contador total de ventas
  @override
  @JsonKey()
  final int salesCount;

  /// Valor total vendido
  @override
  @JsonKey()
  final double totalSalesValue;
// === Información Adicional ===
  /// Notas internas del producto
  @override
  final String? notes;

  /// Etiquetas para búsqueda y categorización
  final List<String> _tags;

  /// Etiquetas para búsqueda y categorización
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Campos personalizados adicionales
  final Map<String, dynamic> _customFields;

  /// Campos personalizados adicionales
  @override
  @JsonKey()
  Map<String, dynamic> get customFields {
    if (_customFields is EqualUnmodifiableMapView) return _customFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_customFields);
  }

// === Información de Proveedor ===
  /// ID del proveedor principal
  @override
  final String? supplierId;

  /// Código del producto del proveedor
  @override
  final String? supplierProductCode;

  /// Costo de compra al proveedor
  @override
  final double? supplierCost;
// === Dimensiones y Peso (para productos físicos) ===
  /// Peso en kilogramos
  @override
  final double? weight;

  /// Largo en centímetros
  @override
  final double? length;

  /// Ancho en centímetros
  @override
  final double? width;

  /// Alto en centímetros
  @override
  final double? height;
// === URLs e Imágenes ===
  /// URL de imagen principal
  @override
  final String? imageUrl;

  /// URLs de imágenes adicionales
  final List<String> _additionalImages;

  /// URLs de imágenes adicionales
  @override
  @JsonKey()
  List<String> get additionalImages {
    if (_additionalImages is EqualUnmodifiableListView)
      return _additionalImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_additionalImages);
  }

  /// URL de ficha técnica o documentación
  @override
  final String? documentationUrl;
// === Fechas Importantes ===
  /// Fecha de lanzamiento del producto
  @override
  final DateTime? launchDate;

  /// Fecha de descontinuación
  @override
  final DateTime? discontinuationDate;

  /// Fecha de última actualización de precio
  @override
  final DateTime? lastPriceUpdate;

  @override
  String toString() {
    return 'ProductEntity(id: $id, metadata: $metadata, status: $status, syncMeta: $syncMeta, code: $code, name: $name, description: $description, barcode: $barcode, brand: $brand, model: $model, category: $category, type: $type, productStatus: $productStatus, taxConfig: $taxConfig, sriProductCode: $sriProductCode, basePrice: $basePrice, salePrice: $salePrice, currency: $currency, priceConfig: $priceConfig, inventoryConfig: $inventoryConfig, isActive: $isActive, isService: $isService, lastSaleDate: $lastSaleDate, salesCount: $salesCount, totalSalesValue: $totalSalesValue, notes: $notes, tags: $tags, customFields: $customFields, supplierId: $supplierId, supplierProductCode: $supplierProductCode, supplierCost: $supplierCost, weight: $weight, length: $length, width: $width, height: $height, imageUrl: $imageUrl, additionalImages: $additionalImages, documentationUrl: $documentationUrl, launchDate: $launchDate, discontinuationDate: $discontinuationDate, lastPriceUpdate: $lastPriceUpdate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.syncMeta, syncMeta) ||
                other.syncMeta == syncMeta) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.productStatus, productStatus) ||
                other.productStatus == productStatus) &&
            (identical(other.taxConfig, taxConfig) ||
                other.taxConfig == taxConfig) &&
            (identical(other.sriProductCode, sriProductCode) ||
                other.sriProductCode == sriProductCode) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.salePrice, salePrice) ||
                other.salePrice == salePrice) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.priceConfig, priceConfig) ||
                other.priceConfig == priceConfig) &&
            (identical(other.inventoryConfig, inventoryConfig) ||
                other.inventoryConfig == inventoryConfig) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isService, isService) ||
                other.isService == isService) &&
            (identical(other.lastSaleDate, lastSaleDate) ||
                other.lastSaleDate == lastSaleDate) &&
            (identical(other.salesCount, salesCount) ||
                other.salesCount == salesCount) &&
            (identical(other.totalSalesValue, totalSalesValue) ||
                other.totalSalesValue == totalSalesValue) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._customFields, _customFields) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.supplierProductCode, supplierProductCode) ||
                other.supplierProductCode == supplierProductCode) &&
            (identical(other.supplierCost, supplierCost) ||
                other.supplierCost == supplierCost) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.length, length) || other.length == length) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other._additionalImages, _additionalImages) &&
            (identical(other.documentationUrl, documentationUrl) ||
                other.documentationUrl == documentationUrl) &&
            (identical(other.launchDate, launchDate) ||
                other.launchDate == launchDate) &&
            (identical(other.discontinuationDate, discontinuationDate) ||
                other.discontinuationDate == discontinuationDate) &&
            (identical(other.lastPriceUpdate, lastPriceUpdate) ||
                other.lastPriceUpdate == lastPriceUpdate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        metadata,
        status,
        syncMeta,
        code,
        name,
        description,
        barcode,
        brand,
        model,
        category,
        type,
        productStatus,
        taxConfig,
        sriProductCode,
        basePrice,
        salePrice,
        currency,
        priceConfig,
        inventoryConfig,
        isActive,
        isService,
        lastSaleDate,
        salesCount,
        totalSalesValue,
        notes,
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_customFields),
        supplierId,
        supplierProductCode,
        supplierCost,
        weight,
        length,
        width,
        height,
        imageUrl,
        const DeepCollectionEquality().hash(_additionalImages),
        documentationUrl,
        launchDate,
        discontinuationDate,
        lastPriceUpdate
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductEntityImplCopyWith<_$ProductEntityImpl> get copyWith =>
      __$$ProductEntityImplCopyWithImpl<_$ProductEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductEntityImplToJson(
      this,
    );
  }
}

abstract class _ProductEntity implements ProductEntity {
  const factory _ProductEntity(
      {required final EntityIdentifier id,
      required final EntityMetadata metadata,
      required final EntityStatus status,
      required final SyncMetadata syncMeta,
      required final String code,
      required final String name,
      final String description,
      final String? barcode,
      final String? brand,
      final String? model,
      final ProductCategory category,
      final ProductType type,
      final ProductStatus productStatus,
      required final TaxConfiguration taxConfig,
      final String? sriProductCode,
      required final double basePrice,
      required final double salePrice,
      final String currency,
      required final PriceConfiguration priceConfig,
      required final InventoryConfiguration inventoryConfig,
      final bool isActive,
      final bool isService,
      final DateTime? lastSaleDate,
      final int salesCount,
      final double totalSalesValue,
      final String? notes,
      final List<String> tags,
      final Map<String, dynamic> customFields,
      final String? supplierId,
      final String? supplierProductCode,
      final double? supplierCost,
      final double? weight,
      final double? length,
      final double? width,
      final double? height,
      final String? imageUrl,
      final List<String> additionalImages,
      final String? documentationUrl,
      final DateTime? launchDate,
      final DateTime? discontinuationDate,
      final DateTime? lastPriceUpdate}) = _$ProductEntityImpl;

  factory _ProductEntity.fromJson(Map<String, dynamic> json) =
      _$ProductEntityImpl.fromJson;

  @override // === IBaseEntity Implementation ===
  EntityIdentifier get id;
  @override
  EntityMetadata get metadata;
  @override
  EntityStatus get status;
  @override
  SyncMetadata get syncMeta;
  @override // === Información Básica ===
  /// Código interno único del producto
  String get code;
  @override

  /// Nombre comercial del producto
  String get name;
  @override

  /// Descripción detallada
  String get description;
  @override

  /// Código de barras (opcional)
  String? get barcode;
  @override

  /// Marca del producto
  String? get brand;
  @override

  /// Modelo del producto
  String? get model;
  @override

  /// Categoría del producto
  ProductCategory get category;
  @override

  /// Tipo de producto
  ProductType get type;
  @override

  /// Estado del producto
  ProductStatus get productStatus;
  @override // === Información Fiscal (SRI) ===
  /// Configuración de impuestos
  TaxConfiguration get taxConfig;
  @override

  /// Código SRI oficial del producto
  String? get sriProductCode;
  @override // === Precios ===
  /// Precio base sin impuestos
  double get basePrice;
  @override

  /// Precio de venta final (puede incluir impuestos)
  double get salePrice;
  @override

  /// Moneda del precio
  String get currency;
  @override

  /// Configuración de precios
  PriceConfiguration get priceConfig;
  @override // === Inventario ===
  /// Configuración de inventario
  InventoryConfiguration get inventoryConfig;
  @override // === Estado y Configuración ===
  /// Producto activo para ventas
  bool get isActive;
  @override

  /// Es un servicio (no producto físico)
  bool get isService;
  @override

  /// Fecha de última venta
  DateTime? get lastSaleDate;
  @override

  /// Contador total de ventas
  int get salesCount;
  @override

  /// Valor total vendido
  double get totalSalesValue;
  @override // === Información Adicional ===
  /// Notas internas del producto
  String? get notes;
  @override

  /// Etiquetas para búsqueda y categorización
  List<String> get tags;
  @override

  /// Campos personalizados adicionales
  Map<String, dynamic> get customFields;
  @override // === Información de Proveedor ===
  /// ID del proveedor principal
  String? get supplierId;
  @override

  /// Código del producto del proveedor
  String? get supplierProductCode;
  @override

  /// Costo de compra al proveedor
  double? get supplierCost;
  @override // === Dimensiones y Peso (para productos físicos) ===
  /// Peso en kilogramos
  double? get weight;
  @override

  /// Largo en centímetros
  double? get length;
  @override

  /// Ancho en centímetros
  double? get width;
  @override

  /// Alto en centímetros
  double? get height;
  @override // === URLs e Imágenes ===
  /// URL de imagen principal
  String? get imageUrl;
  @override

  /// URLs de imágenes adicionales
  List<String> get additionalImages;
  @override

  /// URL de ficha técnica o documentación
  String? get documentationUrl;
  @override // === Fechas Importantes ===
  /// Fecha de lanzamiento del producto
  DateTime? get launchDate;
  @override

  /// Fecha de descontinuación
  DateTime? get discontinuationDate;
  @override

  /// Fecha de última actualización de precio
  DateTime? get lastPriceUpdate;
  @override
  @JsonKey(ignore: true)
  _$$ProductEntityImplCopyWith<_$ProductEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
