part of 'wishlist_bloc.dart';

abstract class WishlistEvent {
  const WishlistEvent();
}

class LoadWishlistEvent extends WishlistEvent {
  final bool isRefresh;

  const LoadWishlistEvent({this.isRefresh = false});
}

class ToggleWishlistEvent extends WishlistEvent {
  final ProductModel product;

  const ToggleWishlistEvent(this.product);
}

class RemoveWishlistItemEvent extends WishlistEvent {
  final int productId;

  const RemoveWishlistItemEvent(this.productId);
}

class LoadMoreWishlistEvent extends WishlistEvent {
  const LoadMoreWishlistEvent();
}
