class ProductReviewModel {
  final double rating;
  final String comment;
  final String date;
  final String reviewerName;
  final String reviewerEmail;

  const ProductReviewModel({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      date: json['date'] as String? ?? '',
      reviewerName: json['reviewerName'] as String? ?? 'Anonymous',
      reviewerEmail: json['reviewerEmail'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'date': date,
      'reviewerName': reviewerName,
      'reviewerEmail': reviewerEmail,
    };
  }
}

class ProductDimensionsModel {
  final double width;
  final double height;
  final double depth;

  const ProductDimensionsModel({
    this.width = 0.0,
    this.height = 0.0,
    this.depth = 0.0,
  });

  factory ProductDimensionsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProductDimensionsModel();
    return ProductDimensionsModel(
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      depth: (json['depth'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
        'depth': depth,
      };
}

class ProductModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String sku;
  final String availabilityStatus;
  final String warrantyInformation;
  final String shippingInformation;
  final String returnPolicy;
  final int minimumOrderQuantity;
  final String thumbnail;
  final List<String> images;
  final List<String> tags;
  final List<ProductReviewModel> reviews;
  final ProductDimensionsModel dimensions;

  const ProductModel({
    required this.id,
    required this.title,
    this.description = '',
    this.category = '',
    required this.price,
    this.discountPercentage = 0.0,
    this.rating = 0.0,
    this.stock = 0,
    this.brand = '',
    this.sku = '',
    this.availabilityStatus = 'In Stock',
    this.warrantyInformation = '',
    this.shippingInformation = '',
    this.returnPolicy = '',
    this.minimumOrderQuantity = 1,
    required this.thumbnail,
    this.images = const [],
    this.tags = const [],
    this.reviews = const [],
    this.dimensions = const ProductDimensionsModel(),
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled Product',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      brand: json['brand'] as String? ?? (json['category'] as String? ?? ''),
      sku: json['sku'] as String? ?? '',
      availabilityStatus: json['availabilityStatus'] as String? ?? 'In Stock',
      warrantyInformation: json['warrantyInformation'] as String? ?? '',
      shippingInformation: json['shippingInformation'] as String? ?? '',
      returnPolicy: json['returnPolicy'] as String? ?? '',
      minimumOrderQuantity: json['minimumOrderQuantity'] as int? ?? 1,
      thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      reviews: (json['reviews'] as List?)
              ?.map((e) => ProductReviewModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dimensions: ProductDimensionsModel.fromJson(json['dimensions'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'sku': sku,
      'availabilityStatus': availabilityStatus,
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'returnPolicy': returnPolicy,
      'minimumOrderQuantity': minimumOrderQuantity,
      'thumbnail': thumbnail,
      'images': images,
      'tags': tags,
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'dimensions': dimensions.toJson(),
    };
  }
}

// Wrapper for paginated DummyJSON response
class ProductResponseModel {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  const ProductResponseModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => (skip + products.length) < total;

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    final list = (json['products'] as List?) ?? [];
    return ProductResponseModel(
      products: list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList(),
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }
}
