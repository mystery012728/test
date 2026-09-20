import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/local/local_preference.dart';
import '../../../product/models/product_model.dart';
import '../../models/wishlist_item_model.dart';
import '../../repo/wishlist_repository.dart';

part 'wishlist_event.dart';
part 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository wishlistRepository;
  DocumentSnapshot? _lastDoc;
  bool _hasMore = false;

  WishlistBloc({required this.wishlistRepository})
      : super(WishlistInitial(
          wishlistIds: LocalPreference.getWishlistProductIds().toSet(),
        )) {
    on<LoadWishlistEvent>(_onLoadWishlist);
    on<ToggleWishlistEvent>(_onToggleWishlist);
    on<RemoveWishlistItemEvent>(_onRemoveWishlistItem);
    on<LoadMoreWishlistEvent>(_onLoadMoreWishlist);
  }

  Future<void> _onLoadWishlist(
    LoadWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    final cachedIds = LocalPreference.getWishlistProductIds().toSet();
    if (!event.isRefresh) {
      emit(WishlistLoading(wishlistIds: cachedIds));
    }

    try {
      final result = await wishlistRepository.fetchWishlist(limit: 20);
      _lastDoc = result.lastDoc;
      _hasMore = result.hasMore;

      final updatedIds = result.items.map((e) => e.productId).toSet();

      if (result.items.isEmpty) {
        emit(WishlistEmpty(wishlistIds: updatedIds));
      } else {
        emit(WishlistLoaded(
          items: result.items,
          wishlistIds: updatedIds,
          hasMore: _hasMore,
        ));
      }
    } catch (e) {
      emit(WishlistError(
        e.toString().replaceAll('Exception: ', ''),
        wishlistIds: cachedIds,
      ));
    }
  }

  Future<void> _onToggleWishlist(
    ToggleWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    final currentIds = Set<int>.from(state.wishlistIds);
    final isAlreadyWishlisted = currentIds.contains(event.product.id);

    // Optimistic ID toggle
    if (isAlreadyWishlisted) {
      currentIds.remove(event.product.id);
    } else {
      currentIds.add(event.product.id);
    }

    // If currently loaded, optimistically update the items list
    if (state is WishlistLoaded) {
      final currentLoaded = state as WishlistLoaded;
      final currentList = List<WishlistItemModel>.from(currentLoaded.items);

      if (isAlreadyWishlisted) {
        currentList.removeWhere((item) => item.productId == event.product.id);
      } else {
        currentList.insert(0, WishlistItemModel.fromProduct(event.product));
      }

      if (currentList.isEmpty) {
        emit(WishlistEmpty(wishlistIds: currentIds));
      } else {
        emit(currentLoaded.copyWith(
          items: currentList,
          wishlistIds: currentIds,
        ));
      }
    } else {
      if (currentIds.isEmpty) {
        emit(WishlistEmpty(wishlistIds: currentIds));
      } else {
        emit(WishlistLoaded(
          items: [WishlistItemModel.fromProduct(event.product)],
          wishlistIds: currentIds,
          hasMore: false,
        ));
      }
    }

    try {
      await wishlistRepository.toggleWishlist(event.product);
    } catch (e) {
      // Revert if error occurs
      final revertedIds = Set<int>.from(LocalPreference.getWishlistProductIds());
      emit(WishlistError('Failed to update wishlist: $e', wishlistIds: revertedIds));
    }
  }

  Future<void> _onRemoveWishlistItem(
    RemoveWishlistItemEvent event,
    Emitter<WishlistState> emit,
  ) async {
    final currentIds = Set<int>.from(state.wishlistIds)..remove(event.productId);

    if (state is WishlistLoaded) {
      final currentLoaded = state as WishlistLoaded;
      final currentList = List<WishlistItemModel>.from(currentLoaded.items)
        ..removeWhere((item) => item.productId == event.productId);

      if (currentList.isEmpty) {
        emit(WishlistEmpty(wishlistIds: currentIds));
      } else {
        emit(currentLoaded.copyWith(
          items: currentList,
          wishlistIds: currentIds,
        ));
      }
    }

    try {
      await wishlistRepository.removeFromWishlist(event.productId);
    } catch (e) {
      emit(WishlistError('Failed to remove item: $e', wishlistIds: currentIds));
    }
  }

  Future<void> _onLoadMoreWishlist(
    LoadMoreWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    if (state is! WishlistLoaded || !_hasMore || _lastDoc == null) return;
    final currentState = state as WishlistLoaded;
    if (currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final result = await wishlistRepository.fetchWishlist(
        limit: 20,
        startAfterDoc: _lastDoc,
      );
      _lastDoc = result.lastDoc;
      _hasMore = result.hasMore;

      final combinedItems = List<WishlistItemModel>.from(currentState.items)
        ..addAll(result.items);
      final combinedIds = combinedItems.map((e) => e.productId).toSet();

      emit(currentState.copyWith(
        items: combinedItems,
        wishlistIds: combinedIds,
        hasMore: _hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}
