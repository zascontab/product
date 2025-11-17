import 'package:drift/drift.dart';

/// Drift table for product persistence
/// Stores product data locally with sync capabilities
@DataClassName('ProductTableData')
class ProductTable extends Table {
  @override
  String get tableName => 'products';

  // ========== Primary Key ==========
  TextColumn get id => text()();

  // ========== Timestamps ==========
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // ========== Metadata ==========
  TextColumn get createdBy => text().withDefault(const Constant(''))();
  TextColumn get updatedBy => text().withDefault(const Constant(''))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== Status ==========
  TextColumn get status => text().withDefault(const Constant('active'))();

  // ========== Sync Metadata ==========
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  // ========== Basic Information ==========
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();

  // ========== Identification ==========
  TextColumn get barcode => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get brand => text().nullable()();
  TextColumn get model => text().nullable()();

  // ========== Pricing ==========
  RealColumn get basePrice => real()();
  RealColumn get salePrice => real()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();

  // Price Configuration (JSON)
  TextColumn get priceConfig => text().nullable()();

  // ========== Inventory ==========
  BoolColumn get inventoryManaged => boolean().withDefault(const Constant(false))();
  IntColumn get currentStock => integer().withDefault(const Constant(0))();
  IntColumn get minStock => integer().nullable()();
  IntColumn get maxStock => integer().nullable()();
  IntColumn get reorderPoint => integer().nullable()();
  BoolColumn get allowNegativeStock => boolean().withDefault(const Constant(false))();
  TextColumn get unitOfMeasure => text().withDefault(const Constant('unit'))();

  // ========== Tax Configuration ==========
  RealColumn get ivaRate => real().withDefault(const Constant(15.0))();
  RealColumn get retentionRate => real().withDefault(const Constant(0.0))();
  RealColumn get ivaRetentionRate => real().withDefault(const Constant(0.0))();
  TextColumn get sriProductCode => text().withDefault(const Constant(''))();
  TextColumn get sriIvaCode => text().withDefault(const Constant('4'))(); // '4' = 15%
  BoolColumn get isIvaExempt => boolean().withDefault(const Constant(false))();
  BoolColumn get isRetentionExempt => boolean().withDefault(const Constant(false))();
  RealColumn get iceRate => real().withDefault(const Constant(0.0))();
  TextColumn get iceCode => text().nullable()();

  // ========== Categorization ==========
  TextColumn get category => text().withDefault(const Constant(''))();
  TextColumn get subcategory => text().nullable()();
  TextColumn get tags => text().nullable()(); // JSON array

  // ========== Product Type ==========
  TextColumn get productType => text().withDefault(const Constant('physical'))();
  TextColumn get productCategory => text().withDefault(const Constant('goods'))();
  BoolColumn get isService => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // ========== Media ==========
  TextColumn get primaryImage => text().nullable()();
  TextColumn get images => text().nullable()(); // JSON array

  // ========== Supplier Information ==========
  TextColumn get supplierId => text().nullable()();
  TextColumn get supplierProductCode => text().nullable()();
  RealColumn get supplierCost => real().nullable()();

  // ========== Dimensions & Weight ==========
  RealColumn get weight => real().nullable()();
  RealColumn get length => real().nullable()();
  RealColumn get width => real().nullable()();
  RealColumn get height => real().nullable()();

  // ========== Sales Data ==========
  DateTimeColumn get lastSaleDate => dateTime().nullable()();
  IntColumn get salesCount => integer().withDefault(const Constant(0))();
  RealColumn get totalSalesValue => real().withDefault(const Constant(0.0))();

  // ========== Additional Fields ==========
  TextColumn get notes => text().nullable()();
  TextColumn get customAttributes => text().nullable()(); // JSON object
  TextColumn get documentationUrl => text().nullable()();

  // ========== Multi-tenancy ==========
  TextColumn get tenantId => text().nullable()();
  TextColumn get companyId => text().nullable()();

  // ========== Dates ==========
  DateTimeColumn get launchDate => dateTime().nullable()();
  DateTimeColumn get discontinuationDate => dateTime().nullable()();
  DateTimeColumn get lastPriceUpdate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
