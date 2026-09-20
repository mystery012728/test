part of 'cart_bloc.dart';

abstract class CartState {
  final Map<int, int> productQuantities;

  const CartState({this.productQuantities = const {}});

  Set<int> get cartProductIds => productQuantities.keys.toSet();

  int getQuantity(int productId) => productQuantities[productId] ?? 0;

  bool isInCart(int productId) => productQuantities.containsKey(productId) && productQuantities[productId]! > 0;

  int get totalItemCount => productQuantities.values.fold(0, (sum, q) => sum + q);
}

class CartInitial extends CartState {
  const CartInitial({super.productQuantities});
}

class CartLoading extends CartState {
  const CartLoading({super.productQuantities});
}

class CartLoaded extends CartState {
  final List<CartItemModel> items;

  const CartLoaded({
    required this.items,
    required super.productQuantities,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get shippingFee => subtotal > 150 ? 0.0 : (subtotal > 0 ? 10.0 : 0.0);

  double get tax => subtotal * 0.08;

  double get grandTotal => subtotal + shippingFee + tax;

  @override
  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartLoaded copyWith({
    List<CartItemModel>? items,
    Map<int, int>? productQuantities,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      productQuantities: productQuantities ?? this.productQuantities,
    );
  }
}

class CartEmpty extends CartState {
  const CartEmpty({super.productQuantities});
}

class CartError extends CartState {
  final String message;

  const CartError(this.message, {super.productQuantities});
}
