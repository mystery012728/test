import '../../product/models/product_model.dart';

class CartItemModel {
  final int productId;
  final String title;
  final double price;
  final double discountPercentage;
  final String thumbnail;
  final String category;
  final String brand;
  final int quantity;
  final int stock;
  final DateTime addedAt;

  const CartItemModel({
    required this.productId,
    required this.title,
    required this.price,
    this.discountPercentage = 0.0,
    required this.thumbnail,
    this.category = '',
    this.brand = '',
    this.quantity = 1,
    this.stock = 99,
    required this.addedAt,
  });

  double get totalPrice => price * quantity;

  double get originalPrice {
    if (discountPercentage <= 0) return price;
    return price / (1 - (discountPercentage / 100));
  }

  CartItemModel copyWith({
    int? productId,
    String? title,
    double? price,
    double? discountPercentage,
    String? thumbnail,
    String? category,
    String? brand,
    int? quantity,
    int? stock,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      thumbnail: thumbnail ?? this.thumbnail,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  factory CartItemModel.fromProduct(ProductModel product, {int quantity = 1}) {
    return CartItemModel(
      productId: product.id,
      title: product.title,
      price: product.price,
      discountPercentage: product.discountPercentage,
      thumbnail: product.thumbnail.isNotEmpty
          ? product.thumbnail
          : (product.images.isNotEmpty ? product.images.first : ''),
      category: product.category,
      brand: product.brand,
      quantity: quantity,
      stock: product.stock,
      addedAt: DateTime.now(),
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail'] as String? ?? '',
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      stock: json['stock'] as int? ?? 99,
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'discountPercentage': discountPercentage,
      'thumbnail': thumbnail,
      'category': category,
      'brand': brand,
      'quantity': quantity,
      'stock': stock,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}
