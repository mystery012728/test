import '../../../core/constants/app_urls.dart';
import '../../../core/network/dio_client.dart';
import '../../product/models/product_model.dart';

class HomeRepository {
  final DioClient _dioClient;

  HomeRepository({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  Future<List<ProductModel>> fetchPersonalizedProducts(List<String> favoriteCategories) async {
    final List<ProductModel> products = [];

    try {
      if (favoriteCategories.isNotEmpty) {
        // Fetch up to 4 products for each selected favorite category
        for (final category in favoriteCategories.take(3)) {
          final response = await _dioClient.dio.get(
            '${AppUrls.productsByCategory(category)}?limit=4',
          );
          if (response.statusCode == 200 && response.data != null) {
            final list = (response.data['products'] as List?) ?? [];
            for (final json in list) {
              products.add(ProductModel.fromJson(json as Map<String, dynamic>));
            }
          }
        }
      }

      // Fallback if empty
      if (products.isEmpty) {
        final response = await _dioClient.dio.get(
          AppUrls.paginatedProducts(limit: 8, skip: 0),
        );
        if (response.statusCode == 200 && response.data != null) {
          final list = (response.data['products'] as List?) ?? [];
          for (final json in list) {
            products.add(ProductModel.fromJson(json as Map<String, dynamic>));
          }
        }
      }

      return products;
    } catch (e) {
      return products;
    }
  }

  Future<List<ProductModel>> fetchPopularProducts({int limit = 10, int skip = 0}) async {
    try {
      // Sort by rating descending so the highest-rated popular products are shown
      final response = await _dioClient.dio.get(
        AppUrls.sortedProducts(
          sortBy: 'rating',
          order: 'desc',
          limit: limit,
          skip: skip,
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = (response.data['products'] as List?) ?? [];
        return list.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load popular products: ${e.toString()}');
    }
  }
}
