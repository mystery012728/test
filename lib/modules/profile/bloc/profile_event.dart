part of 'profile_bloc.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

class LoadProfileEvent extends ProfileEvent {
  final bool isRefresh;
  const LoadProfileEvent({this.isRefresh = false});
}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String phone;
  final String gender;
  final String dateOfBirth;
  final String? profileImage;

  const UpdateProfileEvent({
    required this.name,
    required this.phone,
    required this.gender,
    required this.dateOfBirth,
    this.profileImage,
  });
}

class UploadProfileAvatarEvent extends ProfileEvent {
  final XFile imageFile;
  const UploadProfileAvatarEvent(this.imageFile);
}
