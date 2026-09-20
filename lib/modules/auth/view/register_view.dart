import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_toast_bar.dart';
import '../bloc/register/register_bloc.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedGender = 'Male';
  XFile? _selectedImage;

  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
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
                'Add Profile Photo',
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
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: const Text('Take Photo with Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
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
            "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submitRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<RegisterBloc>().add(
            RegisterSubmitted(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              confirmPassword: _confirmPasswordController.text.trim(),
              phone: _phoneController.text.trim(),
              gender: _selectedGender,
              dateOfBirth: _dobController.text.trim(),
              imageFile: _selectedImage,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterFailure) {
          CustomToastBar.showError(context, state.error);
        } else if (state is RegisterSuccess) {
          CustomToastBar.showSuccess(
            context,
            'Account created successfully! Please personalize your feed.',
          );
          // Show Onboarding ONLY after register success
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        }
      },
      builder: (context, state) {
        final isLoading = state is RegisterLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Sign Up'),
            elevation: 0,
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Center(
                          child: Text(
                            'Complete your profile to get started',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSubtle,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Profile Image Selector (No shadow, flat & clean)
                        Center(
                          child: GestureDetector(
                            onTap: isLoading ? null : _showImagePickerSheet,
                            child: Stack(
                              children: [
                                Container(
                                  width: 90.r,
                                  height: 90.r,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _selectedImage != null
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _selectedImage != null
                                        ? Image.file(
                                            File(_selectedImage!.path),
                                            width: 90.r,
                                            height: 90.r,
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(
                                            Icons.person_rounded,
                                            size: 48.sp,
                                            color: AppColors.primary,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(6.r),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.white, width: 2),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_rounded,
                                      size: 14.sp,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Center(
                          child: Text(
                            _selectedImage != null ? 'Photo selected' : 'Add profile picture',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: _selectedImage != null
                                  ? AppColors.primary
                                  : AppColors.textSubtle,
                              fontWeight: _selectedImage != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Full Name
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Full Name',
                          hintText: 'e.g. Alex Smith',
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSubtle),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Email Address
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email Address',
                          hintText: 'alex.smith@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSubtle),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!val.contains('@') || !val.contains('.')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Phone Number
                        CustomTextField(
                          controller: _phoneController,
                          labelText: 'Phone Number',
                          hintText: '+1 234 567 8900',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSubtle),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (val.trim().length < 7) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Date of Birth
                        CustomTextField(
                          controller: _dobController,
                          labelText: 'Date of Birth',
                          hintText: 'YYYY-MM-DD',
                          readOnly: true,
                          onTap: isLoading ? null : _selectDateOfBirth,
                          prefixIcon: const Icon(Icons.cake_outlined, color: AppColors.textSubtle),
                          suffixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.textSubtle),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please select your date of birth';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Gender Selection
                        Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGender,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSubtle),
                              items: _genders.map((g) {
                                return DropdownMenuItem<String>(
                                  value: g,
                                  child: Row(
                                    children: [
                                      Icon(
                                        g == 'Male'
                                            ? Icons.male_rounded
                                            : g == 'Female'
                                                ? Icons.female_rounded
                                                : Icons.person_outline_rounded,
                                        size: 20.sp,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        g,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: isLoading
                                  ? null
                                  : (newVal) {
                                      if (newVal != null) {
                                        setState(() => _selectedGender = newVal);
                                      }
                                    },
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Password
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: '••••••••',
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSubtle),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSubtle,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Confirm Password
                        CustomTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          hintText: '••••••••',
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSubtle),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSubtle,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 28.h),

                        // Register Button
                        CustomButton(
                          text: 'Create Account',
                          isLoading: isLoading,
                          onPressed: _submitRegister,
                        ),
                        SizedBox(height: 20.h),

                        // Login Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(color: AppColors.textSubtle, fontSize: 14.sp),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Log In',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
