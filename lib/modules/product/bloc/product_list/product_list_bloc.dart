import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/product_model.dart';
import '../../repo/product_repository.dart';

part 'product_list_event.dart';
part 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final ProductRepository productRepository;
  String? _currentCategory;
  String _currentSort = 'Recommended';

  ProductListBloc({required this.productRepository})
      : super(const ProductListInitial()) {
    on<FetchProductListEvent>(_onFetchProductList);
    on<ChangeSortEvent>(_onChangeSort);
    on<LoadMoreProductsEvent>(_onLoadMoreProducts);
  }

  Future<void> _onFetchProductList(
    FetchProductListEvent event,
    Emitter<ProductListState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const ProductListLoading());
    }

    if (event.category != null) {
      _currentCategory = event.category;
    }

    String? sortBy = event.sortBy;
    String? order = event.order;

    if (sortBy == null && _currentSort != 'Recommended') {
      final sortParams = _mapSortOptionToParams(_currentSort);
      sortBy = sortParams['sortBy'];
      order = sortParams['order'];
    }

    try {
      final response = await productRepository.getProducts(
        category: _currentCategory,
        sortBy: sortBy,
        order: order,
        limit: 10,
        skip: 0,
      );

      if (response.products.isEmpty) {
        emit(ProductListEmpty(activeCategory: _currentCategory));
      } else {
        emit(ProductListLoaded(
          products: response.products,
          total: response.total,
          activeCategory: _currentCategory,
          activeSort: _currentSort,
          hasReachedMax: response.products.length >= response.total,
          isLoadingMore: false,
        ));
      }
    } catch (e) {
      emit(ProductListError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onChangeSort(
    ChangeSortEvent event,
    Emitter<ProductListState> emit,
  ) async {
    _currentSort = event.sortOption;
    final sortParams = _mapSortOptionToParams(_currentSort);

    emit(const ProductListLoading());
    try {
      final response = await productRepository.getProducts(
        category: _currentCategory,
        sortBy: sortParams['sortBy'],
        order: sortParams['order'],
        limit: 10,
        skip: 0,
      );

      if (response.products.isEmpty) {
        emit(ProductListEmpty(activeCategory: _currentCategory));
      } else {
        emit(ProductListLoaded(
          products: response.products,
          total: response.total,
          activeCategory: _currentCategory,
          activeSort: _currentSort,
          hasReachedMax: response.products.length >= response.total,
          isLoadingMore: false,
        ));
      }
    } catch (e) {
      emit(ProductListError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProductsEvent event,
    Emitter<ProductListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductListLoaded ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final sortParams = _mapSortOptionToParams(_currentSort);

    try {
      final response = await productRepository.getProducts(
        category: _currentCategory,
        sortBy: sortParams['sortBy'],
        order: sortParams['order'],
        limit: 10,
        skip: currentState.products.length,
      );

      final updatedProducts = List<ProductModel>.from(currentState.products)
        ..addAll(response.products);

      emit(currentState.copyWith(
        products: updatedProducts,
        total: response.total,
        hasReachedMax: updatedProducts.length >= response.total || response.products.isEmpty,
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Map<String, String?> _mapSortOptionToParams(String sort) {
    switch (sort) {
      case 'Price: Low to High':
        return {'sortBy': 'price', 'order': 'asc'};
      case 'Price: High to Low':
        return {'sortBy': 'price', 'order': 'desc'};
      case 'Highest Rated':
      case 'Top Rated':
        return {'sortBy': 'rating', 'order': 'desc'};
      case 'Recommended':
      default:
        return {'sortBy': null, 'order': null};
    }
  }
}
