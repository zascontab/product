import 'dart:convert';
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_entity.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_sync_meta_data.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';
import 'package:rantipay_app/features/product_management/domain/entities/tax_configuration.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_enums.dart';
import '../database/product_table.dart';
import '../dtos/product_dto.dart';

/// Mapper for converting between ProductEntity, ProductDto, and ProductTableData
/// Handles bidirectional conversion for all three representations
class ProductMapper {
  /// Convert ProductEntity to ProductDto (for API)
  static ProductDto entityToDto(ProductEntity entity) {
    return ProductDto(
      id: entity.id.uniqueKey,
      createdAt: entity.metadata.createdAt,
      updatedAt: entity.metadata.modifiedAt,
      deletedAt: null,
      createdBy: entity.metadata.createdBy ?? '',
      updatedBy: entity.metadata.modifiedBy ?? '',
      version: entity.metadata.version,
      status: entity.status.type.name,
      code: entity.code,
      name: entity.name,
      description: entity.description,
      barcode: entity.barcode,
      sku: null, // Not in ProductEntity, map if needed
      brand: entity.brand,
      model: entity.model,
      basePrice: entity.basePrice,
      salePrice: entity.salePrice,
      currency: entity.currency,
      priceConfig: null, // Map PriceConfiguration if needed
      inventoryManaged: entity.inventoryConfig.isManaged,
      currentStock: entity.inventoryConfig.currentStock,
      minStock: entity.inventoryConfig.minStock,
      maxStock: entity.inventoryConfig.maxStock,
      reorderPoint: entity.inventoryConfig.reorderPoint,
      allowNegativeStock: entity.inventoryConfig.allowNegativeStock,
      unitOfMeasure: entity.inventoryConfig.unitOfMeasure ?? 'unit',
      ivaRate: entity.taxConfig.ivaRate,
      retentionRate: entity.taxConfig.retentionRate,
      ivaRetentionRate: entity.taxConfig.ivaRetentionRate,
      sriProductCode: entity.taxConfig.sriProductCode,
      sriIvaCode: entity.taxConfig.sriIvaCode,
      isIvaExempt: entity.taxConfig.isIvaExempt,
      isRetentionExempt: entity.taxConfig.isRetentionExempt,
      iceRate: entity.taxConfig.iceRate,
      iceCode: entity.taxConfig.iceCode,
      category: entity.category.code,
      subcategory: null,
      tags: entity.tags,
      productType: entity.type.code,
      productCategory: entity.category.code,
      isService: entity.isService,
      isActive: entity.isActive,
      primaryImage: entity.imageUrl,
      images: entity.additionalImages,
      supplierId: entity.supplierId,
      supplierProductCode: entity.supplierProductCode,
      supplierCost: entity.supplierCost,
      weight: entity.weight,
      length: entity.length,
      width: entity.width,
      height: entity.height,
      lastSaleDate: entity.lastSaleDate,
      salesCount: entity.salesCount,
      totalSalesValue: entity.totalSalesValue,
      notes: entity.notes,
      customAttributes: entity.customFields,
      documentationUrl: entity.documentationUrl,
      tenantId: null,
      companyId: null,
      launchDate: entity.launchDate,
      discontinuationDate: entity.discontinuationDate,
      lastPriceUpdate: entity.lastPriceUpdate,
    );
  }

  /// Convert ProductDto to ProductEntity (from API)
  static ProductEntity dtoToEntity(ProductDto dto) {
    return ProductEntity(
      id: EntityIdentifier.server(dto.id),
      metadata: EntityMetadata(
        createdAt: dto.createdAt,
        modifiedAt: dto.updatedAt,
        version: dto.version,
        createdBy: dto.createdBy,
        modifiedBy: dto.updatedBy,
      ),
      status: _mapStatus(dto.status),
      syncMeta: SyncMetadata.synced(),
      code: dto.code,
      name: dto.name,
      description: dto.description,
      barcode: dto.barcode,
      brand: dto.brand,
      model: dto.model,
      category: _mapCategory(dto.category),
      type: _mapProductType(dto.productType),
      productStatus: _mapProductStatus(dto.status),
      taxConfig: TaxConfiguration(
        ivaRate: dto.ivaRate,
        retentionRate: dto.retentionRate,
        ivaRetentionRate: dto.ivaRetentionRate,
        sriProductCode: dto.sriProductCode,
        sriIvaCode: dto.sriIvaCode,
        isIvaExempt: dto.isIvaExempt,
        isRetentionExempt: dto.isRetentionExempt,
        iceRate: dto.iceRate,
        iceCode: dto.iceCode,
      ),
      basePrice: dto.basePrice,
      salePrice: dto.salePrice,
      currency: dto.currency,
      priceConfig: PriceConfiguration(), // Use defaults for now
      inventoryConfig: InventoryConfiguration(
        isManaged: dto.inventoryManaged,
        currentStock: dto.currentStock,
        minStock: dto.minStock,
        maxStock: dto.maxStock,
        reorderPoint: dto.reorderPoint,
        allowNegativeStock: dto.allowNegativeStock,
        unitOfMeasure: dto.unitOfMeasure,
      ),
      isActive: dto.isActive,
      isService: dto.isService,
      lastSaleDate: dto.lastSaleDate,
      salesCount: dto.salesCount,
      totalSalesValue: dto.totalSalesValue,
      notes: dto.notes,
      tags: dto.tags ?? [],
      customFields: dto.customAttributes ?? {},
      supplierId: dto.supplierId,
      supplierProductCode: dto.supplierProductCode,
      supplierCost: dto.supplierCost,
      weight: dto.weight,
      length: dto.length,
      width: dto.width,
      height: dto.height,
      imageUrl: dto.primaryImage,
      additionalImages: dto.images ?? [],
      documentationUrl: dto.documentationUrl,
      launchDate: dto.launchDate,
      discontinuationDate: dto.discontinuationDate,
      lastPriceUpdate: dto.lastPriceUpdate,
    );
  }

