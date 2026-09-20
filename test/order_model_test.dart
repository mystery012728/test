import 'package:flutter_test/flutter_test.dart';
import 'package:testprojectnew/modules/cart/models/cart_item_model.dart';
import 'package:testprojectnew/modules/order/models/order_model.dart';

void main() {
  group('OrderModel Tests', () {
    test('Correctly serializes and deserializes OrderModel', () {
      final item = CartItemModel(
        productId: 10,
        title: 'Smartphone X',
        price: 800.0,
        thumbnail: 'https://example.com/phone.jpg',
        quantity: 2,
        addedAt: DateTime(2026, 9, 20),
      );

      final order = OrderModel(
        orderId: 'ORD-TEST1234',
        userId: 'user_abc_123',
        items: [item],
        subtotal: 1600.0,
        shippingFee: 0.0,
        tax: 128.0,
        totalAmount: 1728.0,
        shippingAddress: '123 Test St',
        paymentMethod: 'Credit Card',
        status: 'Processing',
        createdAt: DateTime(2026, 9, 20, 10, 30),
      );

      expect(order.totalItemCount, 2);

      final json = order.toJson();
      final fromJson = OrderModel.fromJson(json);

      expect(fromJson.orderId, 'ORD-TEST1234');
      expect(fromJson.userId, 'user_abc_123');
      expect(fromJson.items.length, 1);
      expect(fromJson.items.first.title, 'Smartphone X');
      expect(fromJson.totalAmount, 1728.0);
      expect(fromJson.status, 'Processing');
    });
  });
}
