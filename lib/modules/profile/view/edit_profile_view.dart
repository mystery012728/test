import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_toast_bar.dart';
import '../../auth/models/user_model.dart';
import '../bloc/profile_bloc.dart';

class EditProfileView extends StatefulWidget {
  final UserModel? user;
  const EditProfileView({super.key, this.user});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;
  late String _gender;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final user = widget.user ?? context.read<ProfileBloc>().state.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _dobController = TextEditingController(text: user?.dateOfBirth ?? '');

    const validGenders = ['Male', 'Female', 'Other', 'Prefer not to say'];
    final userGender = user?.gender ?? '';
    _gender = validGenders.contains(userGender) ? userGender : 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (picked != null && mounted) {
      context.read<ProfileBloc>().add(UploadProfileAvatarEvent(picked));
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload Profile Photo to Cloudinary',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primary),
                ),
                title: const Text('Take Photo with Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: AppColors.primary),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadAvatar(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    DateTime initial = DateTime(2000, 1, 1);
    if (_dobController.text.isNotEmpty) {
      final parsed = DateTime.tryParse(_dobController.text);
      if (parsed != null) initial = parsed;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          CustomToastBar.showSuccess(
            context,
            'Profile updated successfully in Cloud Firestore!',
          );
          Navigator.pop(context);
        } else if (state is ProfileError) {
          CustomToastBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          title: Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with Edit Badge & Cloudinary Upload
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      final isUploading = state is ProfileUpdating;
                      final currentUser = state.user ?? widget.user;
                      final profileImg = currentUser?.profileImage ?? '';

                      return Center(
                        child: GestureDetector(
                          onTap: isUploading ? null : _showImagePickerSheet,
                          child: Stack(
                            children: [
                              Container(
                                width: 100.r,
                                height: 100.r,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryDark
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: ClipOval(
                                  child: isUploading
                                      ? Container(
                                          color: Colors.black.withValues(alpha: 0.4),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        )
                                      : (profileImg.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: profileImg,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Center(
                                                child: Text(
                                                  _nameController.text
                                                          .trim()
                                                          .isNotEmpty
                                                      ? _nameController.text
                                                          .trim()[0]
                                                          .toUpperCase()
                                                      : 'U',
                                                  style: TextStyle(
                                                    fontSize: 38.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child: Text(
                                                _nameController.text
                                                        .trim()
                                                        .isNotEmpty
                                                    ? _nameController.text
                                                        .trim()[0]
                                                        .toUpperCase()
                                                    : 'U',
                                                style: TextStyle(
                                                  fontSize: 38.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            )),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: EdgeInsets.all(7.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.primary, width: 2),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 14.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 28.h),

                  // Full Name
                  Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person_outline_rounded,
                        color: AppColors.textSubtle),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Name cannot be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 18.h),

                  // Email Address (Read-only)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'Verified Account',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  CustomTextField(
                    controller: _emailController,
                    readOnly: true,
                    hintText: 'user@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: AppColors.textSubtle),
                  ),
                  SizedBox(height: 18.h),

                  // Phone Number
                  Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextField(
                    controller: _phoneController,
                    hintText: '+1 (555) 000-0000',
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined,
                        color: AppColors.textSubtle),
                  ),
                  SizedBox(height: 18.h),

                  // Date of Birth
                  Text(
                    'Date of Birth',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: _selectDateOfBirth,
                    child: AbsorbPointer(
                      child: CustomTextField(
                        controller: _dobController,
                        hintText: 'YYYY-MM-DD',
                        prefixIcon: const Icon(Icons.calendar_today_outlined,
                            color: AppColors.textSubtle),
                        suffixIcon: const Icon(Icons.edit_calendar_rounded,
                            color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // Gender Selector
                  Text(
                    'Gender',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _gender,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSubtle),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(
                              value: 'Female', child: Text('Female')),
                          DropdownMenuItem(
                              value: 'Other', child: Text('Other')),
                          DropdownMenuItem(
                              value: 'Prefer not to say',
                              child: Text('Prefer not to say')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _gender = val);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 36.h),

                  // Submit Button with BLoC state
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      final isUpdating = state is ProfileUpdating;
                      return CustomButton(
                        text: isUpdating ? 'Saving to Cloud...' : 'Save Changes',
                        isLoading: isUpdating,
                        onPressed: isUpdating
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  context.read<ProfileBloc>().add(
                                        UpdateProfileEvent(
                                          name: _nameController.text.trim(),
                                          phone: _phoneController.text.trim(),
                                          gender: _gender,
                                          dateOfBirth:
                                              _dobController.text.trim(),
                                        ),
                                      );
                                }
                              },
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
