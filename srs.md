# Product Management CRUD - Software Requirements Specification (SRS)

**Version:** 1.0
**Date:** 2025-11-17
**Project:** RantiPay V2 - Electronic Invoicing Module
**Module:** Product Management System

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Current System Analysis](#2-current-system-analysis)
3. [Requirements Specification](#3-requirements-specification)
4. [System Architecture](#4-system-architecture)
5. [Database Design](#5-database-design)
6. [API Specification](#6-api-specification)
7. [UI/UX Design](#7-uiux-design)
8. [Implementation Plan](#8-implementation-plan)
9. [Testing Strategy](#9-testing-strategy)
10. [Migration & Deployment](#10-migration--deployment)

---

## 1. Executive Summary

### 1.1 Problem Statement

Currently, the RantiPay electronic invoicing system uses **hardcoded mock products** for invoice line items. This creates several critical issues:

1. **Outdated Tax Rates**: Mock products use 12% IVA instead of current 15%
2. **No Product Management**: Users cannot create, edit, or delete products
3. **Limited Functionality**: Cannot manage inventory, pricing, or tax configurations
4. **Backend Dependency**: System fails gracefully but relies on mock data
5. **Scalability Issues**: Cannot support multiple companies or real product catalogs

### 1.2 Solution Overview

Implement a **complete Product Management CRUD system** that:

- ✅ Integrates with existing electronic invoicing module
- ✅ Provides UI for product creation, editing, deletion
- ✅ Connects to backend API for real-time product data
- ✅ Supports dynamic tax rate configuration (15% IVA)
- ✅ Includes inventory management
- ✅ Maintains Clean Architecture principles
- ✅ Implements offline-first with local caching

### 1.3 Project Goals

| Goal | Priority | Status |
|------|----------|--------|
| Product CRUD UI screens | High | 🔴 Not Started |
| Backend API integration | High | 🔴 Not Started |
| Database schema & migrations | High | 🔴 Not Started |
| Tax configuration management | High | 🔴 Not Started |
| Inventory tracking | Medium | 🔴 Not Started |
| Product search & filters | Medium | 🟡 Partially Done |
| Bulk import/export | Low | 🔴 Not Started |
| Product analytics | Low | 🔴 Not Started |

---

## 2. Current System Analysis

### 2.1 Existing Architecture

**Module Location:** `lib/features/product_management/`

**Current Implementation Status:**

```
✅ Domain Layer (Complete)
   ├─ entities/
   │  ├─ product_entity.dart          ✅ Full entity with Freezed
   │  ├─ tax_configuration.dart       ✅ Tax config (12% → needs 15% update)
   │  └─ product_enums.dart           ✅ Status, category, type enums
   └─ repositories/
      └─ product_repository.dart      ✅ Complete interface with CRUD methods

✅ Application Layer (Complete)
   └─ blocs/
      ├─ product_bloc.dart            ✅ BLoC with search, filter, CRUD events
      └─ product_state.dart           ✅ States: loading, success, failure

⚠️ Infrastructure Layer (Mock Only)
   └─ repositories/
      └─ product_repository_mock.dart ⚠️ Hardcoded 5 products with 12% IVA

🔴 Presentation Layer (Minimal)
   ├─ pages/
   │  └─ product_selection_page.dart  ✅ Product picker for invoices
   └─ widgets/
      └─ product_search_widget.dart   ✅ Search bar widget

🔴 Missing Components
   ├─ infrastructure/
   │  ├─ api/
   │  │  └─ product_api_client.dart   🔴 NOT IMPLEMENTED
   │  ├─ dtos/
   │  │  └─ product_dto.dart          🔴 NOT IMPLEMENTED
   │  └─ mappers/
   │     └─ product_mapper.dart       🔴 NOT IMPLEMENTED
   └─ presentation/
      └─ pages/
         ├─ product_list_page.dart    🔴 NOT IMPLEMENTED
         ├─ product_create_page.dart  🔴 NOT IMPLEMENTED
         ├─ product_edit_page.dart    🔴 NOT IMPLEMENTED
         └─ product_detail_page.dart  🔴 NOT IMPLEMENTED
```

### 2.2 Integration Points

**Current Integration with Electronic Invoicing:**

```dart
// File: invoice_create_page.dart (Lines 210-336)
Future<void> _addProductToInvoice(ProductEntity product) async {
  // 1. Gets product from ProductBloc (via ProductSelectorWidget)
  // 2. Extracts: product.taxConfig.ivaRate (currently 12%)
  // 3. Attempts: MultiTaxCalculationService.calculateTaxes()
  // 4. Fallback: Uses product.taxConfig.ivaRate if backend unavailable
  // 5. Creates: InvoiceLineItemEntity with product data
}
```

**Key Integration Files:**
- `electronic_invoicing/presentation/widgets/invoice_create/product_selector_widget.dart`
  - Opens modal with product list
  - Calls `ProductBloc.getInvoiceableProducts()`
  - Returns selected `ProductEntity`

**Data Flow:**
```
ProductRepositoryMock → ProductBloc → ProductSelectorWidget → InvoiceCreatePage
```

### 2.3 Current Entity Structure

**ProductEntity** (Full-featured, 500+ lines):

```dart
@freezed
class ProductEntity with _$ProductEntity {
  const factory ProductEntity({
    required EntityIdentifier id,
    required EntityMetadata metadata,
    required EntityStatus status,
    required SyncMetadata syncMeta,

    // Basic Info
    required String code,              // Unique product code
    required String name,              // Product name
    required String description,

    // Identification
    String? barcode,                   // EAN/UPC barcode
    String? sku,                       // Stock Keeping Unit
    String? brand,
    String? model,

    // Pricing
    required double basePrice,         // Cost price
    required double salePrice,         // Selling price
    required PriceConfiguration priceConfig,

    // Inventory
    required InventoryConfiguration inventoryConfig,

    // Tax Configuration ⚠️
    required TaxConfiguration taxConfig,  // Contains ivaRate (12% → 15%)

    // Categorization
    String? category,
    String? subcategory,
    List<String>? tags,

    // Media
    List<String>? images,
    String? primaryImage,

    // Additional
    Map<String, dynamic>? customAttributes,

  }) = _ProductEntity;
}
```

**TaxConfiguration** (Tax details):

```dart
@freezed
class TaxConfiguration with _$TaxConfiguration {
  const factory TaxConfiguration({
    @Default(12.0) double ivaRate,        // ⚠️ NEEDS UPDATE TO 15.0
    @Default(0.0) double retentionRate,
    @Default(0.0) double ivaRetentionRate,
    required String sriProductCode,       // SRI product classification
    required String sriIvaCode,           // '0', '2', '3', '4' (15% = '4')
    @Default(false) bool isIvaExempt,
    @Default(false) bool isRetentionExempt,
    @Default(0.0) double iceRate,         // Special consumption tax
    String? iceCode,
  }) = _TaxConfiguration;
}
```

**Repository Interface Methods:**

```dart
abstract class IProductRepository {
  // Basic CRUD
  Future<(List<ProductEntity>?, FailureCommons?)> getEntities({int? limit, int? offset});
  Future<(ProductEntity?, FailureCommons?)> getEntityById(String id);
  Future<(ProductEntity?, FailureCommons?)> createEntity(ProductEntity entity);
  Future<(ProductEntity?, FailureCommons?)> updateEntity(ProductEntity entity);
  Future<(bool, FailureCommons?)> deleteEntity(String id);

  // Search & Filter
  Future<(List<ProductEntity>?, FailureCommons?)> searchProducts({required String query, int? limit, int? offset});
  Future<(List<ProductEntity>?, FailureCommons?)> getProductsByCategory(String category, {int? limit, int? offset});
  Future<(List<ProductEntity>?, FailureCommons?)> getProductsByStatus(String status, {int? limit, int? offset});
  Future<(List<ProductEntity>?, FailureCommons?)> getInvoiceableProducts({int? limit, int? offset});

  // Inventory
  Future<(List<ProductEntity>?, FailureCommons?)> getLowStockProducts({int? limit, int? offset});
  Future<(ProductEntity?, FailureCommons?)> updateStock({required String productId, required int newStock, String? reason});

  // Business Logic
  Future<(ProductEntity?, FailureCommons?)> findDuplicateProduct({required String name, required String category, String? brand, String? excludeId});
  Future<(bool, List<String>)> validateSale({required String productId, required int quantity});
  Future<(Map<String, dynamic>?, FailureCommons?)> getProductStats(String productId);
}
```

---

## 3. Requirements Specification

### 3.1 Functional Requirements

#### FR-1: Product Creation

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-1.1 | User can create new product with basic info | High | Form with name, code, description, prices |
| FR-1.2 | User can configure tax settings | High | IVA rate selector with 0%, 12%, 14%, 15% |
| FR-1.3 | User can set inventory configuration | Medium | Stock quantity, min/max levels, unit |
| FR-1.4 | System generates unique product code | High | Auto-generated if not provided |
| FR-1.5 | System validates required fields | High | Shows validation errors inline |
| FR-1.6 | System checks for duplicate products | Medium | Warns if similar product exists |
| FR-1.7 | System syncs to backend on save | High | Creates record in backend database |
| FR-1.8 | System caches locally for offline use | High | Stores in local Drift database |

#### FR-2: Product Listing & Search

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-2.1 | User can view list of all products | High | Paginated list with infinite scroll |
| FR-2.2 | User can search by name, code, barcode | High | Real-time search with debouncing |
| FR-2.3 | User can filter by category | Medium | Dropdown or chip filters |
| FR-2.4 | User can filter by status (active/inactive) | Medium | Toggle or checkbox filter |
| FR-2.5 | User can filter by stock level | Low | Low stock, out of stock filters |
| FR-2.6 | User can sort by name, price, date | Medium | Sort buttons with asc/desc |
| FR-2.7 | System shows product count & stats | Low | Total products, active, low stock |

#### FR-3: Product Editing

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-3.1 | User can edit existing product | High | Form pre-populated with current data |
| FR-3.2 | User can update prices | High | Base price, sale price, discounts |
| FR-3.3 | User can update tax configuration | High | Change IVA rate, exemptions |
| FR-3.4 | User can update inventory | High | Adjust stock, set min/max levels |
| FR-3.5 | User can activate/deactivate product | High | Status toggle with confirmation |
| FR-3.6 | System validates changes before save | High | Shows validation errors |
| FR-3.7 | System syncs updates to backend | High | PUT request with optimistic update |
| FR-3.8 | System handles concurrent edits | Medium | Last-write-wins or conflict detection |

#### FR-4: Product Deletion

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-4.1 | User can soft-delete product | High | Sets status to 'deleted', keeps record |
| FR-4.2 | System confirms deletion action | High | Shows confirmation dialog |
| FR-4.3 | System prevents deletion of used products | High | Checks if product in invoices |
| FR-4.4 | System syncs deletion to backend | High | DELETE or PATCH request |
| FR-4.5 | User can restore deleted products | Low | Undelete from trash/archive |

#### FR-5: Tax Configuration Management

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-5.1 | System uses dynamic tax rates from backend | **Critical** | Fetches from `/api/v1/taxes/rates` |
| FR-5.2 | User can select IVA rate: 0%, 12%, 14%, 15% | High | Dropdown with current rate default (15%) |
| FR-5.3 | System maps rate to SRI percentage code | High | 0%→'0', 12%→'2', 14%→'3', 15%→'4' |
| FR-5.4 | User can mark product as IVA exempt | Medium | Checkbox for exemption |
| FR-5.5 | User can configure ICE (special tax) | Low | ICE rate and code fields |
| FR-5.6 | System validates SRI product codes | Medium | Validates format and existence |

#### FR-6: Integration with Invoicing

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-6.1 | Products appear in invoice product picker | **Critical** | Calls `getInvoiceableProducts()` |
| FR-6.2 | Product tax config applies to invoice lines | **Critical** | Uses `product.taxConfig.ivaRate` |
| FR-6.3 | System uses dynamic tax calculation | High | Calls `MultiTaxCalculationService` |
| FR-6.4 | System falls back to product config | High | Uses `taxConfig` if backend fails |
| FR-6.5 | Product details populate invoice line item | High | Name, code, price, tax auto-fill |
| FR-6.6 | System validates stock before adding | Medium | Warns if insufficient stock |

### 3.2 Non-Functional Requirements

#### NFR-1: Performance

| ID | Requirement | Metric | Priority |
|----|-------------|--------|----------|
| NFR-1.1 | Product list loads in < 2 seconds | 2s | High |
| NFR-1.2 | Search results appear in < 500ms | 500ms | High |
| NFR-1.3 | Product creation completes in < 3s | 3s | Medium |
| NFR-1.4 | Supports 10,000+ products | 10k records | Medium |

#### NFR-2: Usability

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-2.1 | Mobile-responsive design (320px - 1920px) | High |
| NFR-2.2 | Accessible (WCAG 2.1 Level AA) | Medium |
| NFR-2.3 | Supports English and Spanish | High |
| NFR-2.4 | Intuitive UI requiring no training | High |

#### NFR-3: Reliability

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-3.1 | 99.9% uptime for CRUD operations | High |
| NFR-3.2 | Offline-first with automatic sync | High |
| NFR-3.3 | No data loss during network failures | Critical |
| NFR-3.4 | Graceful degradation to cached data | High |

#### NFR-4: Security

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-4.1 | User Level 2+ required for product creation | High |
| NFR-4.2 | User Level 3+ required for deletion | High |
| NFR-4.3 | Audit log for all product changes | Medium |
| NFR-4.4 | Validation prevents SQL injection | Critical |

---

## 4. System Architecture

### 4.1 Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐ │
│  │   Product List  │  │  Product Create │  │  Product Edit  │ │
│  │      Page       │  │      Page       │  │      Page      │ │
│  └────────┬────────┘  └────────┬────────┘  └────────┬───────┘ │
│           │                    │                     │          │
│           └────────────────────┼─────────────────────┘          │
│                                ▼                                │
│                       ┌─────────────────┐                       │
│                       │   ProductBloc   │                       │
│                       │   (Singleton)   │                       │
│                       └────────┬────────┘                       │
└────────────────────────────────┼──────────────────────────────┘
                                 │
┌────────────────────────────────┼──────────────────────────────┐
│                      APPLICATION LAYER                         │
│                                ▼                                │
│                       ┌─────────────────┐                       │
│                       │ IProductRepo    │                       │
│                       │   (Interface)   │                       │
│                       └────────┬────────┘                       │
└────────────────────────────────┼──────────────────────────────┘
                                 │
┌────────────────────────────────┼──────────────────────────────┐
│                    INFRASTRUCTURE LAYER                         │
│                                ▼                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │           ProductRepositoryImpl (NEW)                     │ │
│  │  ┌─────────────────────┐  ┌──────────────────────────┐  │ │
│  │  │ Local Data Source   │  │  Remote Data Source      │  │ │
│  │  │   (Drift DB)        │  │  (ProductApiClient)      │  │ │
│  │  └──────────┬──────────┘  └───────────┬──────────────┘  │ │
│  └─────────────┼─────────────────────────┼─────────────────┘ │
│                ▼                         ▼                     │
│       ┌────────────────┐      ┌────────────────┐              │
│       │  product_table │      │  Backend API   │              │
│       │   (Drift DAO)  │      │  /api/products │              │
│       └────────────────┘      └────────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Data Flow Diagrams

#### 4.2.1 Product Creation Flow

```
User                ProductCreatePage        ProductBloc         Repository        Backend API
 │                         │                     │                   │                  │
 │─── Fill Form ──────────>│                     │                   │                  │
 │                         │                     │                   │                  │
 │─── Tap Save ──────────>│                     │                   │                  │
 │                         │                     │                   │                  │
 │                         │─── createEntity ───>│                   │                  │
 │                         │                     │                   │                  │
 │                         │                     │─── validate ─────>│                  │
 │                         │                     │                   │                  │
 │                         │                     │                   │─── POST ────────>│
 │                         │                     │                   │   /api/products  │
 │                         │                     │                   │                  │
 │                         │                     │                   │<─── 201 Created ─│
 │                         │                     │                   │                  │
 │                         │                     │<─── ProductEntity │                  │
 │                         │                     │                   │                  │
 │                         │                     │─── saveLocal ────>│                  │
 │                         │                     │                   │                  │
 │                         │<─── Success ────────│                   │                  │
 │                         │                     │                   │                  │
 │<─── Navigate to List ──│                     │                   │                  │
 │                         │                     │                   │                  │
```

#### 4.2.2 Product Listing with Search Flow

```
User                ProductListPage          ProductBloc         Repository        Backend API
 │                         │                     │                   │                  │
 │─── Load Page ─────────>│                     │                   │                  │
 │                         │                     │                   │                  │
 │                         │─── loadProducts ───>│                   │                  │
 │                         │                     │                   │                  │
 │                         │                     │─── getLocal ─────>│                  │
 │                         │                     │                   │                  │
 │                         │<─── Show Cache ─────│<─── cached data ──│                  │
 │<─── Display List ──────│                     │                   │                  │
 │                         │                     │                   │                  │
 │                         │                     │─── syncRemote ───>│                  │
 │                         │                     │                   │─── GET ─────────>│
 │                         │                     │                   │   /api/products  │
 │                         │                     │                   │<─── 200 OK ──────│
 │                         │                     │                   │                  │
 │                         │                     │<─── Updated List ─│                  │
 │                         │<─── Refresh ────────│                   │                  │
 │<─── Update Display ────│                     │                   │                  │
 │                         │                     │                   │                  │
 │─── Type Search ────────>│                     │                   │                  │
 │                         │                     │                   │                  │
 │                         │─── searchProducts ─>│                   │                  │
 │                         │     (debounced)     │                   │                  │
 │                         │                     │─── search ───────>│                  │
 │                         │                     │                   │                  │
 │                         │<─── Filtered List ──│<─── results ──────│                  │
 │<─── Show Results ──────│                     │                   │                  │
 │                         │                     │                   │                  │
```

#### 4.2.3 Product Selection in Invoice Flow

```
Invoice Page        ProductSelector          ProductBloc         Repository        Product Selected
 │                         │                     │                   │                  │
 │─── Tap "Add Product" ─>│                     │                   │                  │
 │                         │                     │                   │                  │
 │                         │─── Open Modal ─────>│                   │                  │
 │                         │                     │                   │                  │
 │                         │─── getInvoiceable ─>│                   │                  │
 │                         │                     │                   │                  │
 │                         │                     │─── filter active ─>│                  │
 │                         │                     │     with price    │                  │
 │                         │                     │                   │                  │
 │                         │<─── Product List ───│<─── filtered ─────│                  │
 │                         │                     │                   │                  │
 │<─── Display Modal ─────│                     │                   │                  │
 │                         │                     │                   │                  │
 │─── Select Product ─────>│                     │                   │                  │
 │                         │                     │                   │                  │
 │<─── Return Product ────│                     │                   │                  │
 │                         │                     │                   │                  │
 │─── Calculate Tax ──────────────────────────────────────────────────────────────────>│
 │    (MultiTaxCalcService)                     │                   │                  │
 │                         │                     │                   │                  │
 │─── Add to Invoice ─────────────────────────────────────────────────────────────────>│
 │                         │                     │                   │                  │
```

### 4.3 Component Diagram

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         Product Management Module                          │
│                                                                            │
│  ┌──────────────────────────────────────────────────────────────────────┐ │
│  │                         Presentation Layer                            │ │
│  │                                                                        │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │ │
│  │  │   Pages      │  │   Widgets    │  │   Forms      │               │ │
│  │  ├──────────────┤  ├──────────────┤  ├──────────────┤               │ │
│  │  │ - List       │  │ - Search     │  │ - Create     │               │ │
│  │  │ - Create     │  │ - Card       │  │ - Edit       │               │ │
│  │  │ - Edit       │  │ - Filters    │  │ - Validation │               │ │
│  │  │ - Detail     │  │ - Empty      │  └──────────────┘               │ │
│  │  └──────┬───────┘  └──────┬───────┘                                 │ │
│  │         │                  │                                         │ │
│  └─────────┼──────────────────┼─────────────────────────────────────────┘ │
│            │                  │                                           │
│            └──────────┬───────┘                                           │
│                       ▼                                                   │
│  ┌──────────────────────────────────────────────────────────────────────┐ │
│  │                        Application Layer                              │ │
│  │                                                                        │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐│ │
│  │  │                        ProductBloc                                ││ │
│  │  │  ┌────────────────┐  ┌────────────────┐  ┌──────────────────┐  ││ │
│  │  │  │  Events        │  │  States        │  │  Business Logic  │  ││ │
│  │  │  ├────────────────┤  ├────────────────┤  ├──────────────────┤  ││ │
│  │  │  │ - Load         │  │ - Initial      │  │ - Validation     │  ││ │
│  │  │  │ - Search       │  │ - Loading      │  │ - Transformation │  ││ │
│  │  │  │ - Create       │  │ - Success      │  │ - Caching        │  ││ │
│  │  │  │ - Update       │  │ - Failure      │  │ - Error Handling │  ││ │
│  │  │  │ - Delete       │  └────────────────┘  └──────────────────┘  ││ │
│  │  │  └────────────────┘                                             ││ │
│  │  └──────────────────────────────────────────────────────────────────┘│ │
│  │                                  │                                    │ │
│  └──────────────────────────────────┼────────────────────────────────────┘ │
│                                     ▼                                     │
│  ┌──────────────────────────────────────────────────────────────────────┐ │
│  │                       Infrastructure Layer                            │ │
│  │                                                                        │ │
│  │  ┌──────────────────────┐         ┌──────────────────────┐           │ │
│  │  │ ProductRepositoryImpl│◄────────│ IProductRepository   │           │ │
│  │  └──────────┬───────────┘         └──────────────────────┘           │ │
│  │             │                                                          │ │
│  │             │                                                          │ │
│  │  ┌──────────┴───────────┐         ┌──────────────────────┐           │ │
│  │  │ LocalDataSource      │         │ RemoteDataSource     │           │ │
│  │  ├──────────────────────┤         ├──────────────────────┤           │ │
│  │  │ - ProductDao         │         │ - ProductApiClient   │           │ │
│  │  │ - Drift Database     │         │ - HTTP Client        │           │ │
│  │  │ - Cache Manager      │         │ - Dio Interceptors   │           │ │
│  │  └──────────────────────┘         └──────────────────────┘           │ │
│  │                                                                        │ │
│  │  ┌──────────────────────┐         ┌──────────────────────┐           │ │
│  │  │ DTOs & Mappers       │         │ API Models           │           │ │
│  │  ├──────────────────────┤         ├──────────────────────┤           │ │
│  │  │ - ProductDto         │         │ - Request Models     │           │ │
│  │  │ - TaxConfigDto       │         │ - Response Models    │           │ │
│  │  │ - Entity↔Dto Mappers │         │ - Validation         │           │ │
│  │  └──────────────────────┘         └──────────────────────┘           │ │
│  └──────────────────────────────────────────────────────────────────────┘ │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Database Design

### 5.1 Drift Table Schema

**File:** `lib/core/database/tables/rantipay_product_table.dart` (NEW)

```dart
import 'package:drift/drift.dart';

@DataClassName('ProductTableData')
class RantipayProductTable extends Table {
  // Primary Key
  TextColumn get id => text()();

  // Timestamps
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Metadata
  TextColumn get createdBy => text()();
  TextColumn get updatedBy => text()();

  // Status
  TextColumn get status => text()(); // active, inactive, deleted
  IntColumn get version => integer().withDefault(const Constant(1))();

  // Sync Metadata
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get syncStatus => text().nullable()();

  // Basic Information
  TextColumn get code => text()(); // Unique product code
  TextColumn get name => text()();
  TextColumn get description => text()();

  // Identification
  TextColumn get barcode => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get brand => text().nullable()();
  TextColumn get model => text().nullable()();

  // Pricing (stored as integers to avoid floating point issues)
  IntColumn get basePriceInCents => integer()(); // basePrice * 100
  IntColumn get salePriceInCents => integer()(); // salePrice * 100

  // Price Configuration (JSON)
  TextColumn get priceConfigJson => text()();

  // Inventory Configuration (JSON)
  TextColumn get inventoryConfigJson => text()();

  // Tax Configuration (JSON)
  TextColumn get taxConfigJson => text()();

  // Categorization
  TextColumn get category => text().nullable()();
  TextColumn get subcategory => text().nullable()();
  TextColumn get tagsJson => text().nullable()(); // JSON array

  // Media
  TextColumn get imagesJson => text().nullable()(); // JSON array
  TextColumn get primaryImage => text().nullable()();

  // Additional Data
  TextColumn get customAttributesJson => text().nullable()();

  // Tenant & Company (Multi-tenancy support)
  TextColumn get tenantId => text()();
  TextColumn get companyId => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {code, tenantId, companyId}, // Unique product code per company
  ];
}

// Indexes for performance
@TableIndex(name: 'idx_product_code', columns: {#code})
@TableIndex(name: 'idx_product_status', columns: {#status})
@TableIndex(name: 'idx_product_barcode', columns: {#barcode})
@TableIndex(name: 'idx_product_category', columns: {#category})
@TableIndex(name: 'idx_product_sync', columns: {#isSynced, #lastSyncAt})
@TableIndex(name: 'idx_product_tenant', columns: {#tenantId, #companyId})
class RantipayProductTableIndexes extends Table {}
```

### 5.2 Data Access Object (DAO)

**File:** `lib/core/database/daos/product_dao.dart` (NEW)

```dart
import 'package:drift/drift.dart';
import 'package:rantipay_app/core/database/drift_database.dart';
import 'package:rantipay_app/core/database/tables/rantipay_product_table.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [RantipayProductTable])
class ProductDao extends DatabaseAccessor<RantipayDatabase> with _$ProductDaoMixin {
  ProductDao(RantipayDatabase db) : super(db);

  // ========== CREATE ==========

  Future<int> insertProduct(ProductTableData product) {
    return into(rantipayProductTable).insert(product);
  }

  // ========== READ ==========

  /// Get all products
  Future<List<ProductTableData>> getAllProducts({
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) {
    final query = select(rantipayProductTable)
      ..where((tbl) => tbl.status.isNotValue('deleted'));

    if (tenantId != null) {
      query.where((tbl) => tbl.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      query.where((tbl) => tbl.companyId.equals(companyId));
    }
    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.get();
  }

  /// Get product by ID
  Future<ProductTableData?> getProductById(String id) {
    return (select(rantipayProductTable)
      ..where((tbl) => tbl.id.equals(id)))
      .getSingleOrNull();
  }

  /// Search products by query
  Future<List<ProductTableData>> searchProducts({
    required String query,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) {
    final searchQuery = select(rantipayProductTable)
      ..where((tbl) =>
          (tbl.name.contains(query) |
           tbl.code.contains(query) |
           tbl.description.contains(query) |
           tbl.barcode.contains(query)) &
          tbl.status.isNotValue('deleted'));

    if (tenantId != null) {
      searchQuery.where((tbl) => tbl.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      searchQuery.where((tbl) => tbl.companyId.equals(companyId));
    }
    if (limit != null) {
      searchQuery.limit(limit, offset: offset);
    }

    return searchQuery.get();
  }

  /// Get products by category
  Future<List<ProductTableData>> getProductsByCategory({
    required String category,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) {
    final query = select(rantipayProductTable)
      ..where((tbl) =>
          tbl.category.equals(category) &
          tbl.status.isNotValue('deleted'));

    if (tenantId != null) {
      query.where((tbl) => tbl.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      query.where((tbl) => tbl.companyId.equals(companyId));
    }
    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.get();
  }

  /// Get products by status
  Future<List<ProductTableData>> getProductsByStatus({
    required String status,
    int? limit,
    int? offset,
    String? tenantId,
    String? companyId,
  }) {
    final query = select(rantipayProductTable)
      ..where((tbl) => tbl.status.equals(status));

    if (tenantId != null) {
      query.where((tbl) => tbl.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      query.where((tbl) => tbl.companyId.equals(companyId));
    }
    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.get();
  }

  /// Get unsynced products
  Future<List<ProductTableData>> getUnsyncedProducts() {
    return (select(rantipayProductTable)
      ..where((tbl) => tbl.isSynced.equals(false)))
      .get();
  }

  // ========== UPDATE ==========

  Future<bool> updateProduct(ProductTableData product) {
    return update(rantipayProductTable).replace(product);
  }

  /// Mark product as synced
  Future<int> markAsSynced(String id, DateTime syncTime) {
    return (update(rantipayProductTable)
      ..where((tbl) => tbl.id.equals(id)))
      .write(RantipayProductTableCompanion(
        isSynced: const Value(true),
        lastSyncAt: Value(syncTime),
        syncStatus: const Value('synced'),
      ));
  }

  // ========== DELETE ==========

  /// Soft delete (set status to 'deleted')
  Future<int> softDeleteProduct(String id) {
    return (update(rantipayProductTable)
      ..where((tbl) => tbl.id.equals(id)))
      .write(RantipayProductTableCompanion(
        status: const Value('deleted'),
        deletedAt: Value(DateTime.now()),
      ));
  }

  /// Hard delete (permanent)
  Future<int> hardDeleteProduct(String id) {
    return (delete(rantipayProductTable)
      ..where((tbl) => tbl.id.equals(id)))
      .go();
  }

  // ========== STATISTICS ==========

  Future<int> countProducts({
    String? status,
    String? tenantId,
    String? companyId,
  }) {
    final query = selectOnly(rantipayProductTable)
      ..addColumns([rantipayProductTable.id.count()]);

    if (status != null) {
      query.where(rantipayProductTable.status.equals(status));
    } else {
      query.where(rantipayProductTable.status.isNotValue('deleted'));
    }

    if (tenantId != null) {
      query.where(rantipayProductTable.tenantId.equals(tenantId));
    }
    if (companyId != null) {
      query.where(rantipayProductTable.companyId.equals(companyId));
    }

    return query.map((row) => row.read(rantipayProductTable.id.count())!).getSingle();
  }
}
```

### 5.3 Database Migration

**File:** `lib/core/database/migrations/migration_v3_add_products.dart` (NEW)

```dart
import 'package:drift/drift.dart';

class MigrationV3AddProducts {
  static Future<void> migrate(Migrator m) async {
    // Create products table
    await m.createTable(RantipayProductTable());

    // Create indexes
    await m.createIndex(Index(
      'idx_product_code',
      'CREATE INDEX idx_product_code ON rantipay_product_table(code)',
    ));

    await m.createIndex(Index(
      'idx_product_status',
      'CREATE INDEX idx_product_status ON rantipay_product_table(status)',
    ));

    await m.createIndex(Index(
      'idx_product_barcode',
      'CREATE INDEX idx_product_barcode ON rantipay_product_table(barcode)',
    ));

    await m.createIndex(Index(
      'idx_product_category',
      'CREATE INDEX idx_product_category ON rantipay_product_table(category)',
    ));

    await m.createIndex(Index(
      'idx_product_sync',
      'CREATE INDEX idx_product_sync ON rantipay_product_table(is_synced, last_sync_at)',
    ));

    await m.createIndex(Index(
      'idx_product_tenant',
      'CREATE INDEX idx_product_tenant ON rantipay_product_table(tenant_id, company_id)',
    ));
  }
}
```

---

## 6. API Specification

### 6.1 Backend Endpoints

**Base URL:** `http://192.168.100.145:10000/api/v1`

#### 6.1.1 Product Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/products` | List all products | Yes |
| GET | `/products/:id` | Get product by ID | Yes |
| POST | `/products` | Create new product | Yes (Level 2+) |
| PUT | `/products/:id` | Update product | Yes (Level 2+) |
| DELETE | `/products/:id` | Delete product | Yes (Level 3+) |
| GET | `/products/search` | Search products | Yes |
| GET | `/products/category/:category` | Products by category | Yes |
| GET | `/products/invoiceable` | Active products for invoices | Yes |
| GET | `/products/low-stock` | Low stock products | Yes |
| PATCH | `/products/:id/stock` | Update stock level | Yes |

#### 6.1.2 Request/Response Specifications

**POST `/products` - Create Product**

Request:
```json
{
  "code": "PROD001",
  "name": "Laptop Dell Inspiron 15",
  "description": "Laptop Dell Inspiron 15, 8GB RAM, 256GB SSD",
  "barcode": "1234567890123",
  "brand": "Dell",
  "model": "Inspiron 15",
  "base_price": 850.00,
  "sale_price": 950.00,
  "price_config": {
    "use_base_price": false,
    "allow_discount": true,
    "max_discount_percent": 10.0
  },
  "inventory_config": {
    "is_managed": true,
    "current_stock": 15,
    "min_stock": 5,
    "max_stock": 50,
    "unit": "unidad"
  },
  "tax_config": {
    "iva_rate": 15.0,
    "iva_percentage_code": "4",
    "sri_product_code": "1234567890",
    "sri_iva_code": "2",
    "is_iva_exempt": false,
    "ice_rate": 0.0
  },
  "category": "Electrónica",
  "subcategory": "Computadoras",
  "tags": ["laptop", "dell", "informática"],
  "images": ["https://example.com/image1.jpg"],
  "primary_image": "https://example.com/image1.jpg",
  "status": "active"
}
```

Response (201 Created):
```json
{
  "success": true,
  "data": {
    "id": "01HQX8Y9R6G8N3K4F2J1VZMWTC",
    "code": "PROD001",
    "name": "Laptop Dell Inspiron 15",
    "description": "Laptop Dell Inspiron 15, 8GB RAM, 256GB SSD",
    "barcode": "1234567890123",
    "brand": "Dell",
    "model": "Inspiron 15",
    "base_price": 850.00,
    "sale_price": 950.00,
    "price_config": { ... },
    "inventory_config": { ... },
    "tax_config": {
      "iva_rate": 15.0,
      "iva_percentage_code": "4",
      "sri_product_code": "1234567890",
      "sri_iva_code": "2",
      "is_iva_exempt": false
    },
    "category": "Electrónica",
    "subcategory": "Computadoras",
    "tags": ["laptop", "dell", "informática"],
    "status": "active",
    "created_at": "2025-11-17T12:00:00Z",
    "updated_at": "2025-11-17T12:00:00Z",
    "tenant_id": "639c581c-d5d2-4ecb-b43a-69620a37de32",
    "company_id": "08cfd17f-1f90-48b2-b6ca-97bbe5637573"
  },
  "message": "Product created successfully"
}
```

**GET `/products` - List Products**

Query Parameters:
- `limit` (int): Number of results (default: 50, max: 100)
- `offset` (int): Pagination offset (default: 0)
- `status` (string): Filter by status (active, inactive)
- `category` (string): Filter by category
- `search` (string): Search query
- `sort_by` (string): Sort field (name, code, price, created_at)
- `sort_order` (string): asc or desc

Response (200 OK):
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "01HQX8Y9R6G8N3K4F2J1VZMWTC",
        "code": "PROD001",
        "name": "Laptop Dell Inspiron 15",
        "sale_price": 950.00,
        "tax_config": {
          "iva_rate": 15.0,
          "iva_percentage_code": "4"
        },
        "inventory_config": {
          "current_stock": 15
        },
        "status": "active",
        "created_at": "2025-11-17T12:00:00Z"
      }
    ],
    "pagination": {
      "total": 250,
      "limit": 50,
      "offset": 0,
      "has_more": true
    }
  }
}
```

**GET `/products/search?q={query}` - Search Products**

Query Parameters:
- `q` (string, required): Search query
- `limit`, `offset`: Pagination

Response: Same as GET `/products`

**PUT `/products/:id` - Update Product**

Request: Same structure as POST, all fields optional

Response (200 OK): Updated product object

**DELETE `/products/:id` - Delete Product**

Response (200 OK):
```json
{
  "success": true,
  "message": "Product deleted successfully"
}
```

Error Response (409 Conflict):
```json
{
  "success": false,
  "error": {
    "code": "PRODUCT_IN_USE",
    "message": "Cannot delete product that has been used in invoices",
    "details": {
      "invoice_count": 5
    }
  }
}
```

### 6.2 API Client Implementation

**File:** `lib/features/product_management/infrastructure/api/product_api_client.dart` (NEW)

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/network/rantipay_service_client_factory.dart';

@injectable
class ProductApiClient {
  final RantiPayServiceClientFactory _serviceClientFactory;
  late final Dio _dio;

  ProductApiClient({
    required RantiPayServiceClientFactory serviceClientFactory,
  }) : _serviceClientFactory = serviceClientFactory {
    _dio = _serviceClientFactory.createClient('products');
  }

  /// Get all products
  Future<Response> getProducts({
    int? limit,
    int? offset,
    String? status,
    String? category,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;
    if (status != null) queryParams['status'] = status;
    if (category != null) queryParams['category'] = category;
    if (search != null) queryParams['search'] = search;
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (sortOrder != null) queryParams['sort_order'] = sortOrder;

    return _dio.get(
      '/api/v1/products',
      queryParameters: queryParams,
    );
  }

  /// Get product by ID
  Future<Response> getProductById(String id) async {
    return _dio.get('/api/v1/products/$id');
  }

  /// Create product
  Future<Response> createProduct(Map<String, dynamic> productData) async {
    return _dio.post(
      '/api/v1/products',
      data: productData,
    );
  }

  /// Update product
  Future<Response> updateProduct(String id, Map<String, dynamic> productData) async {
    return _dio.put(
      '/api/v1/products/$id',
      data: productData,
    );
  }

  /// Delete product
  Future<Response> deleteProduct(String id) async {
    return _dio.delete('/api/v1/products/$id');
  }

  /// Search products
  Future<Response> searchProducts({
    required String query,
    int? limit,
    int? offset,
  }) async {
    return _dio.get(
      '/api/v1/products/search',
      queryParameters: {
        'q': query,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );
  }

  /// Get invoiceable products (active with valid pricing)
  Future<Response> getInvoiceableProducts({
    int? limit,
    int? offset,
  }) async {
    return _dio.get(
      '/api/v1/products/invoiceable',
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );
  }

  /// Get products by category
  Future<Response> getProductsByCategory({
    required String category,
    int? limit,
    int? offset,
  }) async {
    return _dio.get(
      '/api/v1/products/category/$category',
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );
  }

  /// Get low stock products
  Future<Response> getLowStockProducts({
    int? limit,
    int? offset,
  }) async {
    return _dio.get(
      '/api/v1/products/low-stock',
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );
  }

  /// Update product stock
  Future<Response> updateStock({
    required String productId,
    required int newStock,
    String? reason,
  }) async {
    return _dio.patch(
      '/api/v1/products/$productId/stock',
      data: {
        'new_stock': newStock,
        if (reason != null) 'reason': reason,
      },
    );
  }
}
```

---

## 7. UI/UX Design

### 7.1 Screen Specifications

#### 7.1.1 Product List Page

**Route:** `/rantipay-products/products/list`

**Features:**
- ✅ Product cards with image, name, price, stock
- ✅ Search bar (debounced, 300ms)
- ✅ Filter chips (category, status)
- ✅ Sort dropdown (name, price, date)
- ✅ Floating action button (FAB) to create product
- ✅ Empty state with "Create your first product" message
- ✅ Pull-to-refresh
- ✅ Infinite scroll pagination
- ✅ Loading skeleton while fetching

**Layout:**
```
┌────────────────────────────────────────────┐
│ [←] Products              [Filter] [Sort]  │ ← AppBar
├────────────────────────────────────────────┤
│ [🔍 Search products...]                     │ ← Search Bar
├────────────────────────────────────────────┤
│ [Electrónica] [Servicios] [Activos ×]      │ ← Filter Chips
├────────────────────────────────────────────┤
│ ┌──────────────────────────────────────┐   │
│ │ [IMG] Laptop Dell Inspiron 15        │   │ ← Product Card
│ │       PROD001                        │   │
│ │       $950.00 | Stock: 15           │   │
│ │       [Edit] [View]                  │   │
│ └──────────────────────────────────────┘   │
│ ┌──────────────────────────────────────┐   │
│ │ [IMG] Mouse Inalámbrico Logitech     │   │
│ │       PROD002                        │   │
│ │       $55.00 | Stock: 30            │   │
│ │       [Edit] [View]                  │   │
│ └──────────────────────────────────────┘   │
│ ...                                         │
├────────────────────────────────────────────┤
│                    [+]                      │ ← FAB
└────────────────────────────────────────────┘
```

**Product Card Widget:**
```dart
class ProductCardWidget extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.primaryImage ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.inventory_2),
                ),
              ),
              SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.code,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${product.salePrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 16),
                        if (product.inventoryConfig.isManaged)
                          _StockIndicator(stock: product.inventoryConfig.currentStock),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton(
                itemBuilder: (_) => [
                  PopupMenuItem(child: Text('Edit'), value: 'edit'),
                  PopupMenuItem(child: Text('View'), value: 'view'),
                  PopupMenuItem(child: Text('Duplicate'), value: 'duplicate'),
                  PopupMenuItem(child: Text('Delete'), value: 'delete'),
                ],
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  // ...
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### 7.1.2 Product Create/Edit Page

**Route:** `/rantipay-products/products/create` or `/rantipay-products/products/:id/edit`

**Form Sections:**

**1. Basic Information**
- Product Code (auto-generated or manual)
- Product Name (required)
- Description (multiline)
- Brand
- Model
- Barcode (with scanner icon)
- SKU

**2. Pricing**
- Base Price (cost)
- Sale Price (required)
- Allow Discounts (checkbox)
- Max Discount Percentage

**3. Tax Configuration** ⭐
- IVA Rate (dropdown: 0%, 12%, 14%, 15%)
  - Default: 15%
  - Maps to SRI percentage code automatically
- IVA Exempt (checkbox)
- SRI Product Code (text field with validation)
- ICE Rate (optional, for special taxes)

**4. Inventory**
- Manage Inventory (toggle)
- Current Stock (number)
- Min Stock Level (warning threshold)
- Max Stock Level
- Unit of Measure (dropdown)

**5. Categorization**
- Category (dropdown with autocomplete)
- Subcategory
- Tags (chip input)

**6. Media**
- Upload Images (multi-select)
- Set Primary Image

**Layout:**
```
┌────────────────────────────────────────────┐
│ [←] Create Product           [Save]  [...]  │ ← AppBar
├────────────────────────────────────────────┤
│                                             │
│ ╔════ Basic Information ════════════════╗  │
│ ║ Product Code*: [PROD003____]          ║  │
│ ║ Product Name*: [________________]     ║  │
│ ║ Description:   [________________]     ║  │
│ ║                [________________]     ║  │
│ ║ Brand:         [________________]     ║  │
│ ║ Model:         [________________]     ║  │
│ ║ Barcode:       [________________] [📷]║  │
│ ╚═══════════════════════════════════════╝  │
│                                             │
│ ╔════ Pricing ═══════════════════════════╗  │
│ ║ Base Price:    [$________]             ║  │
│ ║ Sale Price*:   [$________]             ║  │
│ ║ [✓] Allow Discounts                    ║  │
│ ║ Max Discount:  [___%]                  ║  │
│ ╚═══════════════════════════════════════╝  │
│                                             │
│ ╔════ Tax Configuration ═══════════════╗  │
│ ║ IVA Rate*:     [15% ▼]                ║  │
│ ║                ├─ 0% (Exento)         ║  │
│ ║                ├─ 12% (Obsoleto)      ║  │
│ ║                ├─ 14%                 ║  │
│ ║                └─ 15% (Actual) ✓      ║  │
│ ║                                        ║  │
│ ║ [_] IVA Exempt                         ║  │
│ ║                                        ║  │
│ ║ SRI Product Code*: [__________]       ║  │
│ ║ (e.g., 1234567890)                    ║  │
│ ║                                        ║  │
│ ║ ICE Rate (optional): [___%]           ║  │
│ ╚═══════════════════════════════════════╝  │
│                                             │
│ ╔════ Inventory ════════════════════════╗  │
│ ║ [●] Manage Inventory                   ║  │
│ ║                                        ║  │
│ ║ Current Stock: [____] units           ║  │
│ ║ Min Stock:     [____] (warning at)    ║  │
│ ║ Max Stock:     [____]                 ║  │
│ ║ Unit:          [unidad ▼]             ║  │
│ ╚═══════════════════════════════════════╝  │
│                                             │
│ ╔════ Categorization ═══════════════════╗  │
│ ║ Category:      [Electrónica ▼]        ║  │
│ ║ Subcategory:   [Computadoras ▼]       ║  │
│ ║ Tags:          [laptop] [dell] [+]    ║  │
│ ╚═══════════════════════════════════════╝  │
│                                             │
│ ╔════ Media ════════════════════════════╗  │
│ ║ [+] Upload Images                      ║  │
│ ║ ┌───┐ ┌───┐ ┌───┐                     ║  │
│ ║ │IMG│ │IMG│ │IMG│                     ║  │
│ ║ │⭐ │ │   │ │   │                     ║  │
│ ║ └───┘ └───┘ └───┘                     ║  │
│ ╚═══════════════════════════════════════╝  │
│                                             │
│            [Cancel]  [Save Product]         │
│                                             │
└────────────────────────────────────────────┘
```

**Tax Rate Selector Widget:**
```dart
class TaxRateSelector extends StatelessWidget {
  final double? currentRate;
  final Function(double) onRateChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<double>(
      value: currentRate ?? 15.0,
      decoration: InputDecoration(
        labelText: 'IVA Rate *',
        hintText: 'Select IVA rate',
        suffixIcon: Tooltip(
          message: 'Current Ecuador IVA rate is 15%',
          child: Icon(Icons.info_outline),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: 0.0,
          child: Row(
            children: [
              Text('0% '),
              Text('(Exento)', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 12.0,
          child: Row(
            children: [
              Text('12% '),
              Text('(Obsoleto)', style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 14.0,
          child: Text('14%'),
        ),
        DropdownMenuItem(
          value: 15.0,
          child: Row(
            children: [
              Text('15% '),
              Text('(Actual)', style: TextStyle(color: Colors.green)),
              SizedBox(width: 4),
              Icon(Icons.check_circle, size: 16, color: Colors.green),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) onRateChanged(value);
      },
      validator: (value) {
        if (value == null) return 'IVA rate is required';
        return null;
      },
    );
  }
}
```

**Validation Rules:**
- Product Code: Required, unique per company
- Product Name: Required, min 3 characters
- Sale Price: Required, > 0
- IVA Rate: Required, one of [0, 12, 14, 15]
- SRI Product Code: Required, 10 digits
- Stock: If inventory managed, must be >= 0

#### 7.1.3 Product Detail Page

**Route:** `/rantipay-products/products/:id`

**Sections:**
- Hero image carousel
- Product details (read-only)
- Stock information
- Tax configuration
- Price history (future)
- Recent invoices using this product (future)
- Action buttons: Edit, Duplicate, Delete

**Layout:**
```
┌────────────────────────────────────────────┐
│ [←] Product Details        [Edit] [Delete]  │
├────────────────────────────────────────────┤
│ ┌──────────────────────────────────────┐   │
│ │                                       │   │
│ │          [Product Image]              │   │
│ │                                       │   │
│ └──────────────────────────────────────┘   │
│ ● ○ ○                                       │ ← Image indicators
│                                             │
│ Laptop Dell Inspiron 15                     │
│ PROD001                                     │
│                                             │
│ $950.00                                     │
│ Base: $850.00                               │
│                                             │
│ ─────────────────────────────────────────  │
│                                             │
│ Description                                 │
│ Laptop Dell Inspiron 15, 8GB RAM,          │
│ 256GB SSD                                   │
│                                             │
│ ─────────────────────────────────────────  │
│                                             │
│ Tax Information                             │
│ IVA Rate: 15%                               │
│ SRI Code: 1234567890                        │
│ Percentage Code: 4                          │
│                                             │
│ ─────────────────────────────────────────  │
│                                             │
│ Inventory                                   │
│ Current Stock: 15 units                     │
│ Min Stock: 5 units                          │
│ Status: ●  In Stock                         │
│                                             │
│ ─────────────────────────────────────────  │
│                                             │
│ Category                                    │
│ Electrónica > Computadoras                 │
│                                             │
│ Tags                                        │
│ [laptop] [dell] [informática]              │
│                                             │
└────────────────────────────────────────────┘
```

### 7.2 User Flows

#### 7.2.1 Create Product Flow

```
1. User opens invoice creation page
2. User taps "Add Product" button
3. Product selector modal opens
4. Modal shows "No products found" empty state
5. User taps "Create Product" button
6. Navigation to /rantipay-products/products/create
7. User fills product form:
   - Name: "Monitor LG 24 pulgadas"
   - Code: Auto-generated "PROD006"
   - Sale Price: $250.00
   - IVA Rate: 15% (dropdown)
   - Stock: 10 units
8. User taps "Save Product"
9. System validates form
10. System sends POST to backend
11. Backend returns 201 with product ID
12. System saves to local database
13. System shows success snackbar
14. Navigation back to product list
15. New product appears in list
16. User can now select it for invoices
```

#### 7.2.2 Edit Product with Tax Update Flow

```
1. User opens product list
2. User taps product card
3. Product detail page opens
4. User taps "Edit" button
5. Edit form opens with pre-filled data
6. User sees IVA Rate: 12% (obsolete warning)
7. User changes IVA Rate to 15%
8. System updates percentage code: "2" → "4"
9. System recalculates tax amounts
10. User taps "Save"
11. System sends PUT to backend
12. Backend validates and updates
13. System updates local database
14. System shows "Tax rate updated to 15%" message
15. Navigation back to detail page
16. Updated values displayed
17. Next invoice with this product uses 15% IVA
```

#### 7.2.3 Product Selection in Invoice Flow

```
1. User creating invoice
2. User taps "Add Product"
3. Product selector modal opens
4. Modal loads products via ProductBloc
5. System displays product list (cached)
6. System syncs with backend in background
7. User types "laptop" in search
8. System filters products (debounced 300ms)
9. Results show "Laptop Dell Inspiron 15"
10. User taps product
11. Modal closes, returns ProductEntity
12. System extracts product.taxConfig.ivaRate (15%)
13. System calls MultiTaxCalculationService
14. Service attempts backend tax rate fetch
15. If backend unavailable:
    → Falls back to product.taxConfig.ivaRate
16. System creates InvoiceLineItemEntity:
    - productCode: "PROD001"
    - description: "Laptop Dell Inspiron 15"
    - unitPrice: $950.00
    - appliedTaxes: [TaxDetail(IVA, 15%, $142.50)]
17. Line item added to invoice
18. Totals recalculated:
    - Subtotal 15%: $950.00
    - IVA 15%: $142.50
    - TOTAL: $1,092.50
19. User sees updated invoice
```

### 7.3 Design Tokens

**Colors:**
- Primary: RantiPay brand color
- Success: Green (#4CAF50) for active products
- Warning: Orange (#FF9800) for low stock
- Error: Red (#F44336) for out of stock
- Info: Blue (#2196F3) for IVA info

**Typography:**
- Product Name: titleMedium (16px, medium)
- Product Code: bodySmall (12px, regular)
- Price: titleLarge (20px, bold)
- Description: bodyMedium (14px, regular)

**Spacing:**
- Card padding: 16px
- Section spacing: 24px
- Field spacing: 12px

---

## 8. Implementation Plan

### 8.1 Development Phases

#### Phase 1: Foundation (Week 1) - CRITICAL

**Tasks:**
1. ✅ Update TaxConfiguration default IVA rate: 12.0 → 15.0
2. 🔴 Create database table: `rantipay_product_table.dart`
3. 🔴 Create database DAO: `product_dao.dart`
4. 🔴 Write database migration: `migration_v3_add_products.dart`
5. 🔴 Run migration and test local CRUD
6. 🔴 Create ProductDto and mappers
7. 🔴 Update mock repository to use 15% IVA
8. 🔴 Test invoice creation with updated mock products

**Acceptance Criteria:**
- Database schema created and migrated
- Mock products use 15% IVA
- Invoices calculate tax at 15%
- Local CRUD operations work

#### Phase 2: Backend Integration (Week 2) - HIGH PRIORITY

**Tasks:**
1. 🔴 Implement ProductApiClient
2. 🔴 Create ProductRepositoryImpl with:
   - Remote data source (API)
   - Local data source (Drift)
   - Offline-first sync logic
3. 🔴 Implement request/response DTOs
4. 🔴 Implement entity↔DTO mappers
5. 🔴 Register ProductRepositoryImpl in DI
6. 🔴 Add environment-based repository selection
7. 🔴 Test backend connectivity
8. 🔴 Implement sync queue for offline operations

**Acceptance Criteria:**
- API client communicates with backend
- Products sync from backend to local DB
- Offline CRUD operations queue for sync
- Repository automatically switches mock↔real

#### Phase 3: Product List UI (Week 3) - HIGH PRIORITY

**Tasks:**
1. 🔴 Create ProductListPage
2. 🔴 Implement ProductCardWidget
3. 🔴 Add search bar with debouncing
4. 🔴 Add filter chips (category, status)
5. 🔴 Add sort dropdown
6. 🔴 Implement pull-to-refresh
7. 🔴 Implement infinite scroll pagination
8. 🔴 Add loading states & skeletons
9. 🔴 Add empty state
10. 🔴 Integrate with ProductBloc

**Acceptance Criteria:**
- Product list displays from backend
- Search works with 300ms debounce
- Filters and sort work correctly
- Pull-to-refresh syncs data
- Pagination loads more products
- Empty state shows "Create product"

#### Phase 4: Product Create/Edit UI (Week 4) - HIGH PRIORITY

**Tasks:**
1. 🔴 Create ProductCreatePage
2. 🔴 Create ProductEditPage
3. 🔴 Implement form with sections
4. 🔴 Create TaxRateSelector widget (0%, 12%, 14%, 15%)
5. 🔴 Implement form validation
6. 🔴 Add barcode scanner integration
7. 🔴 Add image upload/picker
8. 🔴 Implement category autocomplete
9. 🔴 Add tag chip input
10. 🔴 Integrate with ProductBloc
11. 🔴 Add success/error handling
12. 🔴 Test create flow end-to-end
13. 🔴 Test edit flow with tax rate update

**Acceptance Criteria:**
- Form validates all required fields
- IVA rate selector shows 15% as current
- Product creation posts to backend
- Product editing updates backend
- Tax rate changes update percentage code
- Images upload successfully
- Success messages display
- Navigation works correctly

#### Phase 5: Product Detail & Delete (Week 5) - MEDIUM PRIORITY

**Tasks:**
1. 🔴 Create ProductDetailPage
2. 🔴 Implement image carousel
3. 🔴 Display all product information
4. 🔴 Add Edit/Delete action buttons
5. 🔴 Implement soft delete with confirmation
6. 🔴 Prevent deletion of products in invoices
7. 🔴 Add restore functionality (future)
8. 🔴 Test detail view
9. 🔴 Test delete flow

**Acceptance Criteria:**
- Detail page shows all product info
- Image carousel works
- Edit navigates to edit page
- Delete shows confirmation dialog
- System prevents deleting used products
- Deletion soft-deletes (status = deleted)

#### Phase 6: Routing & Navigation (Week 5) - HIGH PRIORITY

**Tasks:**
1. 🔴 Register routes in enhanced_app_router.dart:
   - `/rantipay-products/products/list`
   - `/rantipay-products/products/create`
   - `/rantipay-products/products/:id`
   - `/rantipay-products/products/:id/edit`
2. 🔴 Add route guards (User Level 2+ for create/edit)
3. 🔴 Wrap routes with ProductBloc provider
4. 🔴 Add navigation from empty state
5. 🔴 Test deep linking
6. 🔴 Test navigation flow

**Acceptance Criteria:**
- All routes registered
- Route guards work (Level 2+ required)
- ProductBloc available in all product pages
- Deep links work
- Navigation between pages works

#### Phase 7: Invoice Integration (Week 6) - CRITICAL

**Tasks:**
1. 🔴 Update ProductSelectorWidget to use real products
2. 🔴 Ensure InvoiceCreatePage uses dynamic tax rates
3. 🔴 Test product selection → invoice line item flow
4. 🔴 Verify MultiTaxCalculationService uses product tax config
5. 🔴 Test fallback to product IVA rate when backend fails
6. 🔴 Add "Create Product" button in empty product selector
7. 🔴 Test end-to-end: Create product → Add to invoice → Verify tax

**Acceptance Criteria:**
- Product selector shows real products
- New products immediately available for selection
- Tax calculated at 15% from product config
- Fallback works when backend unavailable
- Empty state navigates to product creation
- End-to-end flow works

#### Phase 8: Testing & QA (Week 7) - CRITICAL

**Tasks:**
1. 🔴 Write unit tests for ProductBloc
2. 🔴 Write unit tests for ProductRepository
3. 🔴 Write unit tests for mappers
4. 🔴 Write widget tests for ProductListPage
5. 🔴 Write widget tests for ProductCreatePage
6. 🔴 Write integration tests for CRUD flows
7. 🔴 Test offline scenarios
8. 🔴 Test sync conflicts
9. 🔴 Performance testing with 10,000+ products
10. 🔴 User acceptance testing

**Acceptance Criteria:**
- 80%+ code coverage
- All critical paths tested
- Offline scenarios work
- No crashes or data loss
- Performance meets requirements

#### Phase 9: Deployment & Documentation (Week 8)

**Tasks:**
1. 🔴 Update CLAUDE.md with product module info
2. 🔴 Write user documentation
3. 🔴 Create video tutorials (optional)
4. 🔴 Deploy to staging environment
5. 🔴 User training
6. 🔴 Deploy to production
7. 🔴 Monitor usage and errors
8. 🔴 Collect feedback

**Acceptance Criteria:**
- Documentation complete
- Staging deployment successful
- Users trained
- Production deployment successful
- No critical issues in first week

### 8.2 Task Breakdown

**Total Estimated Effort:** 8 weeks (1 developer)

| Phase | Tasks | Days | Priority |
|-------|-------|------|----------|
| 1. Foundation | 8 | 5 | Critical |
| 2. Backend Integration | 8 | 7 | High |
| 3. Product List UI | 10 | 7 | High |
| 4. Create/Edit UI | 13 | 10 | High |
| 5. Detail & Delete | 9 | 5 | Medium |
| 6. Routing | 6 | 3 | High |
| 7. Invoice Integration | 7 | 5 | Critical |
| 8. Testing & QA | 10 | 7 | Critical |
| 9. Deployment | 8 | 3 | High |
| **TOTAL** | **79 tasks** | **52 days** | |

### 8.3 Dependencies

```
Phase 1 (Foundation)
  └─> Phase 2 (Backend Integration)
      ├─> Phase 3 (Product List UI)
      ├─> Phase 4 (Create/Edit UI)
      └─> Phase 5 (Detail & Delete)
          └─> Phase 6 (Routing)
              └─> Phase 7 (Invoice Integration)
                  └─> Phase 8 (Testing & QA)
                      └─> Phase 9 (Deployment)
```

**Critical Path:** Phase 1 → 2 → 4 → 6 → 7 → 8 → 9

### 8.4 Risks & Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Backend API not ready | High | Medium | Use mock repo, implement API client later |
| Tax rate changes during development | Medium | Low | Make IVA rates configurable via backend |
| Performance issues with large datasets | Medium | Medium | Implement pagination, caching, indexing |
| Offline sync conflicts | High | Medium | Implement last-write-wins with conflict detection |
| User resistance to 15% tax | Low | Low | Provide clear messaging about legal requirements |
| Database migration fails | High | Low | Test migration thoroughly, have rollback plan |

---

## 9. Testing Strategy

### 9.1 Unit Tests

**Target Coverage:** 80%

**Files to Test:**
1. `product_bloc.dart`
   - Test all events and states
   - Test business logic
   - Mock repository

2. `product_repository_impl.dart`
   - Test CRUD operations
   - Test offline/online switching
   - Test sync logic
   - Mock API client and DAO

3. `product_mapper.dart`
   - Test entity → DTO conversion
   - Test DTO → entity conversion
   - Test null handling

4. `product_dao.dart`
   - Test database queries
   - Test indexes
   - Test transactions

5. `tax_configuration.dart`
   - Test IVA rate calculations
   - Test SRI code mappings

**Example Test:**
```dart
// test/features/product_management/application/blocs/product_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('ProductBloc', () {
    late MockProductRepository mockRepository;
    late ProductBloc productBloc;

    setUp(() {
      mockRepository = MockProductRepository();
      productBloc = ProductBloc(repository: mockRepository);
    });

    group('loadProducts', () {
      final mockProducts = [
        ProductEntity(/* ... */),
        ProductEntity(/* ... */),
      ];

      blocTest<ProductBloc, ProductState>(
        'emits [loading, success] when loadProducts succeeds',
        build: () {
          when(() => mockRepository.getEntities())
              .thenAnswer((_) async => (mockProducts, null));
          return productBloc;
        },
        act: (bloc) => bloc.loadProducts(),
        expect: () => [
          ProductState.loading(),
          ProductState.success(mockProducts),
        ],
        verify: (_) {
          verify(() => mockRepository.getEntities()).called(1);
        },
      );

      blocTest<ProductBloc, ProductState>(
        'emits [loading, failure] when loadProducts fails',
        build: () {
          when(() => mockRepository.getEntities())
              .thenAnswer((_) async => (null, FailureCommons.serverError()));
          return productBloc;
        },
        act: (bloc) => bloc.loadProducts(),
        expect: () => [
          ProductState.loading(),
          ProductState.failure(FailureCommons.serverError()),
        ],
      );
    });

    group('searchProducts', () {
      test('debounces search calls by 300ms', () async {
        // Test debouncing logic
      });
    });

    group('createEntity', () {
      test('validates IVA rate is 0, 12, 14, or 15', () async {
        // Test validation
      });
    });
  });
}
```

### 9.2 Widget Tests

**Widgets to Test:**
1. ProductListPage
2. ProductCreatePage
3. ProductCardWidget
4. TaxRateSelector
5. ProductSelectorWidget

**Example Test:**
```dart
// test/features/product_management/presentation/widgets/product_card_widget_test.dart

void main() {
  testWidgets('ProductCardWidget displays product info', (tester) async {
    final product = ProductEntity(
      name: 'Test Product',
      code: 'TEST001',
      salePrice: 100.0,
      /* ... */
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCardWidget(
            product: product,
            onTap: () {},
            onEdit: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('TEST001'), findsOneWidget);
    expect(find.text('\$100.00'), findsOneWidget);
  });

  testWidgets('ProductCardWidget shows low stock warning', (tester) async {
    final product = ProductEntity(
      name: 'Low Stock Product',
      inventoryConfig: InventoryConfiguration(
        isManaged: true,
        currentStock: 2,
        minStock: 5,
      ),
      /* ... */
    );

    await tester.pumpWidget(/* ... */);

    expect(find.byIcon(Icons.warning), findsOneWidget);
  });
}
```

### 9.3 Integration Tests

**Scenarios to Test:**

1. **End-to-End Product Creation**
   - User opens app
   - Navigates to product list
   - Taps create button
   - Fills form with valid data
   - Saves product
   - Verifies product appears in list
   - Verifies product synced to backend

2. **Product Selection in Invoice**
   - User creates invoice
   - Opens product selector
   - Searches for product
   - Selects product
   - Verifies line item created with 15% IVA
   - Verifies total calculated correctly

3. **Offline CRUD Operations**
   - Disable network
   - Create/edit/delete products
   - Verify stored in sync queue
   - Enable network
   - Verify auto-sync
   - Verify backend updated

**Example Integration Test:**
```dart
// integration_test/product_crud_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Product CRUD Integration', () {
    testWidgets('Create, edit, delete product flow', (tester) async {
      // Launch app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Navigate to product list
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();

      // Tap create button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byKey(Key('product_name')), 'Integration Test Product');
      await tester.enterText(find.byKey(Key('sale_price')), '150.00');

      // Select 15% IVA
      await tester.tap(find.byKey(Key('iva_rate_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15%'));
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save Product'));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Product created successfully'), findsOneWidget);

      // Verify product in list
      expect(find.text('Integration Test Product'), findsOneWidget);

      // Tap to edit
      await tester.tap(find.text('Integration Test Product'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Edit price
      await tester.enterText(find.byKey(Key('sale_price')), '175.00');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify updated
      expect(find.text('\$175.00'), findsOneWidget);

      // Delete product
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Verify deleted
      expect(find.text('Integration Test Product'), findsNothing);
    });
  });
}
```

### 9.4 Performance Tests

**Metrics to Measure:**
1. Product list load time with 10,000 products
2. Search response time
3. Create/edit form submission time
4. Database query performance
5. Memory usage

**Tools:**
- Flutter DevTools (Performance tab)
- Dart VM Observatory
- Custom benchmarking scripts

**Example Performance Test:**
```dart
void main() {
  test('Product search completes in < 500ms with 10k products', () async {
    final repository = ProductRepositoryMock();
    final bloc = ProductBloc(repository: repository);

    // Generate 10,000 mock products
    final stopwatch = Stopwatch()..start();

    await bloc.searchProducts('laptop');

    stopwatch.stop();

    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  });
}
```

---

## 10. Migration & Deployment

### 10.1 Database Migration Strategy

**Current Version:** v2
**Target Version:** v3 (adds product table)

**Migration Steps:**

1. **Backup existing database**
   ```dart
   await _backupDatabase();
   ```

2. **Run migration v3**
   ```dart
   @override
   MigrationStrategy get migration => MigrationStrategy(
     onUpgrade: (m, from, to) async {
       if (from < 3) {
         await MigrationV3AddProducts.migrate(m);
       }
     },
   );
   ```

3. **Populate with mock data** (dev/staging only)
   ```dart
   if (environment == 'dev') {
     await _populateMockProducts();
   }
   ```

4. **Verify migration**
   ```dart
   final count = await productDao.countProducts();
   print('Products migrated: $count');
   ```

### 10.2 Deployment Checklist

**Pre-Deployment:**
- [ ] All tests passing (unit, widget, integration)
- [ ] Code coverage >= 80%
- [ ] Code review completed
- [ ] Backend API endpoints ready and tested
- [ ] Database migration tested on staging
- [ ] Performance benchmarks met
- [ ] Security audit completed
- [ ] User documentation written

**Deployment:**
- [ ] Deploy backend API to production
- [ ] Update API base URL in app config
- [ ] Build release APK/IPA
- [ ] Test release build on physical devices
- [ ] Submit to app stores (if applicable)
- [ ] Deploy to internal testing group
- [ ] Monitor crash reports and logs
- [ ] Gradual rollout (10% → 50% → 100%)

**Post-Deployment:**
- [ ] Monitor API errors and response times
- [ ] Monitor app crashes (Firebase Crashlytics)
- [ ] Collect user feedback
- [ ] Track key metrics (product creation rate, search usage)
- [ ] Fix critical bugs within 24 hours
- [ ] Plan next iteration

### 10.3 Rollback Plan

If critical issues are found:

1. **Immediate Rollback:**
   - Revert to previous app version in stores
   - Redirect API traffic to previous backend version
   - Restore database from backup if needed

2. **Partial Rollback:**
   - Feature flag to disable product CRUD
   - Fall back to mock repository
   - Continue using legacy hardcoded products

3. **Data Recovery:**
   - Export products created during deployment
   - Import into fixed version
   - Validate data integrity

---

## Appendix A: File Structure

Complete file tree for product management module:

```
lib/features/product_management/
├── application/
│   └── blocs/
│       ├── product_bloc.dart              ✅ Exists
│       └── product_state.dart             ✅ Exists
│
├── domain/
│   ├── entities/
│   │   ├── product_entity.dart            ✅ Exists
│   │   ├── product_entity.freezed.dart    ✅ Generated
│   │   ├── product_entity.g.dart          ✅ Generated
│   │   ├── tax_configuration.dart         ✅ Exists (updated to 15%)
│   │   ├── tax_configuration.freezed.dart ✅ Generated
│   │   ├── tax_configuration.g.dart       ✅ Generated
│   │   └── product_enums.dart             ✅ Exists
│   │
│   └── repositories/
│       └── product_repository.dart        ✅ Exists (interface)
│
├── infrastructure/
│   ├── api/
│   │   └── product_api_client.dart        🔴 NEW
│   │
│   ├── dtos/
│   │   ├── product_dto.dart               🔴 NEW
│   │   ├── product_dto.freezed.dart       🔴 Generated
│   │   ├── product_dto.g.dart             🔴 Generated
│   │   ├── tax_config_dto.dart            🔴 NEW
│   │   └── tax_config_dto.g.dart          🔴 Generated
│   │
│   ├── mappers/
│   │   ├── product_mapper.dart            🔴 NEW
│   │   └── tax_config_mapper.dart         🔴 NEW
│   │
│   └── repositories/
│       ├── product_repository_mock.dart   ✅ Exists (update IVA to 15%)
│       └── product_repository_impl.dart   🔴 NEW
│
└── presentation/
    ├── pages/
    │   ├── product_selection_page.dart    ✅ Exists (product picker)
    │   ├── product_list_page.dart         🔴 NEW
    │   ├── product_create_page.dart       🔴 NEW
    │   ├── product_edit_page.dart         🔴 NEW
    │   └── product_detail_page.dart       🔴 NEW
    │
    └── widgets/
        ├── product_search_widget.dart     ✅ Exists
        ├── product_card_widget.dart       🔴 NEW
        ├── tax_rate_selector_widget.dart  🔴 NEW
        ├── product_form_widget.dart       🔴 NEW
        └── stock_indicator_widget.dart    🔴 NEW

lib/core/database/
├── tables/
│   └── rantipay_product_table.dart        🔴 NEW
│
├── daos/
│   └── product_dao.dart                   🔴 NEW
│
└── migrations/
    └── migration_v3_add_products.dart     🔴 NEW

lib/core/routes/
└── enhanced_app_router.dart               ⚠️ UPDATE (add product routes)

test/features/product_management/
├── application/
│   └── blocs/
│       └── product_bloc_test.dart         🔴 NEW
│
├── infrastructure/
│   ├── repositories/
│   │   └── product_repository_impl_test.dart  🔴 NEW
│   └── mappers/
│       └── product_mapper_test.dart       🔴 NEW
│
└── presentation/
    ├── pages/
    │   ├── product_list_page_test.dart    🔴 NEW
    │   └── product_create_page_test.dart  🔴 NEW
    └── widgets/
        └── product_card_widget_test.dart  🔴 NEW

integration_test/
└── product_crud_test.dart                 🔴 NEW
```

**Summary:**
- ✅ **Existing:** 12 files
- ⚠️ **To Update:** 2 files
- 🔴 **To Create:** 27 files
- **Total New Work:** 29 files

---

## Appendix B: Code Generation Commands

After creating new files with Freezed/Injectable annotations:

```bash
# Generate all code (Freezed, JSON, DI, Drift)
timeout 60 dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
timeout 300 dart run build_runner watch --delete-conflicting-outputs

# Clean generated files if issues occur
dart run build_runner clean
rm -rf .dart_tool/build
```

---

## Appendix C: API Testing with curl

**Create Product:**
```bash
curl -X POST http://192.168.100.145:10000/api/v1/products \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "TEST001",
    "name": "Test Product",
    "description": "Test product for API validation",
    "sale_price": 100.00,
    "base_price": 80.00,
    "tax_config": {
      "iva_rate": 15.0,
      "iva_percentage_code": "4",
      "sri_product_code": "1234567890",
      "sri_iva_code": "2"
    },
    "status": "active"
  }'
```

**Get Products:**
```bash
curl -X GET "http://192.168.100.145:10000/api/v1/products?limit=50" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Search Products:**
```bash
curl -X GET "http://192.168.100.145:10000/api/v1/products/search?q=laptop" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Update Product:**
```bash
curl -X PUT http://192.168.100.145:10000/api/v1/products/01HQX8Y9R6G8N3K4F2J1VZMWTC \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "tax_config": {
      "iva_rate": 15.0,
      "iva_percentage_code": "4"
    }
  }'
```

**Delete Product:**
```bash
curl -X DELETE http://192.168.100.145:10000/api/v1/products/01HQX8Y9R6G8N3K4F2J1VZMWTC \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-17 | Claude Code | Initial SRS document |

**Status:** Draft
**Reviewers:** Project Lead, Backend Team, QA Team
**Approval:** Pending

---

**End of Document**
