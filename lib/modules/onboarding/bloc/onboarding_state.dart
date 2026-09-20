part of 'onboarding_bloc.dart';

abstract class OnboardingState {
  const OnboardingState();
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

class OnboardingLoaded extends OnboardingState {
  final List<InterestCategoryModel> categories;
  final Set<String> selectedSlugs;
  final bool isValid;
  final String? errorMessage;

  const OnboardingLoaded({
    required this.categories,
    required this.selectedSlugs,
    required this.isValid,
    this.errorMessage,
  });

  OnboardingLoaded copyWith({
    List<InterestCategoryModel>? categories,
    Set<String>? selectedSlugs,
    bool? isValid,
    String? errorMessage,
  }) {
    return OnboardingLoaded(
      categories: categories ?? this.categories,
      selectedSlugs: selectedSlugs ?? this.selectedSlugs,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
    );
  }
}

class OnboardingSaving extends OnboardingState {
  const OnboardingSaving();
}

class OnboardingSuccess extends OnboardingState {
  final List<String> savedCategories;

  const OnboardingSuccess(this.savedCategories);
}

class OnboardingFailure extends OnboardingState {
  final String error;

  const OnboardingFailure(this.error);
}
