// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tax_configuration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TaxConfiguration _$TaxConfigurationFromJson(Map<String, dynamic> json) {
  return _TaxConfiguration.fromJson(json);
}

/// @nodoc
mixin _$TaxConfiguration {
  /// Porcentaje de IVA (0%, 12%, 14%)
  double get ivaRate => throw _privateConstructorUsedError;

  /// Porcentaje de retención en la fuente
  double get retentionRate => throw _privateConstructorUsedError;

  /// Porcentaje de retención de IVA
  double get ivaRetentionRate => throw _privateConstructorUsedError;

  /// Código de producto SRI
  String get sriProductCode => throw _privateConstructorUsedError;

  /// Código de IVA SRI (0, 2, 3, 6, 7)
  String get sriIvaCode => throw _privateConstructorUsedError;

  /// Exento de IVA
  bool get isIvaExempt => throw _privateConstructorUsedError;

  /// Exento de retención
  bool get isRetentionExempt => throw _privateConstructorUsedError;

  /// Sujeto a ICE (Impuesto a Consumos Especiales)
  bool get isIceSubject => throw _privateConstructorUsedError;

  /// Porcentaje de ICE
  double get iceRate => throw _privateConstructorUsedError;

  /// Código de ICE SRI
  String? get sriIceCode => throw _privateConstructorUsedError;

  /// Código de retención SRI
  String? get sriRetentionCode => throw _privateConstructorUsedError;

  /// Notas fiscales adicionales
  String? get fiscalNotes => throw _privateConstructorUsedError;

  /// Fecha de última actualización fiscal
  DateTime? get lastFiscalUpdate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TaxConfigurationCopyWith<TaxConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxConfigurationCopyWith<$Res> {
  factory $TaxConfigurationCopyWith(
          TaxConfiguration value, $Res Function(TaxConfiguration) then) =
      _$TaxConfigurationCopyWithImpl<$Res, TaxConfiguration>;
  @useResult
  $Res call(
      {double ivaRate,
      double retentionRate,
      double ivaRetentionRate,
      String sriProductCode,
      String sriIvaCode,
      bool isIvaExempt,
      bool isRetentionExempt,
      bool isIceSubject,
      double iceRate,
      String? sriIceCode,
      String? sriRetentionCode,
      String? fiscalNotes,
      DateTime? lastFiscalUpdate});
}

/// @nodoc
class _$TaxConfigurationCopyWithImpl<$Res, $Val extends TaxConfiguration>
    implements $TaxConfigurationCopyWith<$Res> {
  _$TaxConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ivaRate = null,
    Object? retentionRate = null,
    Object? ivaRetentionRate = null,
    Object? sriProductCode = null,
    Object? sriIvaCode = null,
    Object? isIvaExempt = null,
    Object? isRetentionExempt = null,
    Object? isIceSubject = null,
    Object? iceRate = null,
    Object? sriIceCode = freezed,
    Object? sriRetentionCode = freezed,
    Object? fiscalNotes = freezed,
    Object? lastFiscalUpdate = freezed,
  }) {
    return _then(_value.copyWith(
      ivaRate: null == ivaRate
          ? _value.ivaRate
          : ivaRate // ignore: cast_nullable_to_non_nullable
              as double,
      retentionRate: null == retentionRate
          ? _value.retentionRate
          : retentionRate // ignore: cast_nullable_to_non_nullable
              as double,
      ivaRetentionRate: null == ivaRetentionRate
          ? _value.ivaRetentionRate
          : ivaRetentionRate // ignore: cast_nullable_to_non_nullable
              as double,
      sriProductCode: null == sriProductCode
          ? _value.sriProductCode
          : sriProductCode // ignore: cast_nullable_to_non_nullable
              as String,
      sriIvaCode: null == sriIvaCode
          ? _value.sriIvaCode
          : sriIvaCode // ignore: cast_nullable_to_non_nullable
              as String,
      isIvaExempt: null == isIvaExempt
          ? _value.isIvaExempt
          : isIvaExempt // ignore: cast_nullable_to_non_nullable
              as bool,
      isRetentionExempt: null == isRetentionExempt
          ? _value.isRetentionExempt
          : isRetentionExempt // ignore: cast_nullable_to_non_nullable
              as bool,
      isIceSubject: null == isIceSubject
          ? _value.isIceSubject
          : isIceSubject // ignore: cast_nullable_to_non_nullable
              as bool,
      iceRate: null == iceRate
          ? _value.iceRate
          : iceRate // ignore: cast_nullable_to_non_nullable
              as double,
      sriIceCode: freezed == sriIceCode
          ? _value.sriIceCode
          : sriIceCode // ignore: cast_nullable_to_non_nullable
              as String?,
      sriRetentionCode: freezed == sriRetentionCode
          ? _value.sriRetentionCode
          : sriRetentionCode // ignore: cast_nullable_to_non_nullable
              as String?,
      fiscalNotes: freezed == fiscalNotes
          ? _value.fiscalNotes
          : fiscalNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      lastFiscalUpdate: freezed == lastFiscalUpdate
          ? _value.lastFiscalUpdate
          : lastFiscalUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaxConfigurationImplCopyWith<$Res>
    implements $TaxConfigurationCopyWith<$Res> {
  factory _$$TaxConfigurationImplCopyWith(_$TaxConfigurationImpl value,
          $Res Function(_$TaxConfigurationImpl) then) =
      __$$TaxConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double ivaRate,
      double retentionRate,
      double ivaRetentionRate,
      String sriProductCode,
      String sriIvaCode,
      bool isIvaExempt,
      bool isRetentionExempt,
      bool isIceSubject,
      double iceRate,
      String? sriIceCode,
      String? sriRetentionCode,
      String? fiscalNotes,
      DateTime? lastFiscalUpdate});
}

/// @nodoc
class __$$TaxConfigurationImplCopyWithImpl<$Res>
    extends _$TaxConfigurationCopyWithImpl<$Res, _$TaxConfigurationImpl>
    implements _$$TaxConfigurationImplCopyWith<$Res> {
  __$$TaxConfigurationImplCopyWithImpl(_$TaxConfigurationImpl _value,
      $Res Function(_$TaxConfigurationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ivaRate = null,
    Object? retentionRate = null,
    Object? ivaRetentionRate = null,
    Object? sriProductCode = null,
    Object? sriIvaCode = null,
    Object? isIvaExempt = null,
    Object? isRetentionExempt = null,
    Object? isIceSubject = null,
    Object? iceRate = null,
    Object? sriIceCode = freezed,
    Object? sriRetentionCode = freezed,
    Object? fiscalNotes = freezed,
    Object? lastFiscalUpdate = freezed,
  }) {
    return _then(_$TaxConfigurationImpl(
      ivaRate: null == ivaRate
          ? _value.ivaRate
          : ivaRate // ignore: cast_nullable_to_non_nullable
              as double,
      retentionRate: null == retentionRate
          ? _value.retentionRate
          : retentionRate // ignore: cast_nullable_to_non_nullable
              as double,
      ivaRetentionRate: null == ivaRetentionRate
          ? _value.ivaRetentionRate
          : ivaRetentionRate // ignore: cast_nullable_to_non_nullable
              as double,
      sriProductCode: null == sriProductCode
          ? _value.sriProductCode
          : sriProductCode // ignore: cast_nullable_to_non_nullable
              as String,
      sriIvaCode: null == sriIvaCode
          ? _value.sriIvaCode
          : sriIvaCode // ignore: cast_nullable_to_non_nullable
              as String,
      isIvaExempt: null == isIvaExempt
          ? _value.isIvaExempt
          : isIvaExempt // ignore: cast_nullable_to_non_nullable
              as bool,
      isRetentionExempt: null == isRetentionExempt
          ? _value.isRetentionExempt
          : isRetentionExempt // ignore: cast_nullable_to_non_nullable
              as bool,
      isIceSubject: null == isIceSubject
          ? _value.isIceSubject
          : isIceSubject // ignore: cast_nullable_to_non_nullable
              as bool,
      iceRate: null == iceRate
          ? _value.iceRate
          : iceRate // ignore: cast_nullable_to_non_nullable
              as double,
      sriIceCode: freezed == sriIceCode
          ? _value.sriIceCode
          : sriIceCode // ignore: cast_nullable_to_non_nullable
              as String?,
      sriRetentionCode: freezed == sriRetentionCode
          ? _value.sriRetentionCode
          : sriRetentionCode // ignore: cast_nullable_to_non_nullable
              as String?,
      fiscalNotes: freezed == fiscalNotes
          ? _value.fiscalNotes
          : fiscalNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      lastFiscalUpdate: freezed == lastFiscalUpdate
          ? _value.lastFiscalUpdate
          : lastFiscalUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaxConfigurationImpl implements _TaxConfiguration {
  const _$TaxConfigurationImpl(
      {this.ivaRate = 12.0,
      this.retentionRate = 0.0,
      this.ivaRetentionRate = 0.0,
      required this.sriProductCode,
      required this.sriIvaCode,
      this.isIvaExempt = false,
      this.isRetentionExempt = false,
      this.isIceSubject = false,
      this.iceRate = 0.0,
      this.sriIceCode,
      this.sriRetentionCode,
      this.fiscalNotes,
      this.lastFiscalUpdate});

  factory _$TaxConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaxConfigurationImplFromJson(json);

  /// Porcentaje de IVA (0%, 12%, 14%)
  @override
  @JsonKey()
  final double ivaRate;

  /// Porcentaje de retención en la fuente
  @override
  @JsonKey()
  final double retentionRate;

  /// Porcentaje de retención de IVA
  @override
  @JsonKey()
  final double ivaRetentionRate;

  /// Código de producto SRI
  @override
  final String sriProductCode;

  /// Código de IVA SRI (0, 2, 3, 6, 7)
  @override
  final String sriIvaCode;

  /// Exento de IVA
  @override
  @JsonKey()
  final bool isIvaExempt;

  /// Exento de retención
  @override
  @JsonKey()
  final bool isRetentionExempt;

  /// Sujeto a ICE (Impuesto a Consumos Especiales)
  @override
  @JsonKey()
  final bool isIceSubject;

  /// Porcentaje de ICE
  @override
  @JsonKey()
  final double iceRate;

  /// Código de ICE SRI
  @override
  final String? sriIceCode;

  /// Código de retención SRI
  @override
  final String? sriRetentionCode;

  /// Notas fiscales adicionales
  @override
  final String? fiscalNotes;

  /// Fecha de última actualización fiscal
  @override
  final DateTime? lastFiscalUpdate;

  @override
  String toString() {
    return 'TaxConfiguration(ivaRate: $ivaRate, retentionRate: $retentionRate, ivaRetentionRate: $ivaRetentionRate, sriProductCode: $sriProductCode, sriIvaCode: $sriIvaCode, isIvaExempt: $isIvaExempt, isRetentionExempt: $isRetentionExempt, isIceSubject: $isIceSubject, iceRate: $iceRate, sriIceCode: $sriIceCode, sriRetentionCode: $sriRetentionCode, fiscalNotes: $fiscalNotes, lastFiscalUpdate: $lastFiscalUpdate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaxConfigurationImpl &&
            (identical(other.ivaRate, ivaRate) || other.ivaRate == ivaRate) &&
            (identical(other.retentionRate, retentionRate) ||
                other.retentionRate == retentionRate) &&
            (identical(other.ivaRetentionRate, ivaRetentionRate) ||
                other.ivaRetentionRate == ivaRetentionRate) &&
            (identical(other.sriProductCode, sriProductCode) ||
                other.sriProductCode == sriProductCode) &&
            (identical(other.sriIvaCode, sriIvaCode) ||
                other.sriIvaCode == sriIvaCode) &&
            (identical(other.isIvaExempt, isIvaExempt) ||
                other.isIvaExempt == isIvaExempt) &&
            (identical(other.isRetentionExempt, isRetentionExempt) ||
                other.isRetentionExempt == isRetentionExempt) &&
            (identical(other.isIceSubject, isIceSubject) ||
                other.isIceSubject == isIceSubject) &&
            (identical(other.iceRate, iceRate) || other.iceRate == iceRate) &&
            (identical(other.sriIceCode, sriIceCode) ||
                other.sriIceCode == sriIceCode) &&
            (identical(other.sriRetentionCode, sriRetentionCode) ||
                other.sriRetentionCode == sriRetentionCode) &&
            (identical(other.fiscalNotes, fiscalNotes) ||
                other.fiscalNotes == fiscalNotes) &&
            (identical(other.lastFiscalUpdate, lastFiscalUpdate) ||
                other.lastFiscalUpdate == lastFiscalUpdate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      ivaRate,
      retentionRate,
      ivaRetentionRate,
      sriProductCode,
      sriIvaCode,
      isIvaExempt,
      isRetentionExempt,
      isIceSubject,
      iceRate,
      sriIceCode,
      sriRetentionCode,
      fiscalNotes,
      lastFiscalUpdate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TaxConfigurationImplCopyWith<_$TaxConfigurationImpl> get copyWith =>
      __$$TaxConfigurationImplCopyWithImpl<_$TaxConfigurationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaxConfigurationImplToJson(
      this,
    );
  }
}

abstract class _TaxConfiguration implements TaxConfiguration {
  const factory _TaxConfiguration(
      {final double ivaRate,
      final double retentionRate,
      final double ivaRetentionRate,
      required final String sriProductCode,
      required final String sriIvaCode,
      final bool isIvaExempt,
      final bool isRetentionExempt,
      final bool isIceSubject,
      final double iceRate,
      final String? sriIceCode,
      final String? sriRetentionCode,
      final String? fiscalNotes,
      final DateTime? lastFiscalUpdate}) = _$TaxConfigurationImpl;

  factory _TaxConfiguration.fromJson(Map<String, dynamic> json) =
      _$TaxConfigurationImpl.fromJson;

  @override

  /// Porcentaje de IVA (0%, 12%, 14%)
  double get ivaRate;
  @override

  /// Porcentaje de retención en la fuente
  double get retentionRate;
  @override

  /// Porcentaje de retención de IVA
  double get ivaRetentionRate;
  @override

  /// Código de producto SRI
  String get sriProductCode;
  @override

  /// Código de IVA SRI (0, 2, 3, 6, 7)
  String get sriIvaCode;
  @override

  /// Exento de IVA
  bool get isIvaExempt;
  @override

  /// Exento de retención
  bool get isRetentionExempt;
  @override

  /// Sujeto a ICE (Impuesto a Consumos Especiales)
  bool get isIceSubject;
  @override

  /// Porcentaje de ICE
  double get iceRate;
  @override

  /// Código de ICE SRI
  String? get sriIceCode;
  @override

  /// Código de retención SRI
  String? get sriRetentionCode;
  @override

  /// Notas fiscales adicionales
  String? get fiscalNotes;
  @override

  /// Fecha de última actualización fiscal
  DateTime? get lastFiscalUpdate;
  @override
  @JsonKey(ignore: true)
  _$$TaxConfigurationImplCopyWith<_$TaxConfigurationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceConfiguration _$PriceConfigurationFromJson(Map<String, dynamic> json) {
  return _PriceConfiguration.fromJson(json);
}

/// @nodoc
mixin _$PriceConfiguration {
  /// Permite aplicar descuentos
  bool get allowDiscount => throw _privateConstructorUsedError;

  /// Porcentaje máximo de descuento permitido
  double get maxDiscountPercent => throw _privateConstructorUsedError;

  /// Precio mínimo permitido
  double? get minPrice => throw _privateConstructorUsedError;

  /// Precio máximo permitido
  double? get maxPrice => throw _privateConstructorUsedError;

  /// Tiene variantes de precio por cantidad
  bool get hasPriceVariants => throw _privateConstructorUsedError;

  /// Lista de variantes de precio
  List<PriceVariant> get variants => throw _privateConstructorUsedError;

  /// Permite precios negociables
  bool get isNegotiable => throw _privateConstructorUsedError;

  /// Requiere aprobación para descuentos
  bool get requiresDiscountApproval => throw _privateConstructorUsedError;

  /// Porcentaje de margen de ganancia
  double? get profitMargin => throw _privateConstructorUsedError;

  /// Costo base del producto
  double? get baseCost => throw _privateConstructorUsedError;

  /// Incluye impuestos en el precio mostrado
  bool get priceIncludesTax => throw _privateConstructorUsedError;

  /// Moneda del precio
  String get currency => throw _privateConstructorUsedError;

  /// Configuración de redondeo
  PriceRounding get rounding => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PriceConfigurationCopyWith<PriceConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceConfigurationCopyWith<$Res> {
  factory $PriceConfigurationCopyWith(
          PriceConfiguration value, $Res Function(PriceConfiguration) then) =
      _$PriceConfigurationCopyWithImpl<$Res, PriceConfiguration>;
  @useResult
  $Res call(
      {bool allowDiscount,
      double maxDiscountPercent,
      double? minPrice,
      double? maxPrice,
      bool hasPriceVariants,
      List<PriceVariant> variants,
      bool isNegotiable,
      bool requiresDiscountApproval,
      double? profitMargin,
      double? baseCost,
      bool priceIncludesTax,
      String currency,
      PriceRounding rounding});
}

/// @nodoc
class _$PriceConfigurationCopyWithImpl<$Res, $Val extends PriceConfiguration>
    implements $PriceConfigurationCopyWith<$Res> {
  _$PriceConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allowDiscount = null,
    Object? maxDiscountPercent = null,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? hasPriceVariants = null,
    Object? variants = null,
    Object? isNegotiable = null,
    Object? requiresDiscountApproval = null,
    Object? profitMargin = freezed,
    Object? baseCost = freezed,
    Object? priceIncludesTax = null,
    Object? currency = null,
    Object? rounding = null,
  }) {
    return _then(_value.copyWith(
      allowDiscount: null == allowDiscount
          ? _value.allowDiscount
          : allowDiscount // ignore: cast_nullable_to_non_nullable
              as bool,
      maxDiscountPercent: null == maxDiscountPercent
          ? _value.maxDiscountPercent
          : maxDiscountPercent // ignore: cast_nullable_to_non_nullable
              as double,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      hasPriceVariants: null == hasPriceVariants
          ? _value.hasPriceVariants
          : hasPriceVariants // ignore: cast_nullable_to_non_nullable
              as bool,
      variants: null == variants
          ? _value.variants
          : variants // ignore: cast_nullable_to_non_nullable
              as List<PriceVariant>,
      isNegotiable: null == isNegotiable
          ? _value.isNegotiable
          : isNegotiable // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresDiscountApproval: null == requiresDiscountApproval
          ? _value.requiresDiscountApproval
          : requiresDiscountApproval // ignore: cast_nullable_to_non_nullable
              as bool,
      profitMargin: freezed == profitMargin
          ? _value.profitMargin
          : profitMargin // ignore: cast_nullable_to_non_nullable
              as double?,
      baseCost: freezed == baseCost
          ? _value.baseCost
          : baseCost // ignore: cast_nullable_to_non_nullable
              as double?,
      priceIncludesTax: null == priceIncludesTax
          ? _value.priceIncludesTax
          : priceIncludesTax // ignore: cast_nullable_to_non_nullable
              as bool,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      rounding: null == rounding
          ? _value.rounding
          : rounding // ignore: cast_nullable_to_non_nullable
              as PriceRounding,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PriceConfigurationImplCopyWith<$Res>
    implements $PriceConfigurationCopyWith<$Res> {
  factory _$$PriceConfigurationImplCopyWith(_$PriceConfigurationImpl value,
          $Res Function(_$PriceConfigurationImpl) then) =
      __$$PriceConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool allowDiscount,
      double maxDiscountPercent,
      double? minPrice,
      double? maxPrice,
      bool hasPriceVariants,
      List<PriceVariant> variants,
      bool isNegotiable,
      bool requiresDiscountApproval,
      double? profitMargin,
      double? baseCost,
      bool priceIncludesTax,
      String currency,
      PriceRounding rounding});
}

/// @nodoc
class __$$PriceConfigurationImplCopyWithImpl<$Res>
    extends _$PriceConfigurationCopyWithImpl<$Res, _$PriceConfigurationImpl>
    implements _$$PriceConfigurationImplCopyWith<$Res> {
  __$$PriceConfigurationImplCopyWithImpl(_$PriceConfigurationImpl _value,
      $Res Function(_$PriceConfigurationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allowDiscount = null,
    Object? maxDiscountPercent = null,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? hasPriceVariants = null,
    Object? variants = null,
    Object? isNegotiable = null,
    Object? requiresDiscountApproval = null,
    Object? profitMargin = freezed,
    Object? baseCost = freezed,
    Object? priceIncludesTax = null,
    Object? currency = null,
    Object? rounding = null,
  }) {
    return _then(_$PriceConfigurationImpl(
      allowDiscount: null == allowDiscount
          ? _value.allowDiscount
          : allowDiscount // ignore: cast_nullable_to_non_nullable
              as bool,
      maxDiscountPercent: null == maxDiscountPercent
          ? _value.maxDiscountPercent
          : maxDiscountPercent // ignore: cast_nullable_to_non_nullable
              as double,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      hasPriceVariants: null == hasPriceVariants
          ? _value.hasPriceVariants
          : hasPriceVariants // ignore: cast_nullable_to_non_nullable
              as bool,
      variants: null == variants
          ? _value._variants
          : variants // ignore: cast_nullable_to_non_nullable
              as List<PriceVariant>,
      isNegotiable: null == isNegotiable
          ? _value.isNegotiable
          : isNegotiable // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresDiscountApproval: null == requiresDiscountApproval
          ? _value.requiresDiscountApproval
          : requiresDiscountApproval // ignore: cast_nullable_to_non_nullable
              as bool,
      profitMargin: freezed == profitMargin
          ? _value.profitMargin
          : profitMargin // ignore: cast_nullable_to_non_nullable
              as double?,
      baseCost: freezed == baseCost
          ? _value.baseCost
          : baseCost // ignore: cast_nullable_to_non_nullable
              as double?,
      priceIncludesTax: null == priceIncludesTax
          ? _value.priceIncludesTax
          : priceIncludesTax // ignore: cast_nullable_to_non_nullable
              as bool,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      rounding: null == rounding
          ? _value.rounding
          : rounding // ignore: cast_nullable_to_non_nullable
              as PriceRounding,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceConfigurationImpl implements _PriceConfiguration {
  const _$PriceConfigurationImpl(
      {this.allowDiscount = true,
      this.maxDiscountPercent = 100.0,
      this.minPrice,
      this.maxPrice,
      this.hasPriceVariants = false,
      final List<PriceVariant> variants = const [],
      this.isNegotiable = false,
      this.requiresDiscountApproval = false,
      this.profitMargin,
      this.baseCost,
      this.priceIncludesTax = true,
      this.currency = 'USD',
      this.rounding = PriceRounding.twoDecimals})
      : _variants = variants;

  factory _$PriceConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceConfigurationImplFromJson(json);

  /// Permite aplicar descuentos
  @override
  @JsonKey()
  final bool allowDiscount;

  /// Porcentaje máximo de descuento permitido
  @override
  @JsonKey()
  final double maxDiscountPercent;

  /// Precio mínimo permitido
  @override
  final double? minPrice;

  /// Precio máximo permitido
  @override
  final double? maxPrice;

  /// Tiene variantes de precio por cantidad
  @override
  @JsonKey()
  final bool hasPriceVariants;

  /// Lista de variantes de precio
  final List<PriceVariant> _variants;

  /// Lista de variantes de precio
  @override
  @JsonKey()
  List<PriceVariant> get variants {
    if (_variants is EqualUnmodifiableListView) return _variants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variants);
  }

  /// Permite precios negociables
  @override
  @JsonKey()
  final bool isNegotiable;

  /// Requiere aprobación para descuentos
  @override
  @JsonKey()
  final bool requiresDiscountApproval;

  /// Porcentaje de margen de ganancia
  @override
  final double? profitMargin;

  /// Costo base del producto
  @override
  final double? baseCost;

  /// Incluye impuestos en el precio mostrado
  @override
  @JsonKey()
  final bool priceIncludesTax;

  /// Moneda del precio
  @override
  @JsonKey()
  final String currency;

  /// Configuración de redondeo
  @override
  @JsonKey()
  final PriceRounding rounding;

  @override
  String toString() {
    return 'PriceConfiguration(allowDiscount: $allowDiscount, maxDiscountPercent: $maxDiscountPercent, minPrice: $minPrice, maxPrice: $maxPrice, hasPriceVariants: $hasPriceVariants, variants: $variants, isNegotiable: $isNegotiable, requiresDiscountApproval: $requiresDiscountApproval, profitMargin: $profitMargin, baseCost: $baseCost, priceIncludesTax: $priceIncludesTax, currency: $currency, rounding: $rounding)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceConfigurationImpl &&
            (identical(other.allowDiscount, allowDiscount) ||
                other.allowDiscount == allowDiscount) &&
            (identical(other.maxDiscountPercent, maxDiscountPercent) ||
                other.maxDiscountPercent == maxDiscountPercent) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.hasPriceVariants, hasPriceVariants) ||
                other.hasPriceVariants == hasPriceVariants) &&
            const DeepCollectionEquality().equals(other._variants, _variants) &&
            (identical(other.isNegotiable, isNegotiable) ||
                other.isNegotiable == isNegotiable) &&
            (identical(
                    other.requiresDiscountApproval, requiresDiscountApproval) ||
                other.requiresDiscountApproval == requiresDiscountApproval) &&
            (identical(other.profitMargin, profitMargin) ||
                other.profitMargin == profitMargin) &&
            (identical(other.baseCost, baseCost) ||
                other.baseCost == baseCost) &&
            (identical(other.priceIncludesTax, priceIncludesTax) ||
                other.priceIncludesTax == priceIncludesTax) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.rounding, rounding) ||
                other.rounding == rounding));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      allowDiscount,
      maxDiscountPercent,
      minPrice,
      maxPrice,
      hasPriceVariants,
      const DeepCollectionEquality().hash(_variants),
      isNegotiable,
      requiresDiscountApproval,
      profitMargin,
      baseCost,
      priceIncludesTax,
      currency,
      rounding);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceConfigurationImplCopyWith<_$PriceConfigurationImpl> get copyWith =>
      __$$PriceConfigurationImplCopyWithImpl<_$PriceConfigurationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceConfigurationImplToJson(
      this,
    );
  }
}

abstract class _PriceConfiguration implements PriceConfiguration {
  const factory _PriceConfiguration(
      {final bool allowDiscount,
      final double maxDiscountPercent,
      final double? minPrice,
      final double? maxPrice,
      final bool hasPriceVariants,
      final List<PriceVariant> variants,
      final bool isNegotiable,
      final bool requiresDiscountApproval,
      final double? profitMargin,
      final double? baseCost,
      final bool priceIncludesTax,
      final String currency,
      final PriceRounding rounding}) = _$PriceConfigurationImpl;

  factory _PriceConfiguration.fromJson(Map<String, dynamic> json) =
      _$PriceConfigurationImpl.fromJson;

  @override

  /// Permite aplicar descuentos
  bool get allowDiscount;
  @override

  /// Porcentaje máximo de descuento permitido
  double get maxDiscountPercent;
  @override

  /// Precio mínimo permitido
  double? get minPrice;
  @override

  /// Precio máximo permitido
  double? get maxPrice;
  @override

  /// Tiene variantes de precio por cantidad
  bool get hasPriceVariants;
  @override

  /// Lista de variantes de precio
  List<PriceVariant> get variants;
  @override

  /// Permite precios negociables
  bool get isNegotiable;
  @override

  /// Requiere aprobación para descuentos
  bool get requiresDiscountApproval;
  @override

  /// Porcentaje de margen de ganancia
  double? get profitMargin;
  @override

  /// Costo base del producto
  double? get baseCost;
  @override

  /// Incluye impuestos en el precio mostrado
  bool get priceIncludesTax;
  @override

  /// Moneda del precio
  String get currency;
  @override

  /// Configuración de redondeo
  PriceRounding get rounding;
  @override
  @JsonKey(ignore: true)
  _$$PriceConfigurationImplCopyWith<_$PriceConfigurationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceVariant _$PriceVariantFromJson(Map<String, dynamic> json) {
  return _PriceVariant.fromJson(json);
}

/// @nodoc
mixin _$PriceVariant {
  /// Nombre de la variante (ej: "Mayorista", "Minorista")
  String get name => throw _privateConstructorUsedError;

  /// Precio específico para esta variante
  double get price => throw _privateConstructorUsedError;

  /// Cantidad mínima para aplicar este precio
  int get minQuantity => throw _privateConstructorUsedError;

  /// Cantidad máxima para aplicar este precio
  int? get maxQuantity => throw _privateConstructorUsedError;

  /// Tipo de cliente para esta variante
  String? get customerType => throw _privateConstructorUsedError;

  /// Descuento automático aplicado
  double get automaticDiscount => throw _privateConstructorUsedError;

  /// Activa o inactiva
  bool get isActive => throw _privateConstructorUsedError;

  /// Fecha de inicio de vigencia
  DateTime? get validFrom => throw _privateConstructorUsedError;

  /// Fecha de fin de vigencia
  DateTime? get validTo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PriceVariantCopyWith<PriceVariant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceVariantCopyWith<$Res> {
  factory $PriceVariantCopyWith(
          PriceVariant value, $Res Function(PriceVariant) then) =
      _$PriceVariantCopyWithImpl<$Res, PriceVariant>;
  @useResult
  $Res call(
      {String name,
      double price,
      int minQuantity,
      int? maxQuantity,
      String? customerType,
      double automaticDiscount,
      bool isActive,
      DateTime? validFrom,
      DateTime? validTo});
}

/// @nodoc
class _$PriceVariantCopyWithImpl<$Res, $Val extends PriceVariant>
    implements $PriceVariantCopyWith<$Res> {
  _$PriceVariantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? price = null,
    Object? minQuantity = null,
    Object? maxQuantity = freezed,
    Object? customerType = freezed,
    Object? automaticDiscount = null,
    Object? isActive = null,
    Object? validFrom = freezed,
    Object? validTo = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      minQuantity: null == minQuantity
          ? _value.minQuantity
          : minQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      maxQuantity: freezed == maxQuantity
          ? _value.maxQuantity
          : maxQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      customerType: freezed == customerType
          ? _value.customerType
          : customerType // ignore: cast_nullable_to_non_nullable
              as String?,
      automaticDiscount: null == automaticDiscount
          ? _value.automaticDiscount
          : automaticDiscount // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      validFrom: freezed == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      validTo: freezed == validTo
          ? _value.validTo
          : validTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PriceVariantImplCopyWith<$Res>
    implements $PriceVariantCopyWith<$Res> {
  factory _$$PriceVariantImplCopyWith(
          _$PriceVariantImpl value, $Res Function(_$PriceVariantImpl) then) =
      __$$PriceVariantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      double price,
      int minQuantity,
      int? maxQuantity,
      String? customerType,
      double automaticDiscount,
      bool isActive,
      DateTime? validFrom,
      DateTime? validTo});
}

/// @nodoc
class __$$PriceVariantImplCopyWithImpl<$Res>
    extends _$PriceVariantCopyWithImpl<$Res, _$PriceVariantImpl>
    implements _$$PriceVariantImplCopyWith<$Res> {
  __$$PriceVariantImplCopyWithImpl(
      _$PriceVariantImpl _value, $Res Function(_$PriceVariantImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? price = null,
    Object? minQuantity = null,
    Object? maxQuantity = freezed,
    Object? customerType = freezed,
    Object? automaticDiscount = null,
    Object? isActive = null,
    Object? validFrom = freezed,
    Object? validTo = freezed,
  }) {
    return _then(_$PriceVariantImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      minQuantity: null == minQuantity
          ? _value.minQuantity
          : minQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      maxQuantity: freezed == maxQuantity
          ? _value.maxQuantity
          : maxQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      customerType: freezed == customerType
          ? _value.customerType
          : customerType // ignore: cast_nullable_to_non_nullable
              as String?,
      automaticDiscount: null == automaticDiscount
          ? _value.automaticDiscount
          : automaticDiscount // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      validFrom: freezed == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      validTo: freezed == validTo
          ? _value.validTo
          : validTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceVariantImpl implements _PriceVariant {
  const _$PriceVariantImpl(
      {required this.name,
      required this.price,
      this.minQuantity = 1,
      this.maxQuantity,
      this.customerType,
      this.automaticDiscount = 0.0,
      this.isActive = true,
      this.validFrom,
      this.validTo});

  factory _$PriceVariantImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceVariantImplFromJson(json);

  /// Nombre de la variante (ej: "Mayorista", "Minorista")
  @override
  final String name;

  /// Precio específico para esta variante
  @override
  final double price;

  /// Cantidad mínima para aplicar este precio
  @override
  @JsonKey()
  final int minQuantity;

  /// Cantidad máxima para aplicar este precio
  @override
  final int? maxQuantity;

  /// Tipo de cliente para esta variante
  @override
  final String? customerType;

  /// Descuento automático aplicado
  @override
  @JsonKey()
  final double automaticDiscount;

  /// Activa o inactiva
  @override
  @JsonKey()
  final bool isActive;

  /// Fecha de inicio de vigencia
  @override
  final DateTime? validFrom;

  /// Fecha de fin de vigencia
  @override
  final DateTime? validTo;

  @override
  String toString() {
    return 'PriceVariant(name: $name, price: $price, minQuantity: $minQuantity, maxQuantity: $maxQuantity, customerType: $customerType, automaticDiscount: $automaticDiscount, isActive: $isActive, validFrom: $validFrom, validTo: $validTo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceVariantImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.minQuantity, minQuantity) ||
                other.minQuantity == minQuantity) &&
            (identical(other.maxQuantity, maxQuantity) ||
                other.maxQuantity == maxQuantity) &&
            (identical(other.customerType, customerType) ||
                other.customerType == customerType) &&
            (identical(other.automaticDiscount, automaticDiscount) ||
                other.automaticDiscount == automaticDiscount) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.validFrom, validFrom) ||
                other.validFrom == validFrom) &&
            (identical(other.validTo, validTo) || other.validTo == validTo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      price,
      minQuantity,
      maxQuantity,
      customerType,
      automaticDiscount,
      isActive,
      validFrom,
      validTo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceVariantImplCopyWith<_$PriceVariantImpl> get copyWith =>
      __$$PriceVariantImplCopyWithImpl<_$PriceVariantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceVariantImplToJson(
      this,
    );
  }
}

abstract class _PriceVariant implements PriceVariant {
  const factory _PriceVariant(
      {required final String name,
      required final double price,
      final int minQuantity,
      final int? maxQuantity,
      final String? customerType,
      final double automaticDiscount,
      final bool isActive,
      final DateTime? validFrom,
      final DateTime? validTo}) = _$PriceVariantImpl;

  factory _PriceVariant.fromJson(Map<String, dynamic> json) =
      _$PriceVariantImpl.fromJson;

  @override

  /// Nombre de la variante (ej: "Mayorista", "Minorista")
  String get name;
  @override

  /// Precio específico para esta variante
  double get price;
  @override

  /// Cantidad mínima para aplicar este precio
  int get minQuantity;
  @override

  /// Cantidad máxima para aplicar este precio
  int? get maxQuantity;
  @override

  /// Tipo de cliente para esta variante
  String? get customerType;
  @override

  /// Descuento automático aplicado
  double get automaticDiscount;
  @override

  /// Activa o inactiva
  bool get isActive;
  @override

  /// Fecha de inicio de vigencia
  DateTime? get validFrom;
  @override

  /// Fecha de fin de vigencia
  DateTime? get validTo;
  @override
  @JsonKey(ignore: true)
  _$$PriceVariantImplCopyWith<_$PriceVariantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InventoryConfiguration _$InventoryConfigurationFromJson(
    Map<String, dynamic> json) {
  return _InventoryConfiguration.fromJson(json);
}

/// @nodoc
mixin _$InventoryConfiguration {
  /// Se gestiona inventario para este producto
  bool get isManaged => throw _privateConstructorUsedError;

  /// Stock actual
  int get currentStock => throw _privateConstructorUsedError;

  /// Stock mínimo (alerta de reposición)
  int? get minStock => throw _privateConstructorUsedError;

  /// Stock máximo recomendado
  int? get maxStock => throw _privateConstructorUsedError;

  /// Punto de reorden
  int? get reorderPoint => throw _privateConstructorUsedError;

  /// Cantidad de reorden
  int? get reorderQuantity => throw _privateConstructorUsedError;

  /// Unidad de medida
  String get unit => throw _privateConstructorUsedError;

  /// Permite stock negativo
  bool get allowNegativeStock => throw _privateConstructorUsedError;

  /// Ubicación en almacén
  String? get storageLocation => throw _privateConstructorUsedError;

  /// Código de ubicación
  String? get locationCode => throw _privateConstructorUsedError;

  /// Rastrea número de serie
  bool get trackSerialNumber => throw _privateConstructorUsedError;

  /// Rastrea número de lote
  bool get trackBatchNumber => throw _privateConstructorUsedError;

  /// Fecha de última actualización de stock
  DateTime? get lastStockUpdate => throw _privateConstructorUsedError;

  /// Notas de inventario
  String? get inventoryNotes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InventoryConfigurationCopyWith<InventoryConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryConfigurationCopyWith<$Res> {
  factory $InventoryConfigurationCopyWith(InventoryConfiguration value,
          $Res Function(InventoryConfiguration) then) =
      _$InventoryConfigurationCopyWithImpl<$Res, InventoryConfiguration>;
  @useResult
  $Res call(
      {bool isManaged,
      int currentStock,
      int? minStock,
      int? maxStock,
      int? reorderPoint,
      int? reorderQuantity,
      String unit,
      bool allowNegativeStock,
      String? storageLocation,
      String? locationCode,
      bool trackSerialNumber,
      bool trackBatchNumber,
      DateTime? lastStockUpdate,
      String? inventoryNotes});
}

/// @nodoc
class _$InventoryConfigurationCopyWithImpl<$Res,
        $Val extends InventoryConfiguration>
    implements $InventoryConfigurationCopyWith<$Res> {
  _$InventoryConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isManaged = null,
    Object? currentStock = null,
    Object? minStock = freezed,
    Object? maxStock = freezed,
    Object? reorderPoint = freezed,
    Object? reorderQuantity = freezed,
    Object? unit = null,
    Object? allowNegativeStock = null,
    Object? storageLocation = freezed,
    Object? locationCode = freezed,
    Object? trackSerialNumber = null,
    Object? trackBatchNumber = null,
    Object? lastStockUpdate = freezed,
    Object? inventoryNotes = freezed,
  }) {
    return _then(_value.copyWith(
      isManaged: null == isManaged
          ? _value.isManaged
          : isManaged // ignore: cast_nullable_to_non_nullable
              as bool,
      currentStock: null == currentStock
          ? _value.currentStock
          : currentStock // ignore: cast_nullable_to_non_nullable
              as int,
      minStock: freezed == minStock
          ? _value.minStock
          : minStock // ignore: cast_nullable_to_non_nullable
              as int?,
      maxStock: freezed == maxStock
          ? _value.maxStock
          : maxStock // ignore: cast_nullable_to_non_nullable
              as int?,
      reorderPoint: freezed == reorderPoint
          ? _value.reorderPoint
          : reorderPoint // ignore: cast_nullable_to_non_nullable
              as int?,
      reorderQuantity: freezed == reorderQuantity
          ? _value.reorderQuantity
          : reorderQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      allowNegativeStock: null == allowNegativeStock
          ? _value.allowNegativeStock
          : allowNegativeStock // ignore: cast_nullable_to_non_nullable
              as bool,
      storageLocation: freezed == storageLocation
          ? _value.storageLocation
          : storageLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      locationCode: freezed == locationCode
          ? _value.locationCode
          : locationCode // ignore: cast_nullable_to_non_nullable
              as String?,
      trackSerialNumber: null == trackSerialNumber
          ? _value.trackSerialNumber
          : trackSerialNumber // ignore: cast_nullable_to_non_nullable
              as bool,
      trackBatchNumber: null == trackBatchNumber
          ? _value.trackBatchNumber
          : trackBatchNumber // ignore: cast_nullable_to_non_nullable
              as bool,
      lastStockUpdate: freezed == lastStockUpdate
          ? _value.lastStockUpdate
          : lastStockUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      inventoryNotes: freezed == inventoryNotes
          ? _value.inventoryNotes
          : inventoryNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InventoryConfigurationImplCopyWith<$Res>
    implements $InventoryConfigurationCopyWith<$Res> {
  factory _$$InventoryConfigurationImplCopyWith(
          _$InventoryConfigurationImpl value,
          $Res Function(_$InventoryConfigurationImpl) then) =
      __$$InventoryConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isManaged,
      int currentStock,
      int? minStock,
      int? maxStock,
      int? reorderPoint,
      int? reorderQuantity,
      String unit,
      bool allowNegativeStock,
      String? storageLocation,
      String? locationCode,
      bool trackSerialNumber,
      bool trackBatchNumber,
      DateTime? lastStockUpdate,
      String? inventoryNotes});
}

/// @nodoc
class __$$InventoryConfigurationImplCopyWithImpl<$Res>
    extends _$InventoryConfigurationCopyWithImpl<$Res,
        _$InventoryConfigurationImpl>
    implements _$$InventoryConfigurationImplCopyWith<$Res> {
  __$$InventoryConfigurationImplCopyWithImpl(
      _$InventoryConfigurationImpl _value,
      $Res Function(_$InventoryConfigurationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isManaged = null,
    Object? currentStock = null,
    Object? minStock = freezed,
    Object? maxStock = freezed,
    Object? reorderPoint = freezed,
    Object? reorderQuantity = freezed,
    Object? unit = null,
    Object? allowNegativeStock = null,
    Object? storageLocation = freezed,
    Object? locationCode = freezed,
    Object? trackSerialNumber = null,
    Object? trackBatchNumber = null,
    Object? lastStockUpdate = freezed,
    Object? inventoryNotes = freezed,
  }) {
    return _then(_$InventoryConfigurationImpl(
      isManaged: null == isManaged
          ? _value.isManaged
          : isManaged // ignore: cast_nullable_to_non_nullable
              as bool,
      currentStock: null == currentStock
          ? _value.currentStock
          : currentStock // ignore: cast_nullable_to_non_nullable
              as int,
      minStock: freezed == minStock
          ? _value.minStock
          : minStock // ignore: cast_nullable_to_non_nullable
              as int?,
      maxStock: freezed == maxStock
          ? _value.maxStock
          : maxStock // ignore: cast_nullable_to_non_nullable
              as int?,
      reorderPoint: freezed == reorderPoint
          ? _value.reorderPoint
          : reorderPoint // ignore: cast_nullable_to_non_nullable
              as int?,
      reorderQuantity: freezed == reorderQuantity
          ? _value.reorderQuantity
          : reorderQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      allowNegativeStock: null == allowNegativeStock
          ? _value.allowNegativeStock
          : allowNegativeStock // ignore: cast_nullable_to_non_nullable
              as bool,
      storageLocation: freezed == storageLocation
          ? _value.storageLocation
          : storageLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      locationCode: freezed == locationCode
          ? _value.locationCode
          : locationCode // ignore: cast_nullable_to_non_nullable
              as String?,
      trackSerialNumber: null == trackSerialNumber
          ? _value.trackSerialNumber
          : trackSerialNumber // ignore: cast_nullable_to_non_nullable
              as bool,
      trackBatchNumber: null == trackBatchNumber
          ? _value.trackBatchNumber
          : trackBatchNumber // ignore: cast_nullable_to_non_nullable
              as bool,
      lastStockUpdate: freezed == lastStockUpdate
          ? _value.lastStockUpdate
          : lastStockUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      inventoryNotes: freezed == inventoryNotes
          ? _value.inventoryNotes
          : inventoryNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryConfigurationImpl implements _InventoryConfiguration {
  const _$InventoryConfigurationImpl(
      {this.isManaged = true,
      this.currentStock = 0,
      this.minStock,
      this.maxStock,
      this.reorderPoint,
      this.reorderQuantity,
      this.unit = 'unidad',
      this.allowNegativeStock = false,
      this.storageLocation,
      this.locationCode,
      this.trackSerialNumber = false,
      this.trackBatchNumber = false,
      this.lastStockUpdate,
      this.inventoryNotes});

  factory _$InventoryConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryConfigurationImplFromJson(json);

  /// Se gestiona inventario para este producto
  @override
  @JsonKey()
  final bool isManaged;

  /// Stock actual
  @override
  @JsonKey()
  final int currentStock;

  /// Stock mínimo (alerta de reposición)
  @override
  final int? minStock;

  /// Stock máximo recomendado
  @override
  final int? maxStock;

  /// Punto de reorden
  @override
  final int? reorderPoint;

  /// Cantidad de reorden
  @override
  final int? reorderQuantity;

  /// Unidad de medida
  @override
  @JsonKey()
  final String unit;

  /// Permite stock negativo
  @override
  @JsonKey()
  final bool allowNegativeStock;

  /// Ubicación en almacén
  @override
  final String? storageLocation;

  /// Código de ubicación
  @override
  final String? locationCode;

  /// Rastrea número de serie
  @override
  @JsonKey()
  final bool trackSerialNumber;

  /// Rastrea número de lote
  @override
  @JsonKey()
  final bool trackBatchNumber;

  /// Fecha de última actualización de stock
  @override
  final DateTime? lastStockUpdate;

  /// Notas de inventario
  @override
  final String? inventoryNotes;

  @override
  String toString() {
    return 'InventoryConfiguration(isManaged: $isManaged, currentStock: $currentStock, minStock: $minStock, maxStock: $maxStock, reorderPoint: $reorderPoint, reorderQuantity: $reorderQuantity, unit: $unit, allowNegativeStock: $allowNegativeStock, storageLocation: $storageLocation, locationCode: $locationCode, trackSerialNumber: $trackSerialNumber, trackBatchNumber: $trackBatchNumber, lastStockUpdate: $lastStockUpdate, inventoryNotes: $inventoryNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryConfigurationImpl &&
            (identical(other.isManaged, isManaged) ||
                other.isManaged == isManaged) &&
            (identical(other.currentStock, currentStock) ||
                other.currentStock == currentStock) &&
            (identical(other.minStock, minStock) ||
                other.minStock == minStock) &&
            (identical(other.maxStock, maxStock) ||
                other.maxStock == maxStock) &&
            (identical(other.reorderPoint, reorderPoint) ||
                other.reorderPoint == reorderPoint) &&
            (identical(other.reorderQuantity, reorderQuantity) ||
                other.reorderQuantity == reorderQuantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.allowNegativeStock, allowNegativeStock) ||
                other.allowNegativeStock == allowNegativeStock) &&
            (identical(other.storageLocation, storageLocation) ||
                other.storageLocation == storageLocation) &&
            (identical(other.locationCode, locationCode) ||
                other.locationCode == locationCode) &&
            (identical(other.trackSerialNumber, trackSerialNumber) ||
                other.trackSerialNumber == trackSerialNumber) &&
            (identical(other.trackBatchNumber, trackBatchNumber) ||
                other.trackBatchNumber == trackBatchNumber) &&
            (identical(other.lastStockUpdate, lastStockUpdate) ||
                other.lastStockUpdate == lastStockUpdate) &&
            (identical(other.inventoryNotes, inventoryNotes) ||
                other.inventoryNotes == inventoryNotes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isManaged,
      currentStock,
      minStock,
      maxStock,
      reorderPoint,
      reorderQuantity,
      unit,
      allowNegativeStock,
      storageLocation,
      locationCode,
      trackSerialNumber,
      trackBatchNumber,
      lastStockUpdate,
      inventoryNotes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryConfigurationImplCopyWith<_$InventoryConfigurationImpl>
      get copyWith => __$$InventoryConfigurationImplCopyWithImpl<
          _$InventoryConfigurationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryConfigurationImplToJson(
      this,
    );
  }
}

abstract class _InventoryConfiguration implements InventoryConfiguration {
  const factory _InventoryConfiguration(
      {final bool isManaged,
      final int currentStock,
      final int? minStock,
      final int? maxStock,
      final int? reorderPoint,
      final int? reorderQuantity,
      final String unit,
      final bool allowNegativeStock,
      final String? storageLocation,
      final String? locationCode,
      final bool trackSerialNumber,
      final bool trackBatchNumber,
      final DateTime? lastStockUpdate,
      final String? inventoryNotes}) = _$InventoryConfigurationImpl;

  factory _InventoryConfiguration.fromJson(Map<String, dynamic> json) =
      _$InventoryConfigurationImpl.fromJson;

  @override

  /// Se gestiona inventario para este producto
  bool get isManaged;
  @override

  /// Stock actual
  int get currentStock;
  @override

  /// Stock mínimo (alerta de reposición)
  int? get minStock;
  @override

  /// Stock máximo recomendado
  int? get maxStock;
  @override

  /// Punto de reorden
  int? get reorderPoint;
  @override

  /// Cantidad de reorden
  int? get reorderQuantity;
  @override

  /// Unidad de medida
  String get unit;
  @override

  /// Permite stock negativo
  bool get allowNegativeStock;
  @override

  /// Ubicación en almacén
  String? get storageLocation;
  @override

  /// Código de ubicación
  String? get locationCode;
  @override

  /// Rastrea número de serie
  bool get trackSerialNumber;
  @override

  /// Rastrea número de lote
  bool get trackBatchNumber;
  @override

  /// Fecha de última actualización de stock
  DateTime? get lastStockUpdate;
  @override

  /// Notas de inventario
  String? get inventoryNotes;
  @override
  @JsonKey(ignore: true)
  _$$InventoryConfigurationImplCopyWith<_$InventoryConfigurationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
