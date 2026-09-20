class AppUrls {
  // Base URL for DummyJSON API
  static const String baseUrl = 'https://dummyjson.com';

  // Products Endpoints
  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String categories = '/products/categories';
  static const String categoryList = '/products/category-list';

  // Dynamic Endpoints
  static String productById(int id) => '/products/$id';
  static String productsByCategory(String category) => '/products/category/$category';

  // Helper query builders
  static String paginatedProducts({int limit = 10, int skip = 0}) =>
      '/products?limit=$limit&skip=$skip';

  static String sortedProducts({
    required String sortBy,
    required String order,
    int limit = 10,
    int skip = 0,
  }) =>
      '/products?sortBy=$sortBy&order=$order&limit=$limit&skip=$skip';

  static String searchWithQuery(String query) =>
      '/products/search?q=${Uri.encodeComponent(query)}';
}
