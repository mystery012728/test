import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    String phone = '',
    String gender = '',
    String dateOfBirth = '',
    String profileImage = '',
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User registration failed: null user credential.');
      }

      await user.updateDisplayName(name.trim());
      if (profileImage.isNotEmpty) {
        try {
          await user.updatePhotoURL(profileImage);
        } catch (_) {}
      }

      final newUser = UserModel(
        uid: user.uid,
        email: email.trim(),
        name: name.trim(),
        phone: phone.trim(),
        gender: gender.trim(),
        dateOfBirth: dateOfBirth.trim(),
        profileImage: profileImage.trim(),
        favoriteCategories: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save initial user document in Firestore users/{uid}
      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User login failed: null user credential.');
      }

      return await getUserProfile(user.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Reset password error: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<UserModel> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc);
    } else {
      // Fallback if document wasn't yet created
      final fbUser = _firebaseAuth.currentUser;
      return UserModel(
        uid: uid,
        email: fbUser?.email ?? '',
        name: fbUser?.displayName ?? 'User',
      );
    }
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please provide a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}
