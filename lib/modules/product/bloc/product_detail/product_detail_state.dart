part of 'product_detail_bloc.dart';

abstract class ProductDetailState {
  const ProductDetailState();
}

class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

class ProductDetailLoaded extends ProductDetailState {
  final ProductModel product;

  const ProductDetailLoaded(this.product);
}

class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError(this.message);
}
