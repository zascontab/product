import 'package:rantipay_app/core/errors/failure_commons.dart';
import 'package:rantipay_app/features/product_management/domain/entities/product_entity.dart';


/// State for ProductBloc
/// Simple state management for product operations
class ProductState {
  final List<ProductEntity> products;
  final ProductEntity? selectedProduct;
  final bool isLoading;
  final bool isLoadingMore;
  final FailureCommons? error;
  final String? searchQuery;
  final bool hasReachedMax;

  const ProductState({
    this.products = const [],
    this.selectedProduct,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.searchQuery,
    this.hasReachedMax = false,
  });

  /// Initial state
  factory ProductState.initial() => const ProductState();

  /// Loading state
  ProductState loading() => copyWith(isLoading: true, error: null);

  /// Loading more state
  ProductState loadingMore() => copyWith(isLoadingMore: true, error: null);

  /// Success state with products
  ProductState success(List<ProductEntity> products) => copyWith(
        products: products,
        isLoading: false,
        isLoadingMore: false,
        error: null,
      );

  /// Error state
  ProductState failure(FailureCommons error) => copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: error,
      );

  /// Search state
  ProductState search(String query) => copyWith(
        searchQuery: query,
        isLoading: true,
        error: null,
      );

  /// Select product state
  ProductState selectProduct(ProductEntity product) => copyWith(
        selectedProduct: product,
      );

  /// Copy with method
  ProductState copyWith({
    List<ProductEntity>? products,
    ProductEntity? selectedProduct,
    bool? isLoading,
    bool? isLoadingMore,
    FailureCommons? error,
    String? searchQuery,
    bool? hasReachedMax,
  }) {
    return ProductState(
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductState &&
        other.products == products &&
        other.selectedProduct == selectedProduct &&
        other.isLoading == isLoading &&
        other.isLoadingMore == isLoadingMore &&
        other.error == error &&
        other.searchQuery == searchQuery &&
        other.hasReachedMax == hasReachedMax;
  }

  @override
  int get hashCode {
    return Object.hash(
      products,
      selectedProduct,
      isLoading,
      isLoadingMore,
      error,
      searchQuery,
      hasReachedMax,
    );
  }

  @override
  String toString() {
    return 'ProductState('
        'products: ${products.length}, '
        'selectedProduct: ${selectedProduct?.name}, '
        'isLoading: $isLoading, '
        'isLoadingMore: $isLoadingMore, '
        'error: $error, '
        'searchQuery: $searchQuery, '
        'hasReachedMax: $hasReachedMax'
        ')';
  }
}