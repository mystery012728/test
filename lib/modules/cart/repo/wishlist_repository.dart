import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/local/local_preference.dart';
import '../../product/models/product_model.dart';
import '../models/wishlist_item_model.dart';

class WishlistRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WishlistRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _currentUid {
    final authUid = _auth.currentUser?.uid;
    if (authUid != null && authUid.isNotEmpty) return authUid;
    final prefUid = LocalPreference.userId;
    if (prefUid != null && prefUid.isNotEmpty) return prefUid;
    return null;
  }

  CollectionReference<Map<String, dynamic>>? get _wishlistRef {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection('users').doc(uid).collection('wishlist');
  }

  /// Fetches paginated wishlist items
  Future<({List<WishlistItemModel> items, DocumentSnapshot? lastDoc, bool hasMore})> fetchWishlist({
    int limit = 20,
    DocumentSnapshot? startAfterDoc,
  }) async {
    final ref = _wishlistRef;
    if (ref == null) {
      return (items: <WishlistItemModel>[], lastDoc: null, hasMore: false);
    }

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      Query<Map<String, dynamic>> query = ref
          .orderBy('addedAt', descending: true)
          .limit(limit);

      if (startAfterDoc != null) {
        query = query.startAfterDocument(startAfterDoc);
      }
      snapshot = await query.get();
    } catch (_) {
      // Fallback query if index or ordering throws
      snapshot = await ref.limit(limit).get();
    }

    final items = snapshot.docs.map((doc) => WishlistItemModel.fromJson(doc.data())).toList();
    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    final hasMore = snapshot.docs.length == limit;

    // Synchronize local cached IDs
    final allIds = items.map((e) => e.productId).toList();
    if (startAfterDoc == null) {
      await LocalPreference.setWishlistProductIds(allIds);
    }

    return (items: items, lastDoc: lastDoc, hasMore: hasMore);
  }

  /// Toggles wishlist state for a product. Returns true if added, false if removed.
  Future<bool> toggleWishlist(ProductModel product) async {
    final ref = _wishlistRef;
    final productId = product.id;

    if (ref == null) {
      // Fallback to local only if unauthenticated
      final ids = LocalPreference.getWishlistProductIds();
      if (ids.contains(productId)) {
        await LocalPreference.removeWishlistProductId(productId);
        return false;
      } else {
        await LocalPreference.addWishlistProductId(productId);
        return true;
      }
    }

    final docRef = ref.doc(productId.toString());
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.delete();
      await LocalPreference.removeWishlistProductId(productId);
      return false;
    } else {
      final wishlistItem = WishlistItemModel.fromProduct(product);
      await docRef.set(wishlistItem.toJson());
      await LocalPreference.addWishlistProductId(productId);
      return true;
    }
  }

  /// Removes an item from the wishlist
  Future<void> removeFromWishlist(int productId) async {
    final ref = _wishlistRef;
    if (ref != null) {
      await ref.doc(productId.toString()).delete();
    }
    await LocalPreference.removeWishlistProductId(productId);
  }

  /// Get wishlisted IDs from cache
  Set<int> getCachedWishlistIds() {
    return LocalPreference.getWishlistProductIds().toSet();
  }
}
