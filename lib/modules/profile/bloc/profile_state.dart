part of 'profile_bloc.dart';

abstract class ProfileState {
  final UserModel? user;
  const ProfileState({this.user});
}

class ProfileInitial extends ProfileState {
  const ProfileInitial({super.user});
}

class ProfileLoading extends ProfileState {
  const ProfileLoading({super.user});
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required UserModel user}) : super(user: user);

  @override
  UserModel get user => super.user!;
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating({required UserModel user}) : super(user: user);

  @override
  UserModel get user => super.user!;
}

class ProfileUpdated extends ProfileState {
  const ProfileUpdated({required UserModel user}) : super(user: user);

  @override
  UserModel get user => super.user!;
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message, {super.user});
}
