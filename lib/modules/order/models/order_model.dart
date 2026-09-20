import '../../cart/models/cart_item_model.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double totalAmount;
  final String shippingAddress;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  const OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.totalAmount,
    this.shippingAddress = '4517 Washington Ave. Manchester, Kentucky 39495',
    this.paymentMethod = 'Credit Card',
    this.status = 'Processing',
    required this.createdAt,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?) ?? [];
    return OrderModel(
      orderId: json['orderId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      items: itemsList
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: json['shippingAddress'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? 'Credit Card',
      status: json['status'] as String? ?? 'Processing',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'tax': tax,
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
