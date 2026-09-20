part of 'register_bloc.dart';

abstract class RegisterEvent {
  const RegisterEvent();
}

class RegisterSubmitted extends RegisterEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final String gender;
  final String dateOfBirth;
  final XFile? imageFile;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.phone = '',
    this.gender = '',
    this.dateOfBirth = '',
    this.imageFile,
  });
}
