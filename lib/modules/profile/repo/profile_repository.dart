import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/local/local_preference.dart';
import '../../auth/models/user_model.dart';

class ProfileRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  ProfileRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  String? get _currentUid =>
      _firebaseAuth.currentUser?.uid ?? LocalPreference.userId;

  /// Fetches the user profile from Firestore users/{uid}
  Future<UserModel> fetchUserProfile() async {
    final uid = _currentUid;
    final fbUser = _firebaseAuth.currentUser;

    if (uid == null || uid.isEmpty) {
      return UserModel(
        uid: 'guest',
        email: fbUser?.email ?? LocalPreference.userEmail ?? 'guest@laza.com',
        name: fbUser?.displayName ?? 'Valued Customer',
        favoriteCategories: LocalPreference.favoriteCategories,
      );
    }

    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromFirestore(doc);
        // Sync favorite categories if local is newer
        if (user.favoriteCategories.isEmpty &&
            LocalPreference.favoriteCategories.isNotEmpty) {
          await _firestore.collection('users').doc(uid).set({
            'favoriteCategories': LocalPreference.favoriteCategories,
          }, SetOptions(merge: true));
          return user.copyWith(
              favoriteCategories: LocalPreference.favoriteCategories);
        }
        return user;
      } else {
        // Document does not exist yet in Firestore, create default
        final newUser = UserModel(
          uid: uid,
          email: fbUser?.email ?? LocalPreference.userEmail ?? '',
          name: fbUser?.displayName ?? 'Valued Customer',
          favoriteCategories: LocalPreference.favoriteCategories,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(uid)
            .set(newUser.toMap(), SetOptions(merge: true));

        return newUser;
      }
    } catch (e) {
      // Fallback on error (e.g. offline)
      return UserModel(
        uid: uid,
        email: fbUser?.email ?? LocalPreference.userEmail ?? '',
        name: fbUser?.displayName ?? 'Valued Customer',
        favoriteCategories: LocalPreference.favoriteCategories,
      );
    }
  }

  /// Updates user profile fields in Firestore users/{uid}
  Future<UserModel> updateUserProfile({
    required String name,
    required String phone,
    required String gender,
    required String dateOfBirth,
    String? profileImage,
  }) async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) {
      throw Exception('User is not authenticated. Please log in.');
    }

    final updateMap = <String, dynamic>{
      'name': name.trim(),
      'phone': phone.trim(),
      'gender': gender.trim(),
      'dateOfBirth': dateOfBirth.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (profileImage != null && profileImage.isNotEmpty) {
      updateMap['profileImage'] = profileImage.trim();
    }

    // Update in Firestore
    await _firestore
        .collection('users')
        .doc(uid)
        .set(updateMap, SetOptions(merge: true));

    // Update Firebase Auth display name and photoURL if applicable
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      if (name.trim().isNotEmpty) {
        try {
          await fbUser.updateDisplayName(name.trim());
        } catch (_) {}
      }
      if (profileImage != null && profileImage.isNotEmpty) {
        try {
          await fbUser.updatePhotoURL(profileImage.trim());
        } catch (_) {}
      }
    }

    return await fetchUserProfile();
  }
}