  /// Convert ProductEntity to ProductTableData (for local DB)
  static ProductTableData entityToTableData(ProductEntity entity) {
    return ProductTableData(
      id: entity.id.uniqueKey,
      createdAt: entity.metadata.createdAt,
      updatedAt: entity.metadata.modifiedAt,
      deletedAt: null,
      createdBy: entity.metadata.createdBy ?? '',
      updatedBy: entity.metadata.modifiedBy ?? '',
      version: entity.metadata.version,
      status: entity.status.type.name,
      isSynced: entity.syncMeta.state == SyncState.synced,
      lastSyncAt: entity.syncMeta.lastSyncAt,
      syncStatus: entity.syncMeta.state.name,
      code: entity.code,
      name: entity.name,
      description: entity.description,
      barcode: entity.barcode,
      sku: null,
      brand: entity.brand,
      model: entity.model,
      basePrice: entity.basePrice,
      salePrice: entity.salePrice,
      currency: entity.currency,
      priceConfig: null,
      inventoryManaged: entity.inventoryConfig.isManaged,
      currentStock: entity.inventoryConfig.currentStock,
      minStock: entity.inventoryConfig.minStock,
      maxStock: entity.inventoryConfig.maxStock,
      reorderPoint: entity.inventoryConfig.reorderPoint,
      allowNegativeStock: entity.inventoryConfig.allowNegativeStock,
      unitOfMeasure: entity.inventoryConfig.unitOfMeasure ?? 'unit',
      ivaRate: entity.taxConfig.ivaRate,
      retentionRate: entity.taxConfig.retentionRate,
      ivaRetentionRate: entity.taxConfig.ivaRetentionRate,
      sriProductCode: entity.taxConfig.sriProductCode,
      sriIvaCode: entity.taxConfig.sriIvaCode,
      isIvaExempt: entity.taxConfig.isIvaExempt,
      isRetentionExempt: entity.taxConfig.isRetentionExempt,
      iceRate: entity.taxConfig.iceRate,
      iceCode: entity.taxConfig.iceCode,
      category: entity.category.code,
      subcategory: null,
      tags: entity.tags.isNotEmpty ? jsonEncode(entity.tags) : null,
      productType: entity.type.code,
      productCategory: entity.category.code,
      isService: entity.isService,
      isActive: entity.isActive,
      primaryImage: entity.imageUrl,
      images: entity.additionalImages.isNotEmpty ? jsonEncode(entity.additionalImages) : null,
      supplierId: entity.supplierId,
      supplierProductCode: entity.supplierProductCode,
      supplierCost: entity.supplierCost,
      weight: entity.weight,
      length: entity.length,
      width: entity.width,
      height: entity.height,
      lastSaleDate: entity.lastSaleDate,
      salesCount: entity.salesCount,
      totalSalesValue: entity.totalSalesValue,
      notes: entity.notes,
      customAttributes: entity.customFields.isNotEmpty ? jsonEncode(entity.customFields) : null,
      documentationUrl: entity.documentationUrl,
      tenantId: null,
      companyId: null,
      launchDate: entity.launchDate,
      discontinuationDate: entity.discontinuationDate,
      lastPriceUpdate: entity.lastPriceUpdate,
    );
  }

