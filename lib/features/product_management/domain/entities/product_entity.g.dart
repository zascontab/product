// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductEntityImpl _$$ProductEntityImplFromJson(Map<String, dynamic> json) =>
    _$ProductEntityImpl(
      id: EntityIdentifier.fromJson(json['id'] as Map<String, dynamic>),
      metadata:
          EntityMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      status: EntityStatus.fromJson(json['status'] as Map<String, dynamic>),
      syncMeta: SyncMetadata.fromJson(json['syncMeta'] as Map<String, dynamic>),
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      barcode: json['barcode'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      category:
          $enumDecodeNullable(_$ProductCategoryEnumMap, json['category']) ??
              ProductCategory.goods,
      type: $enumDecodeNullable(_$ProductTypeEnumMap, json['type']) ??
          ProductType.physical,
      productStatus:
          $enumDecodeNullable(_$ProductStatusEnumMap, json['productStatus']) ??
              ProductStatus.active,
      taxConfig:
          TaxConfiguration.fromJson(json['taxConfig'] as Map<String, dynamic>),
      sriProductCode: json['sriProductCode'] as String?,
      basePrice: (json['basePrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      priceConfig: PriceConfiguration.fromJson(
          json['priceConfig'] as Map<String, dynamic>),
      inventoryConfig: InventoryConfiguration.fromJson(
          json['inventoryConfig'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool? ?? true,
      isService: json['isService'] as bool? ?? false,
      lastSaleDate: json['lastSaleDate'] == null
          ? null
          : DateTime.parse(json['lastSaleDate'] as String),
      salesCount: (json['salesCount'] as num?)?.toInt() ?? 0,
      totalSalesValue: (json['totalSalesValue'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      customFields: json['customFields'] as Map<String, dynamic>? ?? const {},
      supplierId: json['supplierId'] as String?,
      supplierProductCode: json['supplierProductCode'] as String?,
      supplierCost: (json['supplierCost'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      length: (json['length'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      additionalImages: (json['additionalImages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      documentationUrl: json['documentationUrl'] as String?,
      launchDate: json['launchDate'] == null
          ? null
          : DateTime.parse(json['launchDate'] as String),
      discontinuationDate: json['discontinuationDate'] == null
          ? null
          : DateTime.parse(json['discontinuationDate'] as String),
      lastPriceUpdate: json['lastPriceUpdate'] == null
          ? null
          : DateTime.parse(json['lastPriceUpdate'] as String),
    );

Map<String, dynamic> _$$ProductEntityImplToJson(_$ProductEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'metadata': instance.metadata,
      'status': instance.status,
      'syncMeta': instance.syncMeta,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'barcode': instance.barcode,
      'brand': instance.brand,
      'model': instance.model,
      'category': _$ProductCategoryEnumMap[instance.category]!,
      'type': _$ProductTypeEnumMap[instance.type]!,
      'productStatus': _$ProductStatusEnumMap[instance.productStatus]!,
      'taxConfig': instance.taxConfig,
      'sriProductCode': instance.sriProductCode,
      'basePrice': instance.basePrice,
      'salePrice': instance.salePrice,
      'currency': instance.currency,
      'priceConfig': instance.priceConfig,
      'inventoryConfig': instance.inventoryConfig,
      'isActive': instance.isActive,
      'isService': instance.isService,
      'lastSaleDate': instance.lastSaleDate?.toIso8601String(),
      'salesCount': instance.salesCount,
      'totalSalesValue': instance.totalSalesValue,
      'notes': instance.notes,
      'tags': instance.tags,
      'customFields': instance.customFields,
      'supplierId': instance.supplierId,
      'supplierProductCode': instance.supplierProductCode,
      'supplierCost': instance.supplierCost,
      'weight': instance.weight,
      'length': instance.length,
      'width': instance.width,
      'height': instance.height,
      'imageUrl': instance.imageUrl,
      'additionalImages': instance.additionalImages,
      'documentationUrl': instance.documentationUrl,
      'launchDate': instance.launchDate?.toIso8601String(),
      'discontinuationDate': instance.discontinuationDate?.toIso8601String(),
      'lastPriceUpdate': instance.lastPriceUpdate?.toIso8601String(),
    };

const _$ProductCategoryEnumMap = {
  ProductCategory.goods: 'goods',
  ProductCategory.services: 'services',
  ProductCategory.rawMaterials: 'rawMaterials',
  ProductCategory.supplies: 'supplies',
  ProductCategory.digital: 'digital',
  ProductCategory.consumables: 'consumables',
};

const _$ProductTypeEnumMap = {
  ProductType.physical: 'physical',
  ProductType.digital: 'digital',
  ProductType.service: 'service',
  ProductType.subscription: 'subscription',
  ProductType.combo: 'combo',
  ProductType.variable: 'variable',
};

const _$ProductStatusEnumMap = {
  ProductStatus.active: 'active',
  ProductStatus.inactive: 'inactive',
  ProductStatus.discontinued: 'discontinued',
  ProductStatus.draft: 'draft',
  ProductStatus.pending: 'pending',
};
