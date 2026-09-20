import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/local/local_preference.dart';
import '../../repo/auth_repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthRepository authRepository;

  SplashBloc({required this.authRepository}) : super(const SplashInitial()) {
    on<CheckLoginEvent>(_onCheckLoginEvent);
  }

  Future<void> _onCheckLoginEvent(
    CheckLoginEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    // Show splash branding for at least 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    // Initialize local preferences if not yet loaded
    await LocalPreference.init();

    final isLocallyLoggedIn = LocalPreference.isUserLogin;
    final currentFirebaseUser = authRepository.currentFirebaseUser;

    // If local preference is true and Firebase user exists, navigate to Home
    if (isLocallyLoggedIn && currentFirebaseUser != null) {
      emit(const SplashNavigateToHome());
    } else {
      // If not logged in, ensure local preference is reset and navigate to Login
      if (!isLocallyLoggedIn) {
        await LocalPreference.setUserLogin(false);
      }
      emit(const SplashNavigateToLogin());
    }
  }
}
