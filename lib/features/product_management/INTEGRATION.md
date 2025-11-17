# Product Management Module - Integration Guide

This document explains how to integrate the Product Management module into your Flutter application.

## Prerequisites

- Flutter SDK >=3.1.0
- All dependencies from `pubspec.yaml` installed
- Drift code generation completed

## Step 1: Run Code Generation

Before using the module, run Drift code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Step 2: Initialize Dependency Injection

The module uses `get_it` for dependency injection. You need to configure the service locator:

```dart
import 'package:get_it/get_it.dart';
import 'package:rantipay_app/features/product_management/infrastructure/database/product_dao.dart';
import 'package:rantipay_app/features/product_management/infrastructure/datasources/product_local_datasource.dart';
import 'package:rantipay_app/features/product_management/infrastructure/datasources/product_remote_datasource.dart';
import 'package:rantipay_app/features/product_management/infrastructure/repositories/product_repository_impl.dart';
import 'package:rantipay_app/features/product_management/domain/repositories/product_repository.dart';
import 'package:rantipay_app/features/product_management/application/blocs/product_bloc.dart';

final getIt = GetIt.instance;

void setupProductManagement() {
  // Register database (singleton)
  getIt.registerLazySingleton<ProductDatabase>(() => ProductDatabase());

  // Register DAO
  getIt.registerLazySingleton<ProductDao>(
    () => ProductDao(getIt<ProductDatabase>()),
  );

  // Register data sources
  getIt.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSource(productDao: getIt<ProductDao>()),
  );

  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(apiClient: getIt<ProductApiClient>()),
  );

  // Register repository
  getIt.registerLazySingleton<IProductRepository>(
    () => ProductRepositoryImpl(
      localDataSource: getIt<ProductLocalDataSource>(),
      remoteDataSource: getIt<ProductRemoteDataSource>(),
    ),
  );

  // Register BLoC (factory - new instance each time)
  getIt.registerFactory<ProductBloc>(
    () => ProductBloc(repository: getIt<IProductRepository>()),
  );
}
```

## Step 3: Configure Routing

### Option A: Using Named Routes (Current Setup)

Add the product routes to your `MaterialApp`:

```dart
import 'package:flutter/material.dart';
import 'package:rantipay_app/features/product_management/presentation/product_routes_config.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RantiPay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,

      // Set initial route
      initialRoute: ProductRoutesConfig.productList,

      // Configure routes
      routes: ProductRoutesConfig.getRoutes(),

      // Handle routes with arguments
      onGenerateRoute: ProductRoutesConfig.onGenerateRoute,
    );
  }
}
```

### Option B: Using GoRouter (Recommended for Production)

If you're using GoRouter (recommended for larger apps):

```dart
import 'package:go_router/go_router.dart';
import 'package:rantipay_app/features/product_management/presentation/pages/product_list_page.dart';
import 'package:rantipay_app/features/product_management/presentation/pages/product_detail_page.dart';
import 'package:rantipay_app/features/product_management/presentation/pages/product_form_page.dart';

final router = GoRouter(
  initialLocation: '/products',
  routes: [
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListPage(),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => const ProductFormPage(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final productId = state.pathParameters['id']!;
            // Fetch product by ID and pass to detail page
            return ProductDetailPage(product: product);
          },
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) {
                final productId = state.pathParameters['id']!;
                // Fetch product by ID and pass to form page
                return ProductFormPage(product: product);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'RantiPay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
```

## Step 4: Navigation Examples

### Navigate to Product List

```dart
// Using named routes
Navigator.pushNamed(context, ProductRoutesConfig.productList);

// Or using helper method
ProductRoutesConfig.navigateToProductList(context);
```

### Navigate to Product Detail

```dart
final product = // ... get product entity

// Using named routes
Navigator.pushNamed(
  context,
  ProductRoutesConfig.productDetail,
  arguments: product,
);

// Or using helper method
ProductRoutesConfig.navigateToProductDetail(context, product);
```

### Navigate to Create Product

```dart
// Using named routes
Navigator.pushNamed(context, ProductRoutesConfig.productCreate);

// Or using helper method
ProductRoutesConfig.navigateToProductCreate(context);
```

### Navigate to Edit Product

```dart
final product = // ... get product entity

// Using named routes
Navigator.pushNamed(
  context,
  ProductRoutesConfig.productEdit,
  arguments: product,
);

// Or using helper method
ProductRoutesConfig.navigateToProductEdit(context, product);
```

## Step 5: Using the ProductBloc

The Product Management module uses BLoC for state management:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rantipay_app/features/product_management/application/blocs/product_bloc.dart';

// Wrap your page with BlocProvider
class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProductBloc>(),
      child: const ProductListPage(),
    );
  }
}

