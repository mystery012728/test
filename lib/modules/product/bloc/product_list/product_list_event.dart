part of 'product_list_bloc.dart';

abstract class ProductListEvent {
  const ProductListEvent();
}

class FetchProductListEvent extends ProductListEvent {
  final String? category;
  final String? sortBy;
  final String? order;
  final bool isRefresh;

  const FetchProductListEvent({
    this.category,
    this.sortBy,
    this.order,
    this.isRefresh = false,
  });
}

class ChangeSortEvent extends ProductListEvent {
  final String sortOption;

  const ChangeSortEvent({required this.sortOption});
}

class LoadMoreProductsEvent extends ProductListEvent {
  const LoadMoreProductsEvent();
}
