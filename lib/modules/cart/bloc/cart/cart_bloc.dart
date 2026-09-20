import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/local/local_preference.dart';
import '../../../product/models/product_model.dart';
import '../../models/cart_item_model.dart';
import '../../repo/cart_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc({required this.cartRepository})
      : super(CartInitial(
          productQuantities: {
            for (final id in LocalPreference.getCartProductIds()) id: 1
          },
        )) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartQuantityEvent>(_onUpdateCartQuantity);
    on<RemoveCartItemEvent>(_onRemoveCartItem);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onLoadCart(
    LoadCartEvent event,
    Emitter<CartState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(CartLoading(productQuantities: state.productQuantities));
    }

    try {
      final result = await cartRepository.fetchCart(limit: 50);
      final quantities = {
        for (final item in result.items) item.productId: item.quantity
      };

      if (result.items.isEmpty) {
        emit(const CartEmpty());
      } else {
        emit(CartLoaded(items: result.items, productQuantities: quantities));
      }
    } catch (e) {
      emit(CartError(
        e.toString().replaceAll('Exception: ', ''),
        productQuantities: state.productQuantities,
      ));
    }
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentQuantities = Map<int, int>.from(state.productQuantities);
    final existingQty = currentQuantities[event.product.id] ?? 0;
    currentQuantities[event.product.id] = existingQty + event.quantity;

    if (state is CartLoaded) {
      final currentLoaded = state as CartLoaded;
      final currentList = List<CartItemModel>.from(currentLoaded.items);
      final index = currentList.indexWhere((i) => i.productId == event.product.id);

      if (index >= 0) {
        final existingItem = currentList[index];
        currentList[index] = existingItem.copyWith(
          quantity: existingItem.quantity + event.quantity,
        );
      } else {
        currentList.insert(
          0,
          CartItemModel.fromProduct(event.product, quantity: event.quantity),
        );
      }

      emit(currentLoaded.copyWith(
        items: currentList,
        productQuantities: currentQuantities,
      ));
    } else {
      final newItem = CartItemModel.fromProduct(event.product, quantity: event.quantity);
      emit(CartLoaded(items: [newItem], productQuantities: currentQuantities));
    }

    try {
      await cartRepository.addToCart(event.product, quantity: event.quantity);
    } catch (e) {
      emit(CartError('Failed to add to cart: $e', productQuantities: currentQuantities));
    }
  }

  Future<void> _onUpdateCartQuantity(
    UpdateCartQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    if (state is! CartLoaded) return;
    final currentLoaded = state as CartLoaded;
    final currentQuantities = Map<int, int>.from(currentLoaded.productQuantities);
    final currentList = List<CartItemModel>.from(currentLoaded.items);
    final index = currentList.indexWhere((i) => i.productId == event.productId);

    if (index < 0) return;

    if (event.newQuantity <= 0) {
      currentList.removeAt(index);
      currentQuantities.remove(event.productId);
    } else {
      currentList[index] = currentList[index].copyWith(quantity: event.newQuantity);
      currentQuantities[event.productId] = event.newQuantity;
    }

    if (currentList.isEmpty) {
      emit(const CartEmpty());
    } else {
      emit(currentLoaded.copyWith(
        items: currentList,
        productQuantities: currentQuantities,
      ));
    }

    try {
      await cartRepository.updateQuantity(event.productId, event.newQuantity);
    } catch (e) {
      emit(CartError('Failed to update quantity: $e', productQuantities: currentQuantities));
    }
  }

  Future<void> _onRemoveCartItem(
    RemoveCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentQuantities = Map<int, int>.from(state.productQuantities)
      ..remove(event.productId);

    if (state is CartLoaded) {
      final currentLoaded = state as CartLoaded;
      final currentList = List<CartItemModel>.from(currentLoaded.items)
        ..removeWhere((i) => i.productId == event.productId);

      if (currentList.isEmpty) {
        emit(const CartEmpty());
      } else {
        emit(currentLoaded.copyWith(
          items: currentList,
          productQuantities: currentQuantities,
        ));
      }
    }

    try {
      await cartRepository.removeFromCart(event.productId);
    } catch (e) {
      emit(CartError('Failed to remove item: $e', productQuantities: currentQuantities));
    }
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartEmpty());
    try {
      await cartRepository.clearCart();
    } catch (e) {
      // Ignored on best-effort basis
    }
  }
}
