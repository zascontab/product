import 'dart:convert';

/// Data Transfer Object for Product API communication
/// Handles JSON serialization/deserialization for backend API
class ProductDto {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String createdBy;
  final String updatedBy;
  final int version;
  final String status;

  // Basic Information
  final String code;
  final String name;
  final String description;

  // Identification
  final String? barcode;
  final String? sku;
  final String? brand;
  final String? model;

  // Pricing
  final double basePrice;
  final double salePrice;
  final String currency;
  final Map<String, dynamic>? priceConfig;

  // Inventory
  final bool inventoryManaged;
  final int currentStock;
  final int? minStock;
  final int? maxStock;
  final int? reorderPoint;
  final bool allowNegativeStock;
  final String unitOfMeasure;

  // Tax Configuration
  final double ivaRate;
  final double retentionRate;
  final double ivaRetentionRate;
  final String sriProductCode;
  final String sriIvaCode;
  final bool isIvaExempt;
  final bool isRetentionExempt;
  final double iceRate;
  final String? iceCode;

  // Categorization
  final String category;
  final String? subcategory;
  final List<String>? tags;

  // Product Type
  final String productType;
  final String productCategory;
  final bool isService;
  final bool isActive;

  // Media
  final String? primaryImage;
  final List<String>? images;

  // Supplier Information
  final String? supplierId;
  final String? supplierProductCode;
  final double? supplierCost;

  // Dimensions & Weight
  final double? weight;
  final double? length;
  final double? width;
  final double? height;

  // Sales Data
  final DateTime? lastSaleDate;
  final int salesCount;
  final double totalSalesValue;

  // Additional Fields
  final String? notes;
  final Map<String, dynamic>? customAttributes;
  final String? documentationUrl;

  // Multi-tenancy
  final String? tenantId;
  final String? companyId;

  // Dates
  final DateTime? launchDate;
  final DateTime? discontinuationDate;
  final DateTime? lastPriceUpdate;

  ProductDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.version,
    required this.status,
    required this.code,
    required this.name,
    required this.description,
    this.barcode,
    this.sku,
    this.brand,
    this.model,
    required this.basePrice,
    required this.salePrice,
    required this.currency,
    this.priceConfig,
    required this.inventoryManaged,
    required this.currentStock,
    this.minStock,
    this.maxStock,
    this.reorderPoint,
    required this.allowNegativeStock,
    required this.unitOfMeasure,
    required this.ivaRate,
    required this.retentionRate,
    required this.ivaRetentionRate,
    required this.sriProductCode,
    required this.sriIvaCode,
    required this.isIvaExempt,
    required this.isRetentionExempt,
    required this.iceRate,
    this.iceCode,
    required this.category,
    this.subcategory,
    this.tags,
    required this.productType,
    required this.productCategory,
    required this.isService,
    required this.isActive,
    this.primaryImage,
    this.images,
    this.supplierId,
    this.supplierProductCode,
    this.supplierCost,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.lastSaleDate,
    required this.salesCount,
    required this.totalSalesValue,
    this.notes,
    this.customAttributes,
    this.documentationUrl,
    this.tenantId,
    this.companyId,
    this.launchDate,
    this.discontinuationDate,
    this.lastPriceUpdate,
  });

  /// Create DTO from JSON map
  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
      createdBy: json['createdBy'] as String? ?? '',
      updatedBy: json['updatedBy'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      status: json['status'] as String? ?? 'active',
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      barcode: json['barcode'] as String?,
      sku: json['sku'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      basePrice: (json['basePrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      priceConfig: json['priceConfig'] as Map<String, dynamic>?,
      inventoryManaged: json['inventoryManaged'] as bool? ?? false,
      currentStock: json['currentStock'] as int? ?? 0,
      minStock: json['minStock'] as int?,
      maxStock: json['maxStock'] as int?,
      reorderPoint: json['reorderPoint'] as int?,
      allowNegativeStock: json['allowNegativeStock'] as bool? ?? false,
      unitOfMeasure: json['unitOfMeasure'] as String? ?? 'unit',
      ivaRate: (json['ivaRate'] as num?)?.toDouble() ?? 15.0,
      retentionRate: (json['retentionRate'] as num?)?.toDouble() ?? 0.0,
      ivaRetentionRate: (json['ivaRetentionRate'] as num?)?.toDouble() ?? 0.0,
      sriProductCode: json['sriProductCode'] as String? ?? '',
      sriIvaCode: json['sriIvaCode'] as String? ?? '4', // 15% IVA
      isIvaExempt: json['isIvaExempt'] as bool? ?? false,
      isRetentionExempt: json['isRetentionExempt'] as bool? ?? false,
      iceRate: (json['iceRate'] as num?)?.toDouble() ?? 0.0,
      iceCode: json['iceCode'] as String?,
      category: json['category'] as String? ?? '',
      subcategory: json['subcategory'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      productType: json['productType'] as String? ?? 'physical',
      productCategory: json['productCategory'] as String? ?? 'goods',
      isService: json['isService'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      primaryImage: json['primaryImage'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      supplierId: json['supplierId'] as String?,
      supplierProductCode: json['supplierProductCode'] as String?,
      supplierCost: (json['supplierCost'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      length: (json['length'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      lastSaleDate: json['lastSaleDate'] != null ? DateTime.parse(json['lastSaleDate'] as String) : null,
      salesCount: json['salesCount'] as int? ?? 0,
      totalSalesValue: (json['totalSalesValue'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      customAttributes: json['customAttributes'] as Map<String, dynamic>?,
      documentationUrl: json['documentationUrl'] as String?,
      tenantId: json['tenantId'] as String?,
      companyId: json['companyId'] as String?,
      launchDate: json['launchDate'] != null ? DateTime.parse(json['launchDate'] as String) : null,
      discontinuationDate: json['discontinuationDate'] != null ? DateTime.parse(json['discontinuationDate'] as String) : null,
      lastPriceUpdate: json['lastPriceUpdate'] != null ? DateTime.parse(json['lastPriceUpdate'] as String) : null,
    );
  }

  /// Convert DTO to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'version': version,
      'status': status,
      'code': code,
      'name': name,
      'description': description,
      if (barcode != null) 'barcode': barcode,
      if (sku != null) 'sku': sku,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      'basePrice': basePrice,
      'salePrice': salePrice,
      'currency': currency,
      if (priceConfig != null) 'priceConfig': priceConfig,
      'inventoryManaged': inventoryManaged,
      'currentStock': currentStock,
      if (minStock != null) 'minStock': minStock,
      if (maxStock != null) 'maxStock': maxStock,
      if (reorderPoint != null) 'reorderPoint': reorderPoint,
      'allowNegativeStock': allowNegativeStock,
      'unitOfMeasure': unitOfMeasure,
      'ivaRate': ivaRate,
      'retentionRate': retentionRate,
      'ivaRetentionRate': ivaRetentionRate,
      'sriProductCode': sriProductCode,
      'sriIvaCode': sriIvaCode,
      'isIvaExempt': isIvaExempt,
      'isRetentionExempt': isRetentionExempt,
      'iceRate': iceRate,
      if (iceCode != null) 'iceCode': iceCode,
      'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (tags != null) 'tags': tags,
      'productType': productType,
      'productCategory': productCategory,
      'isService': isService,
      'isActive': isActive,
      if (primaryImage != null) 'primaryImage': primaryImage,
      if (images != null) 'images': images,
      if (supplierId != null) 'supplierId': supplierId,
      if (supplierProductCode != null) 'supplierProductCode': supplierProductCode,
      if (supplierCost != null) 'supplierCost': supplierCost,
      if (weight != null) 'weight': weight,
      if (length != null) 'length': length,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (lastSaleDate != null) 'lastSaleDate': lastSaleDate!.toIso8601String(),
      'salesCount': salesCount,
      'totalSalesValue': totalSalesValue,
      if (notes != null) 'notes': notes,
      if (customAttributes != null) 'customAttributes': customAttributes,
      if (documentationUrl != null) 'documentationUrl': documentationUrl,
      if (tenantId != null) 'tenantId': tenantId,
      if (companyId != null) 'companyId': companyId,
      if (launchDate != null) 'launchDate': launchDate!.toIso8601String(),
      if (discontinuationDate != null) 'discontinuationDate': discontinuationDate!.toIso8601String(),
      if (lastPriceUpdate != null) 'lastPriceUpdate': lastPriceUpdate!.toIso8601String(),
    };
  }

  /// Copy with method for immutability
  ProductDto copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? createdBy,
    String? updatedBy,
    int? version,
    String? status,
    String? code,
    String? name,
    String? description,
    String? barcode,
    String? sku,
    String? brand,
    String? model,
    double? basePrice,
    double? salePrice,
    String? currency,
    Map<String, dynamic>? priceConfig,
    bool? inventoryManaged,
    int? currentStock,
    int? minStock,
    int? maxStock,
    int? reorderPoint,
    bool? allowNegativeStock,
    String? unitOfMeasure,
    double? ivaRate,
    double? retentionRate,
    double? ivaRetentionRate,
    String? sriProductCode,
    String? sriIvaCode,
    bool? isIvaExempt,
    bool? isRetentionExempt,
    double? iceRate,
    String? iceCode,
    String? category,
    String? subcategory,
    List<String>? tags,
    String? productType,
    String? productCategory,
    bool? isService,
    bool? isActive,
    String? primaryImage,
    List<String>? images,
    String? supplierId,
    String? supplierProductCode,
    double? supplierCost,
    double? weight,
    double? length,
    double? width,
    double? height,
    DateTime? lastSaleDate,
    int? salesCount,
    double? totalSalesValue,
    String? notes,
    Map<String, dynamic>? customAttributes,
    String? documentationUrl,
    String? tenantId,
    String? companyId,
    DateTime? launchDate,
    DateTime? discontinuationDate,
    DateTime? lastPriceUpdate,
  }) {
    return ProductDto(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      status: status ?? this.status,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      basePrice: basePrice ?? this.basePrice,
      salePrice: salePrice ?? this.salePrice,
      currency: currency ?? this.currency,
      priceConfig: priceConfig ?? this.priceConfig,
      inventoryManaged: inventoryManaged ?? this.inventoryManaged,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      allowNegativeStock: allowNegativeStock ?? this.allowNegativeStock,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      ivaRate: ivaRate ?? this.ivaRate,
      retentionRate: retentionRate ?? this.retentionRate,
      ivaRetentionRate: ivaRetentionRate ?? this.ivaRetentionRate,
      sriProductCode: sriProductCode ?? this.sriProductCode,
      sriIvaCode: sriIvaCode ?? this.sriIvaCode,
      isIvaExempt: isIvaExempt ?? this.isIvaExempt,
      isRetentionExempt: isRetentionExempt ?? this.isRetentionExempt,
      iceRate: iceRate ?? this.iceRate,
      iceCode: iceCode ?? this.iceCode,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      tags: tags ?? this.tags,
      productType: productType ?? this.productType,
      productCategory: productCategory ?? this.productCategory,
      isService: isService ?? this.isService,
      isActive: isActive ?? this.isActive,
      primaryImage: primaryImage ?? this.primaryImage,
      images: images ?? this.images,
      supplierId: supplierId ?? this.supplierId,
      supplierProductCode: supplierProductCode ?? this.supplierProductCode,
      supplierCost: supplierCost ?? this.supplierCost,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      lastSaleDate: lastSaleDate ?? this.lastSaleDate,
      salesCount: salesCount ?? this.salesCount,
      totalSalesValue: totalSalesValue ?? this.totalSalesValue,
      notes: notes ?? this.notes,
      customAttributes: customAttributes ?? this.customAttributes,
      documentationUrl: documentationUrl ?? this.documentationUrl,
      tenantId: tenantId ?? this.tenantId,
      companyId: companyId ?? this.companyId,
      launchDate: launchDate ?? this.launchDate,
      discontinuationDate: discontinuationDate ?? this.discontinuationDate,
      lastPriceUpdate: lastPriceUpdate ?? this.lastPriceUpdate,
    );
  }
}

/// API Response wrapper for product list
class ProductListResponseDto {
  final List<ProductDto> products;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  ProductListResponseDto({
    required this.products,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory ProductListResponseDto.fromJson(Map<String, dynamic> json) {
    return ProductListResponseDto(
      products: (json['products'] as List<dynamic>)
          .map((e) => ProductDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'pageSize': pageSize,
      'hasMore': hasMore,
    };
  }
}
