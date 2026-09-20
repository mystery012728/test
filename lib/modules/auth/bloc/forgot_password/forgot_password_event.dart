part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordEvent {
  const ForgotPasswordEvent();
}

class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  final String email;

  const ForgotPasswordSubmitted({required this.email});
}
