part of 'cart_bloc.dart';

abstract class CartEvent {
  const CartEvent();
}

class LoadCartEvent extends CartEvent {
  final bool isRefresh;

  const LoadCartEvent({this.isRefresh = false});
}

class AddToCartEvent extends CartEvent {
  final ProductModel product;
  final int quantity;

  const AddToCartEvent(this.product, {this.quantity = 1});
}

class UpdateCartQuantityEvent extends CartEvent {
  final int productId;
  final int newQuantity;

  const UpdateCartQuantityEvent({
    required this.productId,
    required this.newQuantity,
  });
}

class RemoveCartItemEvent extends CartEvent {
  final int productId;

  const RemoveCartItemEvent(this.productId);
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}
