part of 'splash_bloc.dart';

abstract class SplashState {
  const SplashState();
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashNavigateToHome extends SplashState {
  const SplashNavigateToHome();
}

class SplashNavigateToLogin extends SplashState {
  const SplashNavigateToLogin();
}
