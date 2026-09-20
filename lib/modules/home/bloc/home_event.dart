part of 'home_bloc.dart';

abstract class HomeEvent {
  const HomeEvent();
}

class LoadHomeDataEvent extends HomeEvent {
  const LoadHomeDataEvent();
}

class RefreshHomeDataEvent extends HomeEvent {
  const RefreshHomeDataEvent();
}
