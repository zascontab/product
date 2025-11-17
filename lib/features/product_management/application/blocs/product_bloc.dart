import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rantipay_app/core/errors/failure_commons.dart';
import 'package:rantipay_app/features/product_management/application/blocs/product_state.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';
import 'package:rantipay_app/features/product_management/domain/repositories/product_repository.dart';




/// Simple BLoC for product management
/// Handles product-specific operations without extending BaseCrudBloc
/// until IBaseEntity implementation is resolved
@lazySingleton
class ProductBloc extends Cubit<ProductState> {
  final IProductRepository _productRepository;

  ProductBloc({
    required IProductRepository repository,
  })  : _productRepository = repository,
        super(ProductState.initial());

  /// Repository typed for product operations
  IProductRepository get productRepository => _productRepository;

  /// Search products by query (name, code, barcode)
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      await loadProducts();
      return;
    }

    try {
      emit(state.search(query));

      final (products, failure) = await _productRepository.searchProducts(
        query: query,
        limit: 50,
      );

      if (failure != null) {
        emit(state.failure(failure));
        return;
      }

      emit(state.success(products ?? []));
    } catch (e) {
      emit(state.failure(
        FailureCommons.create('Error al buscar productos: ${e.toString()}'),
      ));
    }
  }

  /// Load all products
  Future<void> loadProducts() async {
    try {
      emit(state.loading());

      final (products, failure) = await _productRepository.getEntities();

      if (failure != null) {
        emit(state.failure(failure));
        return;
      }

      emit(state.success(products ?? []));
    } catch (e) {
      emit(state.failure(
        FailureCommons.create('Error al cargar productos: ${e.toString()}'),
      ));
    }
  }

  /// Get products by category
  Future<void> getProductsByCategory(String category) async {
    try {
      emit(state.loading());

      final (products, failure) = await _productRepository.getProductsByCategory(
        category,
        limit: 100,
      );

      if (failure != null) {
        emit(state.failure(failure));
        return;
      }

      emit(state.success(products ?? []));
    } catch (e) {
      emit(state.failure(
        FailureCommons.create('Error al obtener productos por categoría: ${e.toString()}'),
      ));
    }
  }

  /// Validate product creation (check for duplicates)
  Future<(bool, List<String>)> validateProductCreation(ProductEntity product) async {
    try {
      final errors = <String>[];

      // Basic entity validation
      final (isValid, validationErrors) = product.baseValidate();
      if (!isValid) {
        errors.addAll(validationErrors);
      }

      // Check for duplicates
      final (existingProduct, failure) = await _productRepository.findDuplicateProduct(
        name: product.name,
        category: product.category.code,
        brand: product.brand,
      );

      if (failure == null && existingProduct != null) {
        errors.add('Ya existe un producto con estas características');
      }

      return (errors.isEmpty, errors);
    } catch (e) {
      return (false, ['Error al validar el producto: ${e.toString()}']);
    }
  }

  /// Create product with validation
  Future<void> createProduct(ProductEntity product) async {
    try {
      // Validate first
      final (isValid, errors) = await validateProductCreation(product);
      if (!isValid) {
        emit(state.failure(
          FailureCommons.create('Errores de validación: ${errors.join(', ')}'),
        ));
        return;
      }

      emit(state.loading());

      final (createdProduct, failure) = await _productRepository.createEntity(product);

      if (failure != null) {
        emit(state.failure(failure));
        return;
      }

      // Update the current product list with the new product
      final updatedProducts = [createdProduct!, ...state.products];
      emit(state.success(updatedProducts).selectProduct(createdProduct));

    } catch (e) {
      emit(state.failure(
        FailureCommons.create('Error al crear producto: ${e.toString()}'),
      ));
    }
  }

  /// Update product
  Future<void> updateProduct(ProductEntity product) async {
    try {
      emit(state.loading());

      final (updatedProduct, failure) = await _productRepository.updateEntity(product);

      if (failure != null) {
        emit(state.failure(failure));
        return;
      }

      // Update the product in the current list
      final updatedProducts = state.products.map((p) {
        if (p.id.uniqueKey == product.id.uniqueKey) {
          return updatedProduct!;
        }
        return p;
      }).toList();

      emit(state.success(updatedProducts).selectProduct(updatedProduct!));

    } catch (e) {
      emit(state.failure(
        FailureCommons.create('Error al actualizar producto: ${e.toString()}'),
      ));
    }
  }

  /// Select product
  void selectProduct(ProductEntity product) {
    emit(state.selectProduct(product));
  }

  /// Clear selection
  void clearSelection() {
    emit(state.copyWith(selectedProduct: null));
  }

  /// Get products suitable for invoicing
  Future<void> getInvoiceableProducts() async {
    try {
      emit(state.loading());

      final (products, failure) = await _productRepository.getInvoiceableProducts(
        limit: 100,
      );

      if (failure != null) {
        emit(state.failure(failure));
        return;
      }

      emit(state.success(products ?? []));
    } catch (e) {
      emit(state.failure(
        FailureCommons.create('Error al obtener productos facturables: ${e.toString()}'),
      ));
    }
  }

  /// Validate product sale
  Future<(bool, List<String>)> validateProductSale({
    required String productId,
    required int quantity,
  }) async {
    try {
      return await _productRepository.validateSale(
        productId: productId,
        quantity: quantity,
      );
    } catch (e) {
      return (false, ['Error al validar la venta: ${e.toString()}']);
    }
  }

  /// Get low stock products
  Future<void> getLowStockProducts() async {
    try {
      emit(state.loading());

      final (products, failure) = await _productRepository.getLowStockProducts(
        limit: 50,
      );

      if (failure != null) {
        emit(state.failure(failure));
        return;
      }

      emit(state.success(products ?? []));
    } catch (e) {
      emit(state.failure(
        FailureCommons.create('Error al obtener productos con bajo stock: ${e.toString()}'),
      ));
    }
  }
}
