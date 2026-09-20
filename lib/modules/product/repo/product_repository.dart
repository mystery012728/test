import '../../../core/constants/app_urls.dart';
import '../../../core/network/dio_client.dart';
import '../models/product_model.dart';

class ProductRepository {
  final DioClient _dioClient;

  ProductRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  /// Fetches products with optional category, sorting, and pagination
  Future<ProductResponseModel> getProducts({
    String? category,
    String? sortBy,
    String? order,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      String endpoint;
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'skip': skip,
      };

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
        queryParams['order'] = order ?? 'asc';
      }

      if (category != null && category.isNotEmpty) {
        endpoint = AppUrls.productsByCategory(category);
      } else {
        endpoint = AppUrls.products;
      }

      final response = await _dioClient.dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return ProductResponseModel.fromJson(
            response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Product fetch error: $e');
    }
  }

  /// Fetches complete details of a single product by ID
  Future<ProductModel> getProductDetail(int id) async {
    try {
      final response = await _dioClient.dio.get(AppUrls.productById(id));

      if (response.statusCode == 200 && response.data != null) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load product details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Product details fetch error: $e');
    }
  }

  /// Searches products with text query, with smart synonym fallback
  Future<ProductResponseModel> searchProducts(String query) async {
    try {
      final trimmed = query.trim();
      final response = await _dioClient.dio.get(
        AppUrls.searchProducts,
        queryParameters: {'q': trimmed},
      );

      if (response.statusCode == 200 && response.data != null) {
        final result = ProductResponseModel.fromJson(
            response.data as Map<String, dynamic>);

        // If DummyJSON returns 0 results due to its strict substring matching,
        // resolve common synonyms (e.g. 'mobiles' -> 'phone', 'shoes' -> 'shoe')
        if (result.products.isEmpty) {
          final fallbackQuery = _resolveSearchFallback(trimmed.toLowerCase());
          if (fallbackQuery != null && fallbackQuery != trimmed.toLowerCase()) {
            final fallbackResponse = await _dioClient.dio.get(
              AppUrls.searchProducts,
              queryParameters: {'q': fallbackQuery},
            );
            if (fallbackResponse.statusCode == 200 && fallbackResponse.data != null) {
              return ProductResponseModel.fromJson(
                fallbackResponse.data as Map<String, dynamic>,
              );
            }
          }
        }

        return result;
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  String? _resolveSearchFallback(String query) {
    const synonyms = {
      'mobile': 'phone',
      'mobiles': 'phone',
      'cellphone': 'phone',
      'cellphones': 'phone',
      'smartphones': 'phone',
      'smartphone': 'phone',
      'watches': 'watch',
      'sneakers': 'shoe',
      'sneaker': 'shoe',
      'shoes': 'shoe',
      'fragrance': 'perfume',
      'fragrances': 'perfume',
      'clothes': 'dress',
      'clothing': 'dress',
    };

    if (synonyms.containsKey(query)) {
      return synonyms[query];
    }

    // Try removing plural trailing 's'
    if (query.length > 3 && query.endsWith('s')) {
      return query.substring(0, query.length - 1);
    }

    return null;
  }
}
