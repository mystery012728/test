import 'package:flutter_test/flutter_test.dart';
import 'package:testprojectnew/modules/product/models/product_model.dart';

void main() {
  group('ProductModel Parsing Tests', () {
    test('Correctly parses full DummyJSON product response', () {
      final sampleJson = {
        "id": 1,
        "title": "Essence Mascara Lash Princess",
        "description": "The Essence Mascara Lash Princess is a popular mascara.",
        "category": "beauty",
        "price": 9.99,
        "discountPercentage": 10.48,
        "rating": 2.56,
        "stock": 99,
        "tags": ["beauty", "mascara"],
        "brand": "Essence",
        "sku": "BEA-ESS-ESS-001",
        "weight": 4,
        "dimensions": {
          "width": 15.14,
          "height": 13.08,
          "depth": 22.99,
        },
        "warrantyInformation": "1 week warranty",
        "shippingInformation": "Ships in 3-5 business days",
        "availabilityStatus": "In Stock",
        "reviews": [
          {
            "rating": 3,
            "comment": "Would not recommend!",
            "date": "2025-04-30T09:41:02.053Z",
            "reviewerName": "Eleanor Collins",
            "reviewerEmail": "eleanor.collins@x.dummyjson.com",
          }
        ],
        "returnPolicy": "No return policy",
        "minimumOrderQuantity": 48,
        "images": ["https://cdn.dummyjson.com/test.webp"],
        "thumbnail": "https://cdn.dummyjson.com/thumb.webp",
      };

      final product = ProductModel.fromJson(sampleJson);

      expect(product.id, 1);
      expect(product.title, "Essence Mascara Lash Princess");
      expect(product.price, 9.99);
      expect(product.brand, "Essence");
      expect(product.sku, "BEA-ESS-ESS-001");
      expect(product.dimensions.width, 15.14);
      expect(product.warrantyInformation, "1 week warranty");
      expect(product.shippingInformation, "Ships in 3-5 business days");
      expect(product.reviews.length, 1);
      expect(product.reviews.first.reviewerName, "Eleanor Collins");
    });
  });
}