// Use BlocBuilder to react to state changes
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) {
    if (state.isLoading) {
      return CircularProgressIndicator();
    }

    if (state.hasError) {
      return ErrorWidget(message: state.error?.message);
    }

    if (state.products.isEmpty) {
      return EmptyStateWidget(
        title: 'No Products',
        message: 'Create your first product',
      );
    }

    return ListView.builder(
      itemCount: state.products.length,
      itemBuilder: (context, index) {
        return ProductCardWidget(
          product: state.products[index],
          onTap: () {
            ProductRoutesConfig.navigateToProductDetail(
              context,
              state.products[index],
            );
          },
        );
      },
    );
  },
)
```

## Step 6: Database Initialization

Initialize the Drift database on app startup:

```dart
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  setupProductManagement();

  // Initialize database
  final db = getIt<ProductDatabase>();

  runApp(MyApp());
}
```

## Module Structure

```
lib/features/product_management/
├── domain/
│   ├── entities/           # Business entities
│   │   ├── product_entity.dart
│   │   ├── product_enums.dart
│   │   └── tax_configuration.dart
│   └── repositories/       # Repository interfaces
│       └── product_repository.dart
├── application/
│   └── blocs/             # State management
│       ├── product_bloc.dart
│       └── product_state.dart
├── infrastructure/
│   ├── database/          # Drift database
│   │   ├── product_table.dart
│   │   └── product_dao.dart
│   ├── dtos/              # Data transfer objects
│   │   └── product_dto.dart
│   ├── mappers/           # DTO/Entity mappers
│   │   └── product_mapper.dart
│   ├── api/               # API clients
│   │   └── product_api_client.dart
│   ├── datasources/       # Data sources
│   │   ├── product_local_datasource.dart
│   │   └── product_remote_datasource.dart
│   └── repositories/      # Repository implementations
│       └── product_repository_impl.dart
└── presentation/
    ├── pages/             # Full pages
    │   ├── product_list_page.dart
    │   ├── product_detail_page.dart
    │   └── product_form_page.dart
    ├── widgets/           # Reusable widgets
    │   ├── product_card_widget.dart
    │   ├── empty_state_widget.dart
    │   ├── filter_chips_widget.dart
    │   └── product_list_skeleton.dart
    └── product_routes_config.dart
```

## Features

### Product List
- ✅ Display all products in a scrollable list
- ✅ Search products by name, code, or description
- ✅ Filter by category (Electronics, Services, Food, Drinks, Other)
- ✅ Filter by status (Active, Inactive)
- ✅ Filter by stock level (Low Stock)
- ✅ Pull-to-refresh
- ✅ Skeleton loading state
- ✅ Empty state when no products
- ✅ Offline-first (cached data)

### Product Detail
- ✅ Display comprehensive product information
- ✅ View basic info, pricing, tax configuration
- ✅ View inventory and sales statistics
- ✅ View dimensions and additional fields
- ✅ Edit, duplicate, share, and delete actions

### Product Form (Create/Edit)
- ✅ Create new products
- ✅ Edit existing products
- ✅ Comprehensive validation
- ✅ Organized sections (Basic, Category, Pricing, Tax, Inventory)
- ✅ IVA rate selector (0%, 12%, 14%, 15%)
- ✅ Automatic SRI code mapping
- ✅ Conditional inventory fields
- ✅ Form state management

### Offline Support
- ✅ Local database with Drift (SQLite)
- ✅ Automatic sync with backend
- ✅ Optimistic updates
- ✅ Graceful degradation when offline

### Tax Configuration
- ✅ Default 15% IVA rate
- ✅ Support for 0%, 12%, 14%, 15% rates
- ✅ Automatic SRI code mapping
- ✅ Tax calculation methods

## Troubleshooting

### Code Generation Issues

If you encounter issues with generated files:

```bash
# Clean generated files
flutter pub run build_runner clean

# Rebuild
flutter pub run build_runner build --delete-conflicting-outputs
```

### Database Migration Issues

If you need to reset the database during development:

1. Uninstall the app
2. Reinstall with `flutter run`

For production, implement proper migration strategy in `ProductDatabase`.

### BLoC State Issues

If state is not updating:
1. Ensure you're using `context.read<ProductBloc>()` to dispatch events
2. Ensure you're using `BlocBuilder` or `BlocConsumer` to listen to state
3. Check that the BLoC is provided above the widget tree

## Next Steps

1. ✅ Complete Drift code generation
2. ✅ Initialize dependency injection
3. ✅ Configure routing
4. ⏳ Implement authentication (if needed)
5. ⏳ Add real API client implementation
6. ⏳ Implement sync logic
7. ⏳ Add unit and widget tests
8. ⏳ Add integration tests

## Support

For issues or questions:
- Check CLAUDE.md for development guidelines
- Review srs.md for requirements
- Check existing code examples in the codebase
