import 'package:flutter/material.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';
import 'package:rantipay_app/features/product_management/presentation/pages/product_detail_page.dart';
import 'package:rantipay_app/features/product_management/presentation/pages/product_form_page.dart';
import 'package:rantipay_app/features/product_management/presentation/pages/product_list_page.dart';

/// Product Management Routes Configuration
/// Defines all routes for the product management module
class ProductRoutesConfig {
  ProductRoutesConfig._();

  // Route names
  static const String productList = '/products';
  static const String productDetail = '/products/detail';
  static const String productCreate = '/products/create';
  static const String productEdit = '/products/edit';

  /// Generates routes for the product management module
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case productList:
        return MaterialPageRoute(
          builder: (_) => const ProductListPage(),
          settings: settings,
        );

      case productDetail:
        final product = settings.arguments as ProductEntity?;
        if (product == null) {
          return _errorRoute('Product not provided');
        }
        return MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product),
          settings: settings,
        );

      case productCreate:
        return MaterialPageRoute(
          builder: (_) => const ProductFormPage(),
          settings: settings,
        );

      case productEdit:
        final product = settings.arguments as ProductEntity?;
        if (product == null) {
          return _errorRoute('Product not provided');
        }
        return MaterialPageRoute(
          builder: (_) => ProductFormPage(product: product),
          settings: settings,
        );

      default:
        return null;
    }
  }

  /// Gets all routes as a Map for MaterialApp
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      productList: (context) => const ProductListPage(),
      // Note: Detail, Create, and Edit routes require arguments
      // Use Navigator.pushNamed with arguments instead
    };
  }

  /// Helper method to navigate to product list
  static Future<void> navigateToProductList(BuildContext context) {
    return Navigator.pushNamed(context, productList);
  }

  /// Helper method to navigate to product detail
  static Future<void> navigateToProductDetail(
    BuildContext context,
    ProductEntity product,
  ) {
    return Navigator.pushNamed(
      context,
      productDetail,
      arguments: product,
    );
  }

  /// Helper method to navigate to create product
  static Future<void> navigateToProductCreate(BuildContext context) {
    return Navigator.pushNamed(context, productCreate);
  }

  /// Helper method to navigate to edit product
  static Future<void> navigateToProductEdit(
    BuildContext context,
    ProductEntity product,
  ) {
    return Navigator.pushNamed(
      context,
      productEdit,
      arguments: product,
    );
  }

  /// Error route for invalid navigation
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Navigation Error',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
