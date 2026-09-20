import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/local/local_preference.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../models/user_model.dart';
import '../../repo/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository authRepository;
  final CloudinaryService cloudinaryService;

  RegisterBloc({
    required this.authRepository,
    CloudinaryService? cloudinaryService,
  })  : cloudinaryService = cloudinaryService ?? CloudinaryService(),
        super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (event.name.trim().isEmpty) {
      emit(const RegisterFailure('Please enter your full name.'));
      return;
    }
    if (event.email.trim().isEmpty) {
      emit(const RegisterFailure('Please enter your email.'));
      return;
    }
    if (event.password.length < 6) {
      emit(const RegisterFailure('Password must be at least 6 characters.'));
      return;
    }
    if (event.password != event.confirmPassword) {
      emit(const RegisterFailure('Passwords do not match.'));
      return;
    }

    emit(const RegisterLoading());

    try {
      String profileImageUrl = '';
      if (event.imageFile != null) {
        profileImageUrl = await cloudinaryService.uploadImage(event.imageFile!);
      }

      final user = await authRepository.signUp(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
        profileImage: profileImageUrl,
      );
      await LocalPreference.setUserLogin(true);
      await LocalPreference.setUserId(user.uid);
      await LocalPreference.setUserEmail(user.email);
      emit(RegisterSuccess(user));
    } catch (e) {
      emit(RegisterFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
