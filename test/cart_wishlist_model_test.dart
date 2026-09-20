import 'package:flutter_test/flutter_test.dart';
import 'package:testprojectnew/modules/cart/models/cart_item_model.dart';
import 'package:testprojectnew/modules/cart/models/wishlist_item_model.dart';
import 'package:testprojectnew/modules/product/models/product_model.dart';

void main() {
  group('Cart & Wishlist Models Tests', () {
    final sampleProduct = ProductModel(
      id: 42,
      title: 'Test Sneaker',
      price: 120.0,
      discountPercentage: 20.0,
      thumbnail: 'https://cdn.example.com/shoe.png',
      category: 'shoes',
      brand: 'Nike',
      rating: 4.8,
      stock: 15,
    );

    test('WishlistItemModel fromProduct and toProductModel works', () {
      final wishlistItem = WishlistItemModel.fromProduct(sampleProduct);
      expect(wishlistItem.productId, 42);
      expect(wishlistItem.title, 'Test Sneaker');
      expect(wishlistItem.price, 120.0);
      expect(wishlistItem.brand, 'Nike');

      final backToProduct = wishlistItem.toProductModel();
      expect(backToProduct.id, 42);
      expect(backToProduct.title, 'Test Sneaker');
    });

    test('CartItemModel calculations and JSON serialization works', () {
      final cartItem = CartItemModel.fromProduct(sampleProduct, quantity: 3);
      expect(cartItem.productId, 42);
      expect(cartItem.quantity, 3);
      expect(cartItem.totalPrice, 360.0);

      final json = cartItem.toJson();
      final fromJson = CartItemModel.fromJson(json);

      expect(fromJson.productId, 42);
      expect(fromJson.quantity, 3);
      expect(fromJson.price, 120.0);
    });
  });
}
