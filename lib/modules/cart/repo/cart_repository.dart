import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/local/local_preference.dart';
import '../../product/models/product_model.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CartRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _currentUid => _auth.currentUser?.uid ?? LocalPreference.userId;

  CollectionReference<Map<String, dynamic>>? get _cartRef {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection('users').doc(uid).collection('cart');
  }

  /// Fetches paginated cart items
  Future<({List<CartItemModel> items, DocumentSnapshot? lastDoc, bool hasMore})> fetchCart({
    int limit = 20,
    DocumentSnapshot? startAfterDoc,
  }) async {
    final ref = _cartRef;
    if (ref == null) {
      return (items: <CartItemModel>[], lastDoc: null, hasMore: false);
    }

    Query<Map<String, dynamic>> query = ref
        .orderBy('addedAt', descending: true)
        .limit(limit);

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    final snapshot = await query.get();
    final items = snapshot.docs.map((doc) => CartItemModel.fromJson(doc.data())).toList();
    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    final hasMore = snapshot.docs.length == limit;

    // Synchronize local cached IDs
    final allIds = items.map((e) => e.productId).toList();
    if (startAfterDoc == null) {
      await LocalPreference.setCartProductIds(allIds);
    }

    return (items: items, lastDoc: lastDoc, hasMore: hasMore);
  }

  /// Adds an item to the cart or increments its quantity if already present
  Future<CartItemModel> addToCart(ProductModel product, {int quantity = 1}) async {
    final ref = _cartRef;
    final productId = product.id;

    if (ref == null) {
      await LocalPreference.addCartProductId(productId);
      return CartItemModel.fromProduct(product, quantity: quantity);
    }

    final docRef = ref.doc(productId.toString());
    final docSnapshot = await docRef.get();

    CartItemModel cartItem;
    if (docSnapshot.exists && docSnapshot.data() != null) {
      final existing = CartItemModel.fromJson(docSnapshot.data()!);
      cartItem = existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      cartItem = CartItemModel.fromProduct(product, quantity: quantity);
    }

    await docRef.set(cartItem.toJson());
    await LocalPreference.addCartProductId(productId);
    return cartItem;
  }

  /// Updates quantity of an existing cart item
  Future<void> updateQuantity(int productId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    final ref = _cartRef;
    if (ref != null) {
      await ref.doc(productId.toString()).update({'quantity': newQuantity});
    }
  }

  /// Removes an item from the cart
  Future<void> removeFromCart(int productId) async {
    final ref = _cartRef;
    if (ref != null) {
      await ref.doc(productId.toString()).delete();
    }
    await LocalPreference.removeCartProductId(productId);
  }

  /// Clears the entire cart (e.g. on checkout success)
  Future<void> clearCart() async {
    final ref = _cartRef;
    if (ref != null) {
      final snapshot = await ref.get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
    await LocalPreference.setCartProductIds([]);
  }

  /// Get cart product IDs from cache
  Set<int> getCachedCartIds() {
    return LocalPreference.getCartProductIds().toSet();
  }
}
