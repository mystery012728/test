import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/local/local_preference.dart';
import '../../models/user_model.dart';
import '../../repo/auth_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(const LoginFailure('Please fill in both email and password.'));
      return;
    }

    emit(const LoginLoading());

    try {
      final user = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      await LocalPreference.setUserLogin(true);
      await LocalPreference.setUserId(user.uid);
      await LocalPreference.setUserEmail(user.email);
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
