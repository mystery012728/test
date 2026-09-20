part of 'onboarding_bloc.dart';

abstract class OnboardingEvent {
  const OnboardingEvent();
}

class LoadInterestsEvent extends OnboardingEvent {
  final List<String>? initialSelectedCategories;
  const LoadInterestsEvent({this.initialSelectedCategories});
}

class ToggleInterestEvent extends OnboardingEvent {
  final String categorySlug;

  const ToggleInterestEvent(this.categorySlug);
}

class SaveInterestsEvent extends OnboardingEvent {
  final String? uid;

  const SaveInterestsEvent({this.uid});
}
