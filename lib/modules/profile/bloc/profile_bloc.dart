import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../auth/models/user_model.dart';
import '../repo/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;
  final CloudinaryService cloudinaryService;

  ProfileBloc({
    required this.profileRepository,
    CloudinaryService? cloudinaryService,
  })  : cloudinaryService = cloudinaryService ?? CloudinaryService(),
        super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadProfileAvatarEvent>(_onUploadProfileAvatar);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (!event.isRefresh && state is! ProfileLoaded) {
      emit(ProfileLoading(user: state.user));
    }

    try {
      final user = await profileRepository.fetchUserProfile();
      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileError(
        e.toString().replaceAll('Exception: ', ''),
        user: state.user,
      ));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = state.user;
    if (currentUser != null) {
      emit(ProfileUpdating(user: currentUser));
    }

    try {
      final updatedUser = await profileRepository.updateUserProfile(
        name: event.name,
        phone: event.phone,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
        profileImage: event.profileImage,
      );

      emit(ProfileUpdated(user: updatedUser));
      emit(ProfileLoaded(user: updatedUser));
    } catch (e) {
      emit(ProfileError(
        'Failed to update profile: ${e.toString().replaceAll('Exception: ', '')}',
        user: currentUser,
      ));
    }
  }

  Future<void> _onUploadProfileAvatar(
    UploadProfileAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = state.user;
    if (currentUser != null) {
      emit(ProfileUpdating(user: currentUser));
    } else {
      emit(const ProfileLoading());
    }

    try {
      // 1. Upload to Cloudinary
      final secureUrl = await cloudinaryService.uploadImage(event.imageFile);

      // 2. Persist URL in Firebase Firestore users/{uid}
      final user = currentUser ?? await profileRepository.fetchUserProfile();
      final updatedUser = await profileRepository.updateUserProfile(
        name: user.name,
        phone: user.phone,
        gender: user.gender,
        dateOfBirth: user.dateOfBirth,
        profileImage: secureUrl,
      );

      emit(ProfileUpdated(user: updatedUser));
      emit(ProfileLoaded(user: updatedUser));
    } catch (e) {
      emit(ProfileError(
        e.toString().replaceAll('Exception: ', ''),
        user: currentUser,
      ));
    }
  }
}
