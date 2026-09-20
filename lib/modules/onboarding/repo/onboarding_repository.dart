import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/local/local_preference.dart';
import '../models/interest_category_model.dart';

class OnboardingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  OnboardingRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  String? get currentUserId => _firebaseAuth.currentUser?.uid ?? LocalPreference.userId;

  List<InterestCategoryModel> getAvailableCategories() {
    return InterestCategoryModel.defaultCategories;
  }

  Future<void> saveFavoriteCategories({
    required String uid,
    required List<String> categories,
  }) async {
    try {
      // 1. Update Cloud Firestore users/{uid}
      await _firestore.collection('users').doc(uid).set(
        {
          'favoriteCategories': categories,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // 2. Cache in LocalPreference for instant offline personalization
      await LocalPreference.setFavoriteCategories(categories);
    } catch (e) {
      // If Firestore fails, still cache locally and rethrow friendly message
      await LocalPreference.setFavoriteCategories(categories);
      throw Exception('Failed to save interests: ${e.toString()}');
    }
  }

  Future<List<String>> fetchUserFavoriteCategories(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final list = List<String>.from(doc.data()?['favoriteCategories'] as List? ?? []);
        await LocalPreference.setFavoriteCategories(list);
        return list;
      }
      return LocalPreference.favoriteCategories;
    } catch (e) {
      return LocalPreference.favoriteCategories;
    }
  }
}
