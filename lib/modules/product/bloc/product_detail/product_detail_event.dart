part of 'product_detail_bloc.dart';

abstract class ProductDetailEvent {
  const ProductDetailEvent();
}

class FetchProductDetailEvent extends ProductDetailEvent {
  final int productId;

  const FetchProductDetailEvent(this.productId);
}
