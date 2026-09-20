part of 'register_bloc.dart';

abstract class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final UserModel user;

  const RegisterSuccess(this.user);
}

class RegisterFailure extends RegisterState {
  final String error;

  const RegisterFailure(this.error);
}
