import 'package:flutter_test/flutter_test.dart';
import 'package:testprojectnew/modules/auth/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('Correctly serializes and deserializes UserModel', () {
      final user = UserModel(
        uid: 'user_123',
        email: 'alex@example.com',
        name: 'Alex Smith',
        phone: '+1 555 123 4567',
        gender: 'Male',
        dateOfBirth: '1995-06-15',
        profileImage: 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        favoriteCategories: ['smartphones', 'laptops'],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
      );

      final map = user.toMap();
      expect(map['uid'], 'user_123');
      expect(map['email'], 'alex@example.com');
      expect(map['name'], 'Alex Smith');
      expect(map['phone'], '+1 555 123 4567');
      expect(map['gender'], 'Male');
      expect(map['dateOfBirth'], '1995-06-15');
      expect(map['profileImage'], 'https://res.cloudinary.com/demo/image/upload/sample.jpg');
      expect(map['favoriteCategories'], ['smartphones', 'laptops']);

      final fromMap = UserModel.fromMap(map, 'user_123');
      expect(fromMap.uid, 'user_123');
      expect(fromMap.email, 'alex@example.com');
      expect(fromMap.name, 'Alex Smith');
      expect(fromMap.phone, '+1 555 123 4567');
      expect(fromMap.gender, 'Male');
      expect(fromMap.dateOfBirth, '1995-06-15');
      expect(fromMap.profileImage, 'https://res.cloudinary.com/demo/image/upload/sample.jpg');
      expect(fromMap.favoriteCategories, ['smartphones', 'laptops']);
    });

    test('UserModel copyWith updates fields properly', () {
      final user = UserModel(
        uid: 'user_123',
        email: 'alex@example.com',
        name: 'Alex Smith',
      );

      final updated = user.copyWith(
        name: 'Alexander Smith',
        phone: '+1 800 555 0199',
        gender: 'Other',
        dateOfBirth: '1992-04-10',
      );

      expect(updated.uid, 'user_123');
      expect(updated.email, 'alex@example.com');
      expect(updated.name, 'Alexander Smith');
      expect(updated.phone, '+1 800 555 0199');
      expect(updated.gender, 'Other');
      expect(updated.dateOfBirth, '1992-04-10');
    });
  });
}
