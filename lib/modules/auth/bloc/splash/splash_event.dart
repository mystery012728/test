part of 'splash_bloc.dart';

abstract class SplashEvent {
  const SplashEvent();
}

class CheckLoginEvent extends SplashEvent {
  const CheckLoginEvent();
}
