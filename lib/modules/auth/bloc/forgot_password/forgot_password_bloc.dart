import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repo/auth_repository.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthRepository authRepository;

  ForgotPasswordBloc({required this.authRepository})
      : super(const ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
  }

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    if (event.email.trim().isEmpty) {
      emit(const ForgotPasswordFailure('Please enter your email address.'));
      return;
    }

    emit(const ForgotPasswordLoading());

    try {
      await authRepository.sendPasswordResetEmail(email: event.email);
      emit(const ForgotPasswordSuccess('Password reset link sent to your email.'));
    } catch (e) {
      emit(ForgotPasswordFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
