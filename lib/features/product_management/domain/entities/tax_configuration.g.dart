// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaxConfigurationImpl _$$TaxConfigurationImplFromJson(
        Map<String, dynamic> json) =>
    _$TaxConfigurationImpl(
      ivaRate: (json['ivaRate'] as num?)?.toDouble() ?? 12.0,
      retentionRate: (json['retentionRate'] as num?)?.toDouble() ?? 0.0,
      ivaRetentionRate: (json['ivaRetentionRate'] as num?)?.toDouble() ?? 0.0,
      sriProductCode: json['sriProductCode'] as String,
      sriIvaCode: json['sriIvaCode'] as String,
      isIvaExempt: json['isIvaExempt'] as bool? ?? false,
      isRetentionExempt: json['isRetentionExempt'] as bool? ?? false,
      isIceSubject: json['isIceSubject'] as bool? ?? false,
      iceRate: (json['iceRate'] as num?)?.toDouble() ?? 0.0,
      sriIceCode: json['sriIceCode'] as String?,
      sriRetentionCode: json['sriRetentionCode'] as String?,
      fiscalNotes: json['fiscalNotes'] as String?,
      lastFiscalUpdate: json['lastFiscalUpdate'] == null
          ? null
          : DateTime.parse(json['lastFiscalUpdate'] as String),
    );

Map<String, dynamic> _$$TaxConfigurationImplToJson(
        _$TaxConfigurationImpl instance) =>
    <String, dynamic>{
      'ivaRate': instance.ivaRate,
      'retentionRate': instance.retentionRate,
      'ivaRetentionRate': instance.ivaRetentionRate,
      'sriProductCode': instance.sriProductCode,
      'sriIvaCode': instance.sriIvaCode,
      'isIvaExempt': instance.isIvaExempt,
      'isRetentionExempt': instance.isRetentionExempt,
      'isIceSubject': instance.isIceSubject,
      'iceRate': instance.iceRate,
      'sriIceCode': instance.sriIceCode,
      'sriRetentionCode': instance.sriRetentionCode,
      'fiscalNotes': instance.fiscalNotes,
      'lastFiscalUpdate': instance.lastFiscalUpdate?.toIso8601String(),
    };

_$PriceConfigurationImpl _$$PriceConfigurationImplFromJson(
        Map<String, dynamic> json) =>
    _$PriceConfigurationImpl(
      allowDiscount: json['allowDiscount'] as bool? ?? true,
      maxDiscountPercent:
          (json['maxDiscountPercent'] as num?)?.toDouble() ?? 100.0,
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      hasPriceVariants: json['hasPriceVariants'] as bool? ?? false,
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => PriceVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isNegotiable: json['isNegotiable'] as bool? ?? false,
      requiresDiscountApproval:
          json['requiresDiscountApproval'] as bool? ?? false,
      profitMargin: (json['profitMargin'] as num?)?.toDouble(),
      baseCost: (json['baseCost'] as num?)?.toDouble(),
      priceIncludesTax: json['priceIncludesTax'] as bool? ?? true,
      currency: json['currency'] as String? ?? 'USD',
      rounding: $enumDecodeNullable(_$PriceRoundingEnumMap, json['rounding']) ??
          PriceRounding.twoDecimals,
    );

Map<String, dynamic> _$$PriceConfigurationImplToJson(
        _$PriceConfigurationImpl instance) =>
    <String, dynamic>{
      'allowDiscount': instance.allowDiscount,
      'maxDiscountPercent': instance.maxDiscountPercent,
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'hasPriceVariants': instance.hasPriceVariants,
      'variants': instance.variants,
      'isNegotiable': instance.isNegotiable,
      'requiresDiscountApproval': instance.requiresDiscountApproval,
      'profitMargin': instance.profitMargin,
      'baseCost': instance.baseCost,
      'priceIncludesTax': instance.priceIncludesTax,
      'currency': instance.currency,
      'rounding': _$PriceRoundingEnumMap[instance.rounding]!,
    };

const _$PriceRoundingEnumMap = {
  PriceRounding.noRounding: 'noRounding',
  PriceRounding.oneDecimal: 'oneDecimal',
  PriceRounding.twoDecimals: 'twoDecimals',
  PriceRounding.nearestFive: 'nearestFive',
  PriceRounding.nearestTen: 'nearestTen',
};

_$PriceVariantImpl _$$PriceVariantImplFromJson(Map<String, dynamic> json) =>
    _$PriceVariantImpl(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      minQuantity: (json['minQuantity'] as num?)?.toInt() ?? 1,
      maxQuantity: (json['maxQuantity'] as num?)?.toInt(),
      customerType: json['customerType'] as String?,
      automaticDiscount: (json['automaticDiscount'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      validFrom: json['validFrom'] == null
          ? null
          : DateTime.parse(json['validFrom'] as String),
      validTo: json['validTo'] == null
          ? null
          : DateTime.parse(json['validTo'] as String),
    );

Map<String, dynamic> _$$PriceVariantImplToJson(_$PriceVariantImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'minQuantity': instance.minQuantity,
      'maxQuantity': instance.maxQuantity,
      'customerType': instance.customerType,
      'automaticDiscount': instance.automaticDiscount,
      'isActive': instance.isActive,
      'validFrom': instance.validFrom?.toIso8601String(),
      'validTo': instance.validTo?.toIso8601String(),
    };

_$InventoryConfigurationImpl _$$InventoryConfigurationImplFromJson(
        Map<String, dynamic> json) =>
    _$InventoryConfigurationImpl(
      isManaged: json['isManaged'] as bool? ?? true,
      currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
      minStock: (json['minStock'] as num?)?.toInt(),
      maxStock: (json['maxStock'] as num?)?.toInt(),
      reorderPoint: (json['reorderPoint'] as num?)?.toInt(),
      reorderQuantity: (json['reorderQuantity'] as num?)?.toInt(),
      unit: json['unit'] as String? ?? 'unidad',
      allowNegativeStock: json['allowNegativeStock'] as bool? ?? false,
      storageLocation: json['storageLocation'] as String?,
      locationCode: json['locationCode'] as String?,
      trackSerialNumber: json['trackSerialNumber'] as bool? ?? false,
      trackBatchNumber: json['trackBatchNumber'] as bool? ?? false,
      lastStockUpdate: json['lastStockUpdate'] == null
          ? null
          : DateTime.parse(json['lastStockUpdate'] as String),
      inventoryNotes: json['inventoryNotes'] as String?,
    );

Map<String, dynamic> _$$InventoryConfigurationImplToJson(
        _$InventoryConfigurationImpl instance) =>
    <String, dynamic>{
      'isManaged': instance.isManaged,
      'currentStock': instance.currentStock,
      'minStock': instance.minStock,
      'maxStock': instance.maxStock,
      'reorderPoint': instance.reorderPoint,
      'reorderQuantity': instance.reorderQuantity,
      'unit': instance.unit,
      'allowNegativeStock': instance.allowNegativeStock,
      'storageLocation': instance.storageLocation,
      'locationCode': instance.locationCode,
      'trackSerialNumber': instance.trackSerialNumber,
      'trackBatchNumber': instance.trackBatchNumber,
      'lastStockUpdate': instance.lastStockUpdate?.toIso8601String(),
      'inventoryNotes': instance.inventoryNotes,
    };
