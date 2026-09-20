import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/local/local_preference.dart';
import '../models/interest_category_model.dart';
import '../repo/onboarding_repository.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository onboardingRepository;

  OnboardingBloc({required this.onboardingRepository}) : super(const OnboardingInitial()) {
    on<LoadInterestsEvent>(_onLoadInterests);
    on<ToggleInterestEvent>(_onToggleInterest);
    on<SaveInterestsEvent>(_onSaveInterests);
  }

  Future<void> _onLoadInterests(
    LoadInterestsEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());

    final categories = onboardingRepository.getAvailableCategories();
    Set<String> initialSelections = {};

    // 1. Passed explicitly from Profile or other views
    if (event.initialSelectedCategories != null &&
        event.initialSelectedCategories!.isNotEmpty) {
      initialSelections = event.initialSelectedCategories!.toSet();
    } else {
      // 2. Fetch from backend Firestore
      final uid = onboardingRepository.currentUserId;
      if (uid != null && uid.isNotEmpty) {
        try {
          final backendCategories =
              await onboardingRepository.fetchUserFavoriteCategories(uid);
          if (backendCategories.isNotEmpty) {
            initialSelections = backendCategories.toSet();
          }
        } catch (_) {
          // ignore and fallback to local cache
        }
      }

      // 3. Fallback to LocalPreference cache
      if (initialSelections.isEmpty &&
          LocalPreference.favoriteCategories.isNotEmpty) {
        initialSelections = LocalPreference.favoriteCategories.toSet();
      }

      // 4. Default fallback if completely empty
      if (initialSelections.isEmpty) {
        initialSelections = {'smartphones', 'beauty', 'mens-watches'};
      }
    }

    emit(
      OnboardingLoaded(
        categories: categories,
        selectedSlugs: initialSelections,
        isValid: initialSelections.length >= 3 && initialSelections.length <= 5,
      ),
    );
  }

  void _onToggleInterest(
    ToggleInterestEvent event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      final updatedSet = Set<String>.from(currentState.selectedSlugs);

      if (updatedSet.contains(event.categorySlug)) {
        updatedSet.remove(event.categorySlug);
        emit(
          currentState.copyWith(
            selectedSlugs: updatedSet,
            isValid: updatedSet.length >= 3 && updatedSet.length <= 5,
            errorMessage: null,
          ),
        );
      } else {
        if (updatedSet.length >= 5) {
          emit(
            currentState.copyWith(
              errorMessage: 'You can select a maximum of 5 categories.',
            ),
          );
        } else {
          updatedSet.add(event.categorySlug);
          emit(
            currentState.copyWith(
              selectedSlugs: updatedSet,
              isValid: updatedSet.length >= 3 && updatedSet.length <= 5,
              errorMessage: null,
            ),
          );
        }
      }
    }
  }

  Future<void> _onSaveInterests(
    SaveInterestsEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;

      if (!currentState.isValid) {
        emit(
          currentState.copyWith(
            errorMessage: 'Please select between 3 and 5 categories.',
          ),
        );
        return;
      }

      final uid = event.uid ?? onboardingRepository.currentUserId ?? 'guest_user';
      final selectedList = currentState.selectedSlugs.toList();

      emit(const OnboardingSaving());

      try {
        await onboardingRepository.saveFavoriteCategories(
          uid: uid,
          categories: selectedList,
        );
        emit(OnboardingSuccess(selectedList));
      } catch (e) {
        emit(OnboardingFailure(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }
}
