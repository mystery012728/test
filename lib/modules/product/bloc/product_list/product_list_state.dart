part of 'product_list_bloc.dart';

abstract class ProductListState {
  const ProductListState();
}

class ProductListInitial extends ProductListState {
  const ProductListInitial();
}

class ProductListLoading extends ProductListState {
  const ProductListLoading();
}

class ProductListLoaded extends ProductListState {
  final List<ProductModel> products;
  final int total;
  final String? activeCategory;
  final String activeSort;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const ProductListLoaded({
    required this.products,
    required this.total,
    this.activeCategory,
    this.activeSort = 'Recommended',
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  ProductListLoaded copyWith({
    List<ProductModel>? products,
    int? total,
    String? activeCategory,
    String? activeSort,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return ProductListLoaded(
      products: products ?? this.products,
      total: total ?? this.total,
      activeCategory: activeCategory ?? this.activeCategory,
      activeSort: activeSort ?? this.activeSort,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ProductListEmpty extends ProductListState {
  final String? activeCategory;

  const ProductListEmpty({this.activeCategory});
}

class ProductListError extends ProductListState {
  final String message;

  const ProductListError(this.message);
}