  /// Convert ProductTableData to ProductEntity (from local DB)
  static ProductEntity tableDataToEntity(ProductTableData data) {
    return ProductEntity(
      id: EntityIdentifier.server(data.id),
      metadata: EntityMetadata(
        createdAt: data.createdAt,
        modifiedAt: data.updatedAt,
        version: data.version,
        createdBy: data.createdBy,
        modifiedBy: data.updatedBy,
      ),
      status: _mapStatus(data.status),
      syncMeta: SyncMetadata(
        state: _mapSyncState(data.syncStatus),
        lastSyncAt: data.lastSyncAt,
        lastAttemptAt: data.lastSyncAt,
        failureReason: null,
      ),
      code: data.code,
      name: data.name,
      description: data.description,
      barcode: data.barcode,
      brand: data.brand,
      model: data.model,
      category: _mapCategory(data.category),
      type: _mapProductType(data.productType),
      productStatus: _mapProductStatus(data.status),
      taxConfig: TaxConfiguration(
        ivaRate: data.ivaRate,
        retentionRate: data.retentionRate,
        ivaRetentionRate: data.ivaRetentionRate,
        sriProductCode: data.sriProductCode,
        sriIvaCode: data.sriIvaCode,
        isIvaExempt: data.isIvaExempt,
        isRetentionExempt: data.isRetentionExempt,
        iceRate: data.iceRate,
        iceCode: data.iceCode,
      ),
      basePrice: data.basePrice,
      salePrice: data.salePrice,
      currency: data.currency,
      priceConfig: PriceConfiguration(),
      inventoryConfig: InventoryConfiguration(
        isManaged: data.inventoryManaged,
        currentStock: data.currentStock,
        minStock: data.minStock,
        maxStock: data.maxStock,
        reorderPoint: data.reorderPoint,
        allowNegativeStock: data.allowNegativeStock,
        unitOfMeasure: data.unitOfMeasure,
      ),
      isActive: data.isActive,
      isService: data.isService,
      lastSaleDate: data.lastSaleDate,
      salesCount: data.salesCount,
      totalSalesValue: data.totalSalesValue,
      notes: data.notes,
      tags: data.tags != null ? List<String>.from(jsonDecode(data.tags!)) : [],
      customFields: data.customAttributes != null ? Map<String, dynamic>.from(jsonDecode(data.customAttributes!)) : {},
      supplierId: data.supplierId,
      supplierProductCode: data.supplierProductCode,
      supplierCost: data.supplierCost,
      weight: data.weight,
      length: data.length,
      width: data.width,
      height: data.height,
      imageUrl: data.primaryImage,
      additionalImages: data.images != null ? List<String>.from(jsonDecode(data.images!)) : [],
      documentationUrl: data.documentationUrl,
      launchDate: data.launchDate,
      discontinuationDate: data.discontinuationDate,
      lastPriceUpdate: data.lastPriceUpdate,
    );
  }

  /// Helper: Map string status to EntityStatus
  static EntityStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return EntityStatus.draft();
      case 'active':
        return EntityStatus.active();
      case 'archived':
        return EntityStatus.archived();
      case 'deleted':
        return EntityStatus.deleted();
      case 'suspended':
        return EntityStatus.suspended(reason: 'Suspended');
      default:
        return EntityStatus.active();
    }
  }

  /// Helper: Map string to SyncState
  static SyncState _mapSyncState(String syncStatus) {
    switch (syncStatus.toLowerCase()) {
      case 'synced':
        return SyncState.synced;
      case 'pending':
        return SyncState.pending;
      case 'failed':
        return SyncState.failed;
      case 'conflict':
        return SyncState.conflict;
      default:
        return SyncState.notSynced;
    }
  }

  /// Helper: Map string to ProductCategory
  static ProductCategory _mapCategory(String category) {
    switch (category.toLowerCase()) {
      case 'goods':
        return ProductCategory.goods;
      case 'services':
        return ProductCategory.services;
      case 'electronics':
        return ProductCategory.electronics;
      case 'food':
        return ProductCategory.food;
      case 'clothing':
        return ProductCategory.clothing;
      case 'automotive':
        return ProductCategory.automotive;
      case 'healthcare':
        return ProductCategory.healthcare;
      case 'education':
        return ProductCategory.education;
      case 'entertainment':
        return ProductCategory.entertainment;
      case 'other':
        return ProductCategory.other;
      default:
        return ProductCategory.goods;
    }
  }

  /// Helper: Map string to ProductType
  static ProductType _mapProductType(String type) {
    switch (type.toLowerCase()) {
      case 'physical':
        return ProductType.physical;
      case 'digital':
        return ProductType.digital;
      case 'service':
        return ProductType.service;
      case 'subscription':
        return ProductType.subscription;
      default:
        return ProductType.physical;
    }
  }

  /// Helper: Map string to ProductStatus
  static ProductStatus _mapProductStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return ProductStatus.active;
      case 'inactive':
        return ProductStatus.inactive;
      case 'discontinued':
        return ProductStatus.discontinued;
      case 'outofstock':
        return ProductStatus.outOfStock;
      default:
        return ProductStatus.active;
    }
  }

  /// Convert list of DTOs to list of Entities
  static List<ProductEntity> dtoListToEntityList(List<ProductDto> dtos) {
    return dtos.map((dto) => dtoToEntity(dto)).toList();
  }

  /// Convert list of Entities to list of DTOs
  static List<ProductDto> entityListToDtoList(List<ProductEntity> entities) {
    return entities.map((entity) => entityToDto(entity)).toList();
  }

  /// Convert list of TableData to list of Entities
  static List<ProductEntity> tableDataListToEntityList(List<ProductTableData> dataList) {
    return dataList.map((data) => tableDataToEntity(data)).toList();
  }

  /// Convert list of Entities to list of TableData
  static List<ProductTableData> entityListToTableDataList(List<ProductEntity> entities) {
    return entities.map((entity) => entityToTableData(entity)).toList();
  }
}
