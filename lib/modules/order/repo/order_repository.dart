import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/local/local_preference.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OrderRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _currentUid => _auth.currentUser?.uid ?? LocalPreference.userId;

  CollectionReference<Map<String, dynamic>>? get _ordersRef {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return null;
    return _firestore.collection('users').doc(uid).collection('orders');
  }

  /// Places and saves order to Firestore
  Future<OrderModel> placeOrder(OrderModel order) async {
    final ref = _ordersRef;
    if (ref != null) {
      await ref.doc(order.orderId).set(order.toJson());
    }
    return order;
  }

  /// Fetches order history for current user from Firestore
  Future<List<OrderModel>> fetchOrders() async {
    final ref = _ordersRef;
    if (ref == null) return [];

    final snapshot = await ref.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data()))
        .toList();
  }
}
