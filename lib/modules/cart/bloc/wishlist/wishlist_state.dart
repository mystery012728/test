part of 'wishlist_bloc.dart';

abstract class WishlistState {
  final Set<int> wishlistIds;

  const WishlistState({this.wishlistIds = const {}});
}

class WishlistInitial extends WishlistState {
  const WishlistInitial({super.wishlistIds});
}

class WishlistLoading extends WishlistState {
  const WishlistLoading({super.wishlistIds});
}

class WishlistLoaded extends WishlistState {
  final List<WishlistItemModel> items;
  final bool hasMore;
  final bool isLoadingMore;

  const WishlistLoaded({
    required this.items,
    super.wishlistIds,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  WishlistLoaded copyWith({
    List<WishlistItemModel>? items,
    Set<int>? wishlistIds,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return WishlistLoaded(
      items: items ?? this.items,
      wishlistIds: wishlistIds ?? this.wishlistIds,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class WishlistEmpty extends WishlistState {
  const WishlistEmpty({super.wishlistIds});
}

class WishlistError extends WishlistState {
  final String message;

  const WishlistError(this.message, {super.wishlistIds});
}
