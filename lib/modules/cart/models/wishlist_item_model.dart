import '../../product/models/product_model.dart';

class WishlistItemModel {
  final int productId;
  final String title;
  final double price;
  final double discountPercentage;
  final String thumbnail;
  final String category;
  final String brand;
  final double rating;
  final int stock;
  final DateTime addedAt;

  const WishlistItemModel({
    required this.productId,
    required this.title,
    required this.price,
    this.discountPercentage = 0.0,
    required this.thumbnail,
    this.category = '',
    this.brand = '',
    this.rating = 0.0,
    this.stock = 99,
    required this.addedAt,
  });

  factory WishlistItemModel.fromProduct(ProductModel product) {
    return WishlistItemModel(
      productId: product.id,
      title: product.title,
      price: product.price,
      discountPercentage: product.discountPercentage,
      thumbnail: product.thumbnail.isNotEmpty
          ? product.thumbnail
          : (product.images.isNotEmpty ? product.images.first : ''),
      category: product.category,
      brand: product.brand,
      rating: product.rating,
      stock: product.stock,
      addedAt: DateTime.now(),
    );
  }

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      productId: json['productId'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail'] as String? ?? '',
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? 99,
      addedAt: json['addedAt'] != null
          ? (json['addedAt'] is DateTime
              ? json['addedAt'] as DateTime
              : DateTime.tryParse(json['addedAt'].toString()) ?? DateTime.now())
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
      'rating': rating,
      'stock': stock,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  ProductModel toProductModel() {
    return ProductModel(
      id: productId,
      title: title,
      price: price,
      discountPercentage: discountPercentage,
      thumbnail: thumbnail,
      category: category,
      brand: brand,
      rating: rating,
      stock: stock,
      images: [thumbnail],
    );
  }
}
