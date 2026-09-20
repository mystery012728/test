import 'package:shared_preferences/shared_preferences.dart';

class LocalPreference {
  static const String _keyIsUserLogin = 'isUserLogin';
  static const String _keyUserId = 'userId';
  static const String _keyUserEmail = 'userEmail';

  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // Check if user is logged in
  static bool get isUserLogin {
    return _preferences?.getBool(_keyIsUserLogin) ?? false;
  }

  // Save login state
  static Future<bool> setUserLogin(bool isLogin) async {
    await init();
    return await _preferences?.setBool(_keyIsUserLogin, isLogin) ?? false;
  }

  // User ID
  static String? get userId {
    return _preferences?.getString(_keyUserId);
  }

  static Future<bool> setUserId(String uid) async {
    await init();
    return await _preferences?.setString(_keyUserId, uid) ?? false;
  }

  // User Email
  static String? get userEmail {
    return _preferences?.getString(_keyUserEmail);
  }

  static Future<bool> setUserEmail(String email) async {
    await init();
    return await _preferences?.setString(_keyUserEmail, email) ?? false;
  }

  static const String _keyFavoriteCategories = 'favoriteCategories';

  // Favorite Categories
  static List<String> get favoriteCategories {
    return _preferences?.getStringList(_keyFavoriteCategories) ?? [];
  }

  static Future<bool> setFavoriteCategories(List<String> categories) async {
    await init();
    return await _preferences?.setStringList(_keyFavoriteCategories, categories) ?? false;
  }

  static const String _keyRecentSearches = 'recentSearches';

  // Get Recent Searches List
  static List<String> getRecentSearchList() {
    return _preferences?.getStringList(_keyRecentSearches) ?? [];
  }

  // Set Recent Search (saves query, avoids duplicates, places at top)
  static Future<bool> setRecentSearch(String query) async {
    await init();
    final trimmed = query.trim();
    if (trimmed.isEmpty) return false;

    final list = getRecentSearchList().toList();
    list.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    list.insert(0, trimmed);

    if (list.length > 10) {
      list.removeRange(10, list.length);
    }

    return await _preferences?.setStringList(_keyRecentSearches, list) ?? false;
  }

  // Alias support
  static Future<bool> setResentSearch(String query) => setRecentSearch(query);

  // Clear Recent Searches
  static Future<bool> clearRecentSearches() async {
    await init();
    return await _preferences?.remove(_keyRecentSearches) ?? false;
  }

  static const String _keyWishlistProductIds = 'wishlistProductIds';
  static const String _keyCartProductIds = 'cartProductIds';

  // --- Wishlist Product IDs ---
  static List<int> getWishlistProductIds() {
    final list = _preferences?.getStringList(_keyWishlistProductIds) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).where((id) => id > 0).toList();
  }

  static Future<bool> setWishlistProductIds(List<int> ids) async {
    await init();
    final stringList = ids.map((id) => id.toString()).toList();
    return await _preferences?.setStringList(_keyWishlistProductIds, stringList) ?? false;
  }

  static Future<bool> addWishlistProductId(int id) async {
    final ids = getWishlistProductIds();
    if (!ids.contains(id)) {
      ids.add(id);
      return await setWishlistProductIds(ids);
    }
    return true;
  }

  static Future<bool> removeWishlistProductId(int id) async {
    final ids = getWishlistProductIds();
    if (ids.contains(id)) {
      ids.remove(id);
      return await setWishlistProductIds(ids);
    }
    return true;
  }

  // --- Cart Product IDs ---
  static List<int> getCartProductIds() {
    final list = _preferences?.getStringList(_keyCartProductIds) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).where((id) => id > 0).toList();
  }

  static Future<bool> setCartProductIds(List<int> ids) async {
    await init();
    final stringList = ids.map((id) => id.toString()).toList();
    return await _preferences?.setStringList(_keyCartProductIds, stringList) ?? false;
  }

  static Future<bool> addCartProductId(int id) async {
    final ids = getCartProductIds();
    if (!ids.contains(id)) {
      ids.add(id);
      return await setCartProductIds(ids);
    }
    return true;
  }

  static Future<bool> removeCartProductId(int id) async {
    final ids = getCartProductIds();
    if (ids.contains(id)) {
      ids.remove(id);
      return await setCartProductIds(ids);
    }
    return true;
  }

  // Clear on logout
  static Future<bool> clear() async {
    await init();
    return await _preferences?.clear() ?? false;
  }
}
