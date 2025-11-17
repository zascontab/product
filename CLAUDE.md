# CLAUDE.md - RantiPay V2 Development Guide

**Last Updated:** 2025-11-17
**Version:** 2.0.0
**Project:** RantiPay Incidence Mobile - Clean Architecture V2

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Directory Structure](#directory-structure)
4. [Development Conventions](#development-conventions)
5. [State Management](#state-management)
6. [Error Handling](#error-handling)
7. [Code Generation](#code-generation)
8. [Testing Strategy](#testing-strategy)
9. [Common Tasks](#common-tasks)
10. [Key Patterns](#key-patterns)
11. [Security Guidelines](#security-guidelines)
12. [Dependencies Guide](#dependencies-guide)
13. [Feature Development Workflow](#feature-development-workflow)

---

## Project Overview

### What is RantiPay?

RantiPay is a comprehensive Flutter mobile application for electronic invoicing and incidence management. Version 2.0 represents a complete rewrite following Clean Architecture principles with a focus on:

- **Clean Architecture**: Strict separation of concerns across Domain, Application, Infrastructure, and Presentation layers
- **Offline-First**: Full offline support with synchronization
- **Type Safety**: Extensive use of Freezed and type-safe patterns
- **Security**: Encryption, biometric auth, certificate pinning, jailbreak detection
- **Matrix Chat Integration**: Full FluffyChat/Valkyrie chat integration (Phase 1 complete)
- **Electronic Invoicing**: SRI (Ecuador tax authority) compliant invoicing
- **Multi-Platform**: Android, iOS, Web, macOS, Linux, Windows support

### Tech Stack

- **Flutter SDK**: >=3.1.0 <4.0.0
- **Language**: Dart (null-safety enabled)
- **State Management**: BLoC (bloc + flutter_bloc) + Cubit
- **Dependency Injection**: get_it + injectable
- **Database**: Drift (primary), Sqflite, Sembast, SqlCipher (encrypted)
- **Network**: Dio with custom interceptors
- **Code Generation**: Freezed, json_serializable, injectable_generator, drift_dev
- **Functional Programming**: Dartz (Either/Option patterns)
- **Testing**: BLoC test, Mockito, Mocktail, Golden toolkit

---

## Architecture

### Clean Architecture Layers

RantiPay follows **Clean Architecture** with strict layer separation:

```
lib/
├── features/              # Feature modules (vertical slices)
│   └── feature_name/
│       ├── domain/        # Business logic (pure Dart)
│       │   ├── entities/  # Business entities (Freezed)
│       │   └── repositories/ # Repository interfaces
│       ├── application/   # Use cases & BLoCs
│       │   └── blocs/     # State management
│       ├── infrastructure/ # External concerns
│       │   ├── datasources/ # API clients, local storage
│       │   ├── dtos/      # Data transfer objects
│       │   └── repositories/ # Repository implementations
│       └── presentation/  # UI layer
│           ├── pages/     # Full screen widgets
│           └── widgets/   # Reusable components
└── core/                  # Shared utilities
    ├── rantipay/          # Core RantiPay framework
    │   ├── rantipay_base/ # Base classes & patterns
    │   ├── constants/     # App-wide constants
    │   ├── failure/       # Error handling
    │   └── utils/         # Utility functions
    └── rantipay_theme/    # Theming & design system
```

### Dependency Rules

**CRITICAL**: Follow these dependency rules strictly:

1. **Domain Layer** (innermost):
   - NO dependencies on other layers
   - Pure Dart code only
   - Contains entities and repository interfaces

2. **Application Layer**:
   - Depends ONLY on Domain
   - Contains BLoCs, Cubits, and use cases
   - NO UI or infrastructure dependencies

3. **Infrastructure Layer**:
   - Depends on Domain (implements interfaces)
   - Contains API clients, DTOs, concrete repositories
   - NO Application or Presentation dependencies

4. **Presentation Layer** (outermost):
   - Can depend on ALL layers
   - Contains widgets, pages, UI components

### Base Entity Pattern

All entities MUST extend the base entity pattern:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_entity.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_sync_meta_data.dart';

@freezed
class YourEntity with _$YourEntity {
  const factory YourEntity({
    // === IBaseEntity Implementation (REQUIRED) ===
    required EntityIdentifier id,
    required EntityMetadata metadata,
    required EntityStatus status,
    required SyncMetadata syncMeta,

    // === Your specific fields ===
    required String name,
    String? description,
    // ... other fields
  }) = _YourEntity;

  factory YourEntity.fromJson(Map<String, dynamic> json) =>
      _$YourEntityFromJson(json);
}

// Extensions for IBaseEntity compliance
extension YourEntityBaseImplementation on YourEntity {
  ValidationResult validate() {
    final errors = <String>[];
    // Add validation logic
    return (errors.isEmpty, errors);
  }

  String getCacheKey() => '${entityType}_${id.uniqueKey}';
  String getDisplayName() => name;
  bool needsSync() => syncMeta.needsSync;
  String get entityType => 'your_entity';
}
```

### Entity Identifier System

RantiPay uses a sophisticated identifier system for offline-first support:

```dart
// Temporary ID (not saved yet)
EntityIdentifier.temp('product_temp_123');

// Local ID (saved locally, not synced)
EntityIdentifier.local('local_product_456');

// Server ID (synced to backend)
EntityIdentifier.server('srv_789');

// Mapped ID (both local and server IDs)
EntityIdentifier.mapped(localId: 'local_456', serverId: 'srv_789');

// Auto-detect from key
EntityIdentifier.fromKey('temp_123'); // detects type by prefix
```

---

## Directory Structure

### Core Framework (`lib/core/rantipay/`)

```
core/rantipay/
├── rantipay_base/               # Base framework
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── base_entity.dart           # IBaseEntity interface
│   │   │   └── base_sync_meta_data.dart   # Sync metadata
│   │   ├── repositories/
│   │   │   └── base_repository.dart       # IBaseRepository interface
│   │   └── common/
│   │       ├── pagination.dart            # Pagination support
│   │       └── api_response_entity.dart   # Standard API responses
│   ├── application/
│   │   ├── blocs/
│   │   │   └── base_crud_bloc.dart        # Universal CRUD BLoC
│   │   ├── services/
│   │   │   ├── connectivity_service.dart  # Network status
│   │   │   └── search_service.dart        # Search utilities
│   │   └── usecases/
│   │       └── base_usecase.dart          # Use case pattern
│   ├── infrastructure/
│   │   ├── datasources/
│   │   │   ├── local_datasource.dart      # Local DB interface
│   │   │   └── remote_datasource.dart     # API interface
│   │   ├── repositories/
│   │   │   └── base_repository_impl.dart  # Base repo implementation
│   │   └── services/
│   │       └── sync_service.dart          # Offline sync logic
│   └── presentation/
│       ├── pages/
│       │   └── enhanced_page_scaffold.dart # Enhanced scaffold with error boundary
│       ├── widgets/
│       │   ├── base_list_widget.dart      # Reusable list UI
│       │   ├── base_form_widget.dart      # Form builder
│       │   ├── base_search_widget.dart    # Search UI
│       │   ├── page_error_boundary.dart   # Error boundary widget
│       │   └── recovery_strategy_manager.dart # Error recovery
│       └── dialogs/
│           └── base_dialog.dart           # Reusable dialogs
├── constants/                   # App constants
│   ├── rantipay_app_constants.dart       # App-wide constants
│   ├── rantipay_time_constants.dart      # Time/date formats
│   └── rantipay_regex_patterns.dart      # Regex patterns
├── failure/                     # Error handling
│   ├── rantipay_failures.dart            # Common failures
│   ├── rantipay_exceptions.dart          # Custom exceptions
│   ├── rantipay_error_mapper.dart        # Error mapping
│   ├── rantipay_error_interceptor.dart   # Dio error interceptor
│   └── rantipay_database_errors.dart     # DB error handling
├── rantipay_api_client.dart     # Base API client
├── rantipay_dio_client.dart     # Dio configuration
├── rantipay_auth_interceptor.dart        # Auth interceptor
├── enhanced_auth_interceptor.dart        # Enhanced auth with retry
├── rantipay_logger.dart         # Logging utility
├── rantipay_secure_storage.dart # Secure storage wrapper
├── rantipay_encryption_service.dart      # Encryption utilities
├── rantipay_biometric_service.dart       # Biometric auth
├── rantipay_jailbreak_detection.dart     # Security checks
├── rantipay_certificate_pinning.dart     # SSL pinning
├── rantipay_security_manager.dart        # Security orchestrator
├── rantipay_pin_service.dart    # PIN management
└── utils/                       # Utilities
    └── jwt_token_validator.dart          # JWT validation
```

### Theme System (`lib/core/rantipay_theme/`)

```
rantipay_theme/
├── ranti_theme.dart             # Main theme configuration
├── ranti_colors.dart            # Color palette
├── ranti_spacing.dart           # Spacing constants
└── components/
    └── base/
        ├── ranti_button.dart    # Button components
        └── ranti_card.dart      # Card components
```

### Feature Modules (`lib/features/`)

Each feature follows the same structure:

```
features/
└── product_management/          # Example feature
    ├── domain/
    │   ├── entities/
    │   │   ├── product_entity.dart        # Main entity (Freezed)
    │   │   ├── product_entity.freezed.dart # Generated
    │   │   ├── product_entity.g.dart      # Generated
    │   │   ├── product_enums.dart         # Enums
    │   │   └── tax_configuration.dart     # Sub-entities
    │   └── repositories/
    │       └── product_repository.dart    # Repository interface
    ├── application/
    │   └── blocs/
    │       ├── product_bloc.dart          # BLoC implementation
    │       └── product_state.dart         # State definitions
    ├── infrastructure/
    │   └── repositories/
    │       └── product_repository_mock.dart # Mock implementation
    └── presentation/
        ├── pages/
        │   └── product_selection_page.dart # Full page
        └── widgets/
            └── product_search_widget.dart  # Reusable widget
```

---

## Development Conventions

### File Naming

- **Dart files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/functions**: `camelCase`
- **Constants**: `camelCase` (not SCREAMING_SNAKE_CASE)
- **Private members**: `_prefixedWithUnderscore`

Examples:
```dart
// ✅ CORRECT
lib/features/product_management/domain/entities/product_entity.dart
class ProductEntity { }
const defaultPageSize = 20;
final _repository = ProductRepository();

// ❌ INCORRECT
lib/features/ProductManagement/domain/entities/ProductEntity.dart
const DEFAULT_PAGE_SIZE = 20;
```

### Code Organization

1. **Imports**: Group imports by type
   ```dart
   // Dart imports
   import 'dart:async';
   import 'dart:convert';

   // Flutter imports
   import 'package:flutter/material.dart';
   import 'package:flutter/services.dart';

   // Package imports
   import 'package:bloc/bloc.dart';
   import 'package:freezed_annotation/freezed_annotation.dart';

   // Project imports
   import 'package:rantipay_app/core/errors/failure_commons.dart';
   import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';

   // Relative imports (avoid when possible)
   import '../../../domain/entities/base_entity.dart';
   ```

2. **Class Structure**: Follow this order
   ```dart
   class MyClass {
     // 1. Static constants
     static const defaultValue = 10;

     // 2. Private fields
     final Repository _repository;

     // 3. Public fields
     final String name;

     // 4. Constructor
     MyClass({required this.name, required Repository repository})
         : _repository = repository;

     // 5. Factory constructors
     factory MyClass.create() => MyClass(name: 'default');

     // 6. Getters
     String get displayName => name.toUpperCase();

     // 7. Public methods
     void doSomething() { }

     // 8. Private methods
     void _internalLogic() { }

     // 9. Overrides
     @override
     String toString() => 'MyClass($name)';
   }
   ```

### Comments and Documentation

Use comments strategically:

```dart
/// Public API documentation (triple slash)
/// Describes what this class/method does
///
/// Example:
/// ```dart
/// final product = ProductEntity.createService(
///   code: 'SRV001',
///   name: 'Consulting',
///   price: 100.0,
/// );
/// ```
class ProductEntity {
  // Single line comment for implementation notes
  final String code;

  /* Multi-line comment for complex logic explanation
     Use when single line is insufficient */

  // === Section dividers for organization ===
  // Use for grouping related fields/methods
}
```

**Comment Guidelines**:
- ✅ DO document public APIs with `///`
- ✅ DO explain WHY, not WHAT (code shows what)
- ✅ DO use section dividers for clarity
- ❌ DON'T state the obvious: `// increment counter`
- ❌ DON'T leave TODO comments (use issue tracker)
- ❌ DON'T comment out code (use version control)

### Null Safety

RantiPay uses **sound null safety**:

```dart
// ✅ CORRECT
String? nullableString;
String nonNullString = 'value';
final length = nullableString?.length ?? 0;
final upperCase = nonNullString.toUpperCase();

// Use null-aware operators
String? getName() => user?.name;
int getAge() => user?.age ?? 0;
List<String> getTags() => product?.tags ?? [];

// ❌ INCORRECT
String badString = nullableString!; // Avoid ! operator unless 100% sure
```

### Async/Await

Always handle errors with async operations:

```dart
// ✅ CORRECT
Future<void> loadData() async {
  try {
    emit(state.loading());
    final (data, failure) = await repository.getData();

    if (failure != null) {
      emit(state.failure(failure));
      return;
    }

    emit(state.success(data!));
  } catch (e, stackTrace) {
    errorHandler.handleError(e, stackTrace);
    emit(state.failure(FailureCommons.create(e.toString())));
  }
}

// ❌ INCORRECT
Future<void> badLoadData() async {
  final data = await repository.getData(); // No error handling
  emit(state.success(data));
}
```

---

## State Management

### BLoC Pattern

RantiPay uses **BLoC** (Business Logic Component) pattern with **Cubit** for simpler cases.

#### When to use BLoC vs Cubit

**Use Cubit** when:
- Simple state management
- No complex event transformation needed
- Straightforward state transitions

**Use BLoC** when:
- Complex event handling
- Event transformation/debouncing
- Multiple event sources

#### BLoC Structure

```dart
// 1. Define events (not needed for Cubit)
abstract class ProductEvent {}
class LoadProducts extends ProductEvent {}
class CreateProduct extends ProductEvent {
  final ProductEntity product;
  CreateProduct(this.product);
}

// 2. Define state
@freezed
class ProductState with _$ProductState {
  const factory ProductState.initial() = _Initial;
  const factory ProductState.loading() = _Loading;
  const factory ProductState.success(List<ProductEntity> products) = _Success;
  const factory ProductState.failure(FailureCommons failure) = _Failure;
}

// 3. Implement BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final IProductRepository _repository;

  ProductBloc({required IProductRepository repository})
      : _repository = repository,
        super(const ProductState.initial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProduct>(_onCreateProduct);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductState.loading());

    final (products, failure) = await _repository.getEntities();

    if (failure != null) {
      emit(ProductState.failure(failure));
      return;
    }

    emit(ProductState.success(products ?? []));
  }

  // ... other event handlers
}
```

#### Using BLoC in UI

```dart
// 1. Provide BLoC
BlocProvider(
  create: (context) => getIt<ProductBloc>()..add(LoadProducts()),
  child: ProductPage(),
)

// 2. Listen to state changes
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) {
    return state.when(
      initial: () => const SizedBox(),
      loading: () => const CircularProgressIndicator(),
      success: (products) => ProductList(products: products),
      failure: (failure) => ErrorWidget(message: failure.message),
    );
  },
)

// 3. Dispatch events
context.read<ProductBloc>().add(CreateProduct(product));

// 4. Listen to state without rebuilding
BlocListener<ProductBloc, ProductState>(
  listener: (context, state) {
    state.whenOrNull(
      success: (products) => showSnackBar('Success!'),
      failure: (failure) => showErrorDialog(failure.message),
    );
  },
  child: MyWidget(),
)
```

### Base CRUD BLoC

For standard CRUD operations, extend `BaseCrudBloc`:

```dart
@lazySingleton
class YourBloc extends BaseCrudBloc<YourEntity> {
  YourBloc({
    required IBaseRepository<YourEntity> repository,
    required IConnectivityService connectivityService,
    required ISearchService<YourEntity> searchService,
    required GlobalErrorHandler errorHandler,
  }) : super(
          repository: repository,
          connectivityService: connectivityService,
          searchService: searchService,
          errorHandler: errorHandler,
        );

  // Add custom methods beyond CRUD
  Future<void> customOperation() async {
    // Your logic here
  }
}
```

**BaseCrudBloc provides**:
- `LoadEntitiesEvent`: Load all entities
- `LoadEntityByIdEvent`: Load single entity
- `CreateEntityEvent`: Create new entity
- `UpdateEntityEvent`: Update entity
- `DeleteEntityEvent`: Delete entity
- `SearchEntitiesEvent`: Search entities
- `RefreshEntitiesEvent`: Refresh data
- `SyncEntitiesEvent`: Sync with server
- `SelectEntityEvent`: Select entity
- Automatic pagination support
- Real-time data watching
- Connectivity awareness

---

## Error Handling

### Error Handling Pattern

RantiPay uses **tuple-based error handling** (native Dart records):

```dart
// Repository method signature
Future<(ProductEntity?, FailureCommons?)> getEntityById(String id);

// Usage
Future<void> loadProduct(String id) async {
  final (product, failure) = await repository.getEntityById(id);

  if (failure != null) {
    // Handle error
    emit(state.failure(failure));
    return;
  }

  // Handle success
  emit(state.success(product!));
}
```

### Failure Types

```dart
// Generic failure
FailureCommons.create('Something went wrong');

// Network failures
FailureCommons.network('Connection timeout');

// Database failures
FailureCommons.database('Failed to save');

// Validation failures
FailureCommons.validation('Invalid input');

// Auth failures
FailureCommons.unauthorized('Session expired');

// With error code
FailureCommons.create('Error', errorCode: 'ERR_001');
```

### Error Interceptor

Dio requests automatically use error interceptor:

```dart
// lib/core/rantipay/rantipay_error_interceptor.dart
class RantiPayErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = _mapDioError(err);
    // Log error
    logger.error('API Error: ${failure.message}');
    // Continue with error
    handler.next(err);
  }
}
```

### Global Error Handler

For uncaught errors:

```dart
@injectable
class GlobalErrorHandler {
  void handleError(Object error, StackTrace stackTrace) {
    // Log to crash reporting
    logger.error('Uncaught error', error, stackTrace);

    // Show user-friendly message
    messageService.showError('Something went wrong');
  }
}
```

### Error Boundary Widget

Wrap pages with error boundary:

```dart
EnhancedPageScaffold(
  title: 'Product Management',
  body: ProductListWidget(),
  // Automatically catches and displays errors
)
```

---

## Code Generation

### Required Generators

RantiPay uses several code generators:

1. **Freezed**: Immutable entities with copyWith, equality
2. **json_serializable**: JSON serialization
3. **Injectable**: Dependency injection
4. **Drift**: Database code generation

### Running Code Generation

```bash
# Run all generators
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean generated files
flutter pub run build_runner clean
```

### Freezed Entities

Every entity should use Freezed:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_entity.freezed.dart';
part 'product_entity.g.dart';

@freezed
class ProductEntity with _$ProductEntity {
  const factory ProductEntity({
    required String id,
    required String name,
    @Default('') String description,
    required double price,
  }) = _ProductEntity;

  factory ProductEntity.fromJson(Map<String, dynamic> json) =>
      _$ProductEntityFromJson(json);
}
```

**Freezed Benefits**:
- Immutability by default
- `copyWith()` method
- `==` and `hashCode` implementation
- `toString()` implementation
- Pattern matching with `when/map`
- JSON serialization

### Injectable Dependency Injection

Mark services for DI with `@injectable` or `@lazySingleton`:

```dart
@lazySingleton
class ProductRepository implements IProductRepository {
  final ApiClient _apiClient;
  final Database _database;

  ProductRepository({
    required ApiClient apiClient,
    required Database database,
  })  : _apiClient = apiClient,
        _database = database;

  // Implementation...
}
```

**DI Annotations**:
- `@injectable`: New instance every time
- `@lazySingleton`: Single instance (lazy initialization)
- `@singleton`: Single instance (immediate initialization)
- `@preResolve`: Async factory (Future resolution)

### Drift Database

Define database tables with Drift:

```dart
import 'package:drift/drift.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().withLength(min: 1, max: 50)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  RealColumn get price => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Products])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
```

---

## Testing Strategy

### Test Structure

```
test/
├── unit/                  # Unit tests
│   ├── domain/            # Entity and business logic tests
│   ├── application/       # BLoC tests
│   └── infrastructure/    # Repository tests
├── widget/                # Widget tests
│   └── presentation/      # UI component tests
├── integration/           # Integration tests
│   └── features/          # Feature flow tests
├── golden/                # Golden (snapshot) tests
│   └── widgets/           # UI snapshot tests
└── fixtures/              # Test data
    └── json/              # JSON fixtures
```

### Unit Testing

```dart
// test/unit/domain/entities/product_entity_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';

void main() {
  group('ProductEntity', () {
    test('should create valid product', () {
      final product = ProductEntity(
        id: EntityIdentifier.temp('test_1'),
        metadata: EntityMetadata.create(),
        status: EntityStatus.active(),
        syncMeta: SyncMetadata.notSynced(),
        code: 'PROD001',
        name: 'Test Product',
        basePrice: 100.0,
        salePrice: 115.0,
        taxConfig: TaxConfiguration(),
        priceConfig: PriceConfiguration(),
        inventoryConfig: InventoryConfiguration(),
      );

      expect(product.name, 'Test Product');
      expect(product.basePrice, 100.0);
    });

    test('should validate required fields', () {
      final product = ProductEntity(
        // ... minimal fields
        code: '',
        name: '',
      );

      final (isValid, errors) = product.validate();

      expect(isValid, false);
      expect(errors, contains('El código del producto es obligatorio'));
    });
  });
}
```

### BLoC Testing

```dart
// test/unit/application/blocs/product_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements IProductRepository {}

void main() {
  late ProductBloc bloc;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    bloc = ProductBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('ProductBloc', () {
    blocTest<ProductBloc, ProductState>(
      'emits [loading, success] when products loaded successfully',
      build: () {
        when(() => mockRepository.getEntities())
            .thenAnswer((_) async => ([mockProduct], null));
        return bloc;
      },
      act: (bloc) => bloc.loadProducts(),
      expect: () => [
        ProductState.loading(),
        ProductState.success([mockProduct]),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [loading, failure] when load fails',
      build: () {
        when(() => mockRepository.getEntities())
            .thenAnswer((_) async => (null, FailureCommons.create('Error')));
        return bloc;
      },
      act: (bloc) => bloc.loadProducts(),
      expect: () => [
        ProductState.loading(),
        isA<ProductState>().having(
          (s) => s.maybeWhen(failure: (f) => f.message, orElse: () => ''),
          'error message',
          'Error',
        ),
      ],
    );
  });
}
```

### Widget Testing

```dart
// test/widget/presentation/widgets/product_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('ProductCard displays product info', (tester) async {
    final product = ProductEntity.createPhysicalProduct(
      code: 'PROD001',
      name: 'Test Product',
      price: 100.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(product: product),
        ),
      ),
    );

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('PROD001'), findsOneWidget);
    expect(find.text('\$100.00'), findsOneWidget);
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/domain/entities/product_entity_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Common Tasks

### Creating a New Feature

1. **Create feature directory structure**:
   ```bash
   mkdir -p lib/features/my_feature/{domain,application,infrastructure,presentation}/{entities,repositories,blocs,pages,widgets}
   ```

2. **Define domain entity**:
   ```dart
   // lib/features/my_feature/domain/entities/my_entity.dart
   import 'package:freezed_annotation/freezed_annotation.dart';
   import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_entity.dart';

   part 'my_entity.freezed.dart';
   part 'my_entity.g.dart';

   @freezed
   class MyEntity with _$MyEntity {
     const factory MyEntity({
       required EntityIdentifier id,
       required EntityMetadata metadata,
       required EntityStatus status,
       required SyncMetadata syncMeta,
       required String name,
     }) = _MyEntity;

     factory MyEntity.fromJson(Map<String, dynamic> json) =>
         _$MyEntityFromJson(json);
   }
   ```

3. **Define repository interface**:
   ```dart
   // lib/features/my_feature/domain/repositories/my_repository.dart
   abstract class IMyRepository {
     Future<(List<MyEntity>?, FailureCommons?)> getEntities();
     Future<(MyEntity?, FailureCommons?)> getEntityById(String id);
     // ... other methods
   }
   ```

4. **Create BLoC**:
   ```dart
   // lib/features/my_feature/application/blocs/my_bloc.dart
   @lazySingleton
   class MyBloc extends Cubit<MyState> {
     final IMyRepository _repository;

     MyBloc({required IMyRepository repository})
         : _repository = repository,
           super(MyState.initial());

     Future<void> loadData() async {
       emit(state.loading());
       final (data, failure) = await _repository.getEntities();
       if (failure != null) {
         emit(state.failure(failure));
       } else {
         emit(state.success(data!));
       }
     }
   }
   ```

5. **Implement repository**:
   ```dart
   // lib/features/my_feature/infrastructure/repositories/my_repository_impl.dart
   @LazySingleton(as: IMyRepository)
   class MyRepositoryImpl implements IMyRepository {
     final ApiClient _apiClient;

     MyRepositoryImpl({required ApiClient apiClient})
         : _apiClient = apiClient;

     @override
     Future<(List<MyEntity>?, FailureCommons?)> getEntities() async {
       try {
         final response = await _apiClient.get('/my-entities');
         final entities = (response.data as List)
             .map((json) => MyEntity.fromJson(json))
             .toList();
         return (entities, null);
       } catch (e) {
         return (null, FailureCommons.create(e.toString()));
       }
     }
   }
   ```

6. **Create presentation layer**:
   ```dart
   // lib/features/my_feature/presentation/pages/my_page.dart
   class MyPage extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return BlocProvider(
         create: (context) => getIt<MyBloc>()..loadData(),
         child: EnhancedPageScaffold(
           title: 'My Feature',
           body: BlocBuilder<MyBloc, MyState>(
             builder: (context, state) {
               return state.when(
                 initial: () => const SizedBox(),
                 loading: () => const CircularProgressIndicator(),
                 success: (data) => MyListWidget(data: data),
                 failure: (failure) => ErrorWidget(message: failure.message),
               );
             },
           ),
         ),
       );
     }
   }
   ```

7. **Run code generation**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

8. **Write tests**:
   ```bash
   # Create test files
   touch test/unit/domain/entities/my_entity_test.dart
   touch test/unit/application/blocs/my_bloc_test.dart
   touch test/widget/presentation/pages/my_page_test.dart
   ```

### Adding a New Dependency

1. **Add to pubspec.yaml**:
   ```yaml
   dependencies:
     new_package: ^1.0.0
   ```

2. **Get packages**:
   ```bash
   flutter pub get
   ```

3. **Document in CLAUDE.md** (this file) if it's a significant dependency

### Updating Tax Rates

Tax configuration is centralized in entities. To update from 12% to 15% IVA:

1. **Update tax configuration constant**:
   ```dart
   // lib/core/rantipay/constants/rantipay_app_constants.dart
   class TaxConstants {
     static const currentIvaRate = 15; // Changed from 12
     static const currentIvaCode = '2'; // SRI code for IVA 15%
   }
   ```

2. **Update existing entities**:
   - Run data migration script
   - Update mock data in repositories

### Database Migration

1. **Update Drift schema version**:
   ```dart
   @DriftDatabase(tables: [Products, Orders])
   class AppDatabase extends _$AppDatabase {
     @override
     int get schemaVersion => 2; // Increment

     @override
     MigrationStrategy get migration {
       return MigrationStrategy(
         onUpgrade: (migrator, from, to) async {
           if (from == 1) {
             // Migration from v1 to v2
             await migrator.addColumn(products, products.newColumn);
           }
         },
       );
     }
   }
   ```

2. **Test migration**:
   ```bash
   flutter test test/integration/database_migration_test.dart
   ```

---

## Key Patterns

### Repository Pattern

All data access goes through repositories:

```dart
// Interface (in domain layer)
abstract class IProductRepository {
  Future<(List<ProductEntity>?, FailureCommons?)> getEntities();
  Future<(ProductEntity?, FailureCommons?)> createEntity(ProductEntity entity);
}

// Implementation (in infrastructure layer)
@LazySingleton(as: IProductRepository)
class ProductRepositoryImpl implements IProductRepository {
  final ProductApiClient _apiClient;
  final ProductLocalDataSource _localDataSource;

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> getEntities() async {
    try {
      // Try API first
      final dto = await _apiClient.getProducts();
      final entities = dto.map((d) => d.toEntity()).toList();

      // Cache locally
      await _localDataSource.saveAll(entities);

      return (entities, null);
    } on NetworkException catch (e) {
      // Fallback to local cache
      final cached = await _localDataSource.getAll();
      return (cached, null);
    } catch (e) {
      return (null, FailureCommons.create(e.toString()));
    }
  }
}
```

### DTO Pattern

DTOs handle API data, entities handle business logic:

```dart
// DTO (infrastructure layer)
@JsonSerializable()
class ProductDto {
  final String id;
  final String name;
  final double price;

  ProductDto({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDtoToJson(this);

  // Convert to domain entity
  ProductEntity toEntity() {
    return ProductEntity(
      id: EntityIdentifier.server(id),
      metadata: EntityMetadata.create(),
      status: EntityStatus.active(),
      syncMeta: SyncMetadata.synced(),
      code: id,
      name: name,
      basePrice: price,
      salePrice: price,
      taxConfig: TaxConfiguration(),
      priceConfig: PriceConfiguration(),
      inventoryConfig: InventoryConfiguration(),
    );
  }
}
```

### Use Case Pattern

For complex operations, use the use case pattern:

```dart
// lib/features/my_feature/application/usecases/create_product_usecase.dart
@injectable
class CreateProductUseCase {
  final IProductRepository _repository;
  final IValidationService _validation;

  CreateProductUseCase({
    required IProductRepository repository,
    required IValidationService validation,
  })  : _repository = repository,
        _validation = validation;

  Future<(ProductEntity?, FailureCommons?)> call(
    CreateProductParams params,
  ) async {
    // 1. Validate input
    final (isValid, errors) = _validation.validateProduct(params);
    if (!isValid) {
      return (null, FailureCommons.validation(errors.join(', ')));
    }

    // 2. Check for duplicates
    final (duplicate, _) = await _repository.findDuplicateProduct(
      name: params.name,
      category: params.category,
    );
    if (duplicate != null) {
      return (null, FailureCommons.validation('Product already exists'));
    }

    // 3. Create entity
    final product = ProductEntity(
      id: EntityIdentifier.temp('product_${DateTime.now().millisecondsSinceEpoch}'),
      metadata: EntityMetadata.create(),
      status: EntityStatus.active(),
      syncMeta: SyncMetadata.notSynced(),
      code: params.code,
      name: params.name,
      basePrice: params.price,
      salePrice: params.price,
      taxConfig: params.taxConfig,
      priceConfig: PriceConfiguration(),
      inventoryConfig: InventoryConfiguration(),
    );

    // 4. Save
    return await _repository.createEntity(product);
  }
}

@freezed
class CreateProductParams with _$CreateProductParams {
  const factory CreateProductParams({
    required String code,
    required String name,
    required double price,
    required String category,
    required TaxConfiguration taxConfig,
  }) = _CreateProductParams;
}
```

### Offline-First Pattern

All repositories should support offline-first:

```dart
@LazySingleton(as: IProductRepository)
class ProductRepositoryImpl implements IProductRepository {
  final ProductApiClient _apiClient;
  final ProductLocalDataSource _localDataSource;
  final IConnectivityService _connectivity;

  @override
  Future<(List<ProductEntity>?, FailureCommons?)> getEntities() async {
    try {
      // 1. Return cached data immediately
      final cached = await _localDataSource.getAll();

      // 2. If online, fetch fresh data in background
      if (await _connectivity.isConnected) {
        _fetchAndUpdateCache();
      }

      return (cached, null);
    } catch (e) {
      return (null, FailureCommons.create(e.toString()));
    }
  }

  Future<void> _fetchAndUpdateCache() async {
    try {
      final dto = await _apiClient.getProducts();
      final entities = dto.map((d) => d.toEntity()).toList();
      await _localDataSource.saveAll(entities);
    } catch (e) {
      // Silently fail - user already has cached data
      logger.warning('Background sync failed: $e');
    }
  }
}
```

### Extension Pattern

Use extensions to add utility methods:

```dart
extension ProductEntityExtensions on ProductEntity {
  /// Calculate total price with taxes
  double getPriceWithTaxes() {
    return taxConfig.calculateTotalWithTaxes(basePrice);
  }

  /// Check if product is available for sale
  bool get isAvailableForSale {
    if (!isActive) return false;
    if (inventoryConfig.isManaged && inventoryConfig.currentStock <= 0) {
      return inventoryConfig.allowNegativeStock;
    }
    return true;
  }

  /// Generate search tags
  List<String> generateSearchTags() {
    return [
      ...name.toLowerCase().split(' '),
      code.toLowerCase(),
      if (brand != null) brand!.toLowerCase(),
      category.code,
    ].where((tag) => tag.isNotEmpty).toSet().toList();
  }
}
```

---

## Security Guidelines

### Sensitive Data Storage

**NEVER** store sensitive data in plain text:

```dart
// ✅ CORRECT
import 'package:rantipay_app/core/rantipay/rantipay_secure_storage.dart';

@injectable
class AuthService {
  final RantiPaySecureStorage _secureStorage;

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }
}

// ❌ INCORRECT
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token); // INSECURE!
```

### API Keys and Secrets

**CRITICAL**: Never commit secrets to version control:

1. **Use environment variables**:
   ```dart
   // assets/.env
   API_KEY=your_api_key_here
   API_URL=https://api.example.com
   ```

2. **Load with flutter_dotenv**:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';

   await dotenv.load(fileName: 'assets/.env');
   final apiKey = dotenv.env['API_KEY'];
   ```

3. **Add .env to .gitignore**:
   ```gitignore
   assets/.env
   .env
   ```

### Certificate Pinning

API clients should use certificate pinning:

```dart
import 'package:rantipay_app/core/rantipay/rantipay_certificate_pinning.dart';

@lazySingleton
class SecureApiClient {
  final Dio _dio;

  SecureApiClient() : _dio = Dio() {
    _dio.interceptors.add(
      RantiPayCertificatePinning.createInterceptor(),
    );
  }
}
```

### Jailbreak/Root Detection

Check device security status:

```dart
import 'package:rantipay_app/core/rantipay/rantipay_jailbreak_detection.dart';

@injectable
class SecurityService {
  final RantiPayJailbreakDetection _detection;

  Future<bool> isDeviceSecure() async {
    final isJailbroken = await _detection.isJailbroken();
    if (isJailbroken) {
      // Show warning or restrict functionality
      return false;
    }
    return true;
  }
}
```

### Biometric Authentication

Enable biometric auth for sensitive operations:

```dart
import 'package:rantipay_app/core/rantipay/rantipay_biometric_service.dart';

@injectable
class AuthService {
  final RantiPayBiometricService _biometric;

  Future<bool> authenticateUser() async {
    final canUseBiometric = await _biometric.canCheckBiometrics();
    if (!canUseBiometric) return false;

    return await _biometric.authenticate(
      localizedReason: 'Authenticate to access your account',
    );
  }
}
```

### Input Validation

Always validate and sanitize user input:

```dart
import 'package:rantipay_app/core/rantipay/constants/rantipay_regex_patterns.dart';

class ValidationService {
  bool isValidEmail(String email) {
    return RantiPayRegexPatterns.email.hasMatch(email);
  }

  bool isValidPhone(String phone) {
    return RantiPayRegexPatterns.phone.hasMatch(phone);
  }

  String sanitizeInput(String input) {
    // Remove potential XSS/SQL injection attempts
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'[;\'"\\]'), ''); // Remove SQL injection chars
  }
}
```

---

## Dependencies Guide

### State Management

- **bloc** (^8.1.2): Core BLoC pattern implementation
- **flutter_bloc** (^8.1.3): Flutter widgets for BLoC
- **hydrated_bloc** (^9.1.5): Persistent state across app restarts
- **provider** (^6.1.1): Simple dependency injection for widgets

### Dependency Injection

- **get_it** (^7.6.4): Service locator
- **injectable** (^2.3.2): Code generation for DI

### Functional Programming

- **dartz** (^0.10.1): Functional programming (Either, Option, etc.)
- **equatable** (^2.0.5): Value equality

### Network

- **dio** (^5.4.0): HTTP client
- **dio_cookie_manager** (^3.1.1): Cookie management
- **cookie_jar** (^4.0.8): Cookie storage
- **web_socket_channel** (^2.4.0): WebSocket support
- **connectivity_plus** (^5.0.2): Network connectivity
- **internet_connection_checker** (^1.0.0+1): Connection validation

### Database

- **drift** (^2.16.0): Type-safe SQL database
- **sqlite3** (^2.4.0): SQLite for Dart
- **sqflite** (^2.3.3+1): SQLite for Flutter
- **sqlcipher_flutter_libs** (^0.6.8): Encrypted SQLite
- **sembast** (^3.7.1): NoSQL database

### Storage

- **shared_preferences** (^2.2.2): Key-value storage
- **flutter_secure_storage** (^9.2.4): Encrypted storage
- **flutter_cache_manager** (^3.3.1): File caching

### Code Generation

- **freezed** (^2.4.6): Immutable classes
- **json_serializable** (^6.7.1): JSON serialization
- **build_runner** (^2.4.7): Code generation runner

### UI Components

- **google_fonts** (^6.2.1): Google Fonts
- **font_awesome_flutter** (^10.7.0): FontAwesome icons
- **flutter_svg** (^2.2.0): SVG rendering
- **lottie** (^3.3.1): Lottie animations
- **shimmer** (^3.0.0): Shimmer effects
- **loading_animation_widget** (^1.2.0+4): Loading animations

### Media & Camera

- **camera** (0.10.3+2): Camera access
- **image_picker** (^1.2.0): Pick images
- **video_player** (^2.9.5): Video playback
- **just_audio** (^0.10.5): Audio playback
- **record** (^6.1.1): Audio recording
- **flutter_image_compress** (^2.1.0): Image compression

### Maps & Location

- **google_maps_flutter** (^2.5.0): Google Maps
- **geolocator** (^14.0.2): Location services

### Firebase

- **firebase_core** (^3.6.0): Firebase initialization
- **firebase_messaging** (^15.1.3): Push notifications

### Security

- **encrypt** (^5.0.3): Encryption utilities
- **local_auth** (^2.3.0): Biometric authentication
- **jailbreak_root_detection** (^1.1.6): Device security check
- **jwt_decoder** (^2.0.1): JWT token parsing

### Matrix Chat (FluffyChat Integration)

- **matrix** (^3.0.1): Matrix protocol SDK
- **flutter_vodozemac** (^0.3.0): E2E encryption
- **emoji_picker_flutter** (^4.3.0): Emoji picker
- **flutter_webrtc** (^1.2.0): Video/audio calls
- **qr_code_scanner_plus** (^2.0.13): QR code scanning

### Utilities

- **intl** (^0.20.2): Internationalization
- **uuid** (^4.4.0): UUID generation
- **url_launcher** (^6.3.2): Launch URLs
- **share_plus** (^12.0.1): Share content
- **permission_handler** (^12.0.1): Permissions

---

## Feature Development Workflow

### Step-by-Step Guide

#### 1. Planning Phase

- **Define requirements**: Understand feature scope
- **Check SRS document**: Review `srs.md` for specifications
- **Identify affected modules**: List features that will interact
- **Plan architecture**: Decide on layers and dependencies

#### 2. Domain Layer (Pure Business Logic)

**Create entities:**
```bash
lib/features/my_feature/domain/entities/my_entity.dart
```

**Define repository interface:**
```bash
lib/features/my_feature/domain/repositories/my_repository.dart
```

**Run code generation:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 3. Application Layer (Use Cases & BLoCs)

**Create BLoC/Cubit:**
```bash
lib/features/my_feature/application/blocs/my_bloc.dart
lib/features/my_feature/application/blocs/my_state.dart
```

**Define events (if using BLoC):**
```bash
lib/features/my_feature/application/blocs/my_event.dart
```

**Register with DI:**
```dart
@lazySingleton
class MyBloc extends Cubit<MyState> { ... }
```

#### 4. Infrastructure Layer (Data & External Services)

**Create DTOs:**
```bash
lib/features/my_feature/infrastructure/dtos/my_dto.dart
```

**Implement repository:**
```bash
lib/features/my_feature/infrastructure/repositories/my_repository_impl.dart
```

**Create API client:**
```bash
lib/features/my_feature/infrastructure/api/my_api_client.dart
```

**Create local data source:**
```bash
lib/features/my_feature/infrastructure/datasources/my_local_datasource.dart
```

#### 5. Presentation Layer (UI)

**Create pages:**
```bash
lib/features/my_feature/presentation/pages/my_page.dart
```

**Create widgets:**
```bash
lib/features/my_feature/presentation/widgets/my_widget.dart
```

**Add routing:**
```dart
// lib/features/my_feature/my_feature_routes.dart
class MyFeatureRoutes {
  static const myPage = '/my-feature';
}
```

#### 6. Testing

**Write unit tests:**
```bash
test/unit/domain/entities/my_entity_test.dart
test/unit/application/blocs/my_bloc_test.dart
```

**Write widget tests:**
```bash
test/widget/presentation/pages/my_page_test.dart
```

**Run tests:**
```bash
flutter test
```

#### 7. Integration

**Update main app:**
- Add routing
- Register dependencies
- Update navigation

**Test integration:**
- Manual testing
- Integration tests

#### 8. Documentation

**Update CLAUDE.md** (this file):
- Document new patterns
- Add to dependencies if needed
- Update architecture diagram

**Update code comments:**
- Public API documentation
- Complex logic explanation

#### 9. Code Review Checklist

- [ ] Clean Architecture layers respected
- [ ] Error handling implemented
- [ ] Null safety followed
- [ ] Tests written and passing
- [ ] Code generation run
- [ ] No hardcoded strings (use i18n)
- [ ] No secrets in code
- [ ] Offline support implemented
- [ ] Loading states handled
- [ ] Error states handled
- [ ] Accessibility considered
- [ ] Documentation updated

#### 10. Commit & Push

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: implement product management CRUD

- Add ProductEntity with full validation
- Implement ProductBloc with search and CRUD
- Create ProductRepositoryImpl with offline support
- Add ProductSelectionPage UI
- Write comprehensive tests (unit + widget)
- Update CLAUDE.md with patterns"

# Push to feature branch
git push origin feature/product-management
```

---

## Additional Resources

### Official Documentation

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [BLoC Library](https://bloclibrary.dev/)
- [Freezed](https://pub.dev/packages/freezed)
- [Drift](https://drift.simonbinder.eu/)
- [GetIt](https://pub.dev/packages/get_it)
- [Injectable](https://pub.dev/packages/injectable)

### Code Style

- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)

### Project-Specific

- **SRS Document**: See `srs.md` for requirements
- **README**: See `README.md` for setup instructions
- **Architecture Diagrams**: See `/docs/architecture/` (if available)

---

## Quick Reference

### Common Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean build
flutter clean && flutter pub get

# Analyze code
flutter analyze

# Format code
dart format lib/ test/

# Run on specific device
flutter devices
flutter run -d <device_id>

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

### Code Snippets

#### Quick Entity Template

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rantipay_app/core/rantipay/rantipay_base/domain/entities/base_entity.dart';

part 'my_entity.freezed.dart';
part 'my_entity.g.dart';

@freezed
class MyEntity with _$MyEntity {
  const factory MyEntity({
    required EntityIdentifier id,
    required EntityMetadata metadata,
    required EntityStatus status,
    required SyncMetadata syncMeta,
    required String name,
  }) = _MyEntity;

  factory MyEntity.fromJson(Map<String, dynamic> json) =>
      _$MyEntityFromJson(json);
}
```

#### Quick BLoC Template

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class MyBloc extends Cubit<MyState> {
  final IMyRepository _repository;

  MyBloc({required IMyRepository repository})
      : _repository = repository,
        super(MyState.initial());

  Future<void> loadData() async {
    emit(state.loading());
    final (data, failure) = await _repository.getData();
    if (failure != null) {
      emit(state.failure(failure));
    } else {
      emit(state.success(data!));
    }
  }
}
```

#### Quick Repository Template

```dart
import 'package:injectable/injectable.dart';

@LazySingleton(as: IMyRepository)
class MyRepositoryImpl implements IMyRepository {
  final ApiClient _apiClient;
  final LocalDataSource _localDataSource;

  MyRepositoryImpl({
    required ApiClient apiClient,
    required LocalDataSource localDataSource,
  })  : _apiClient = apiClient,
        _localDataSource = localDataSource;

  @override
  Future<(List<MyEntity>?, FailureCommons?)> getEntities() async {
    try {
      final dto = await _apiClient.get('/entities');
      final entities = dto.map((d) => d.toEntity()).toList();
      await _localDataSource.saveAll(entities);
      return (entities, null);
    } catch (e) {
      return (null, FailureCommons.create(e.toString()));
    }
  }
}
```

---

## Conclusion

This guide covers the essential patterns, conventions, and workflows for developing features in RantiPay V2. Always prioritize:

1. **Clean Architecture**: Keep layers separated
2. **Type Safety**: Use Freezed and proper null safety
3. **Error Handling**: Always handle errors gracefully
4. **Testing**: Write tests for critical paths
5. **Security**: Never compromise on security
6. **Offline-First**: Support offline usage
7. **Documentation**: Keep this guide updated

When in doubt:
- Refer to existing features as examples
- Follow the patterns in `lib/core/rantipay/rantipay_base/`
- Ask questions and document answers
- Keep the codebase clean and maintainable

**Happy coding!** 🚀
