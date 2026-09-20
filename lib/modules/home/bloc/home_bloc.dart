import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/local/local_preference.dart';
import '../../auth/repo/auth_repository.dart';
import '../../product/models/product_model.dart';
import '../repo/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;
  final AuthRepository authRepository;

  HomeBloc({
    required this.homeRepository,
    required this.authRepository,
  }) : super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<RefreshHomeDataEvent>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _fetchAndEmitData(emit);
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _fetchAndEmitData(emit);
  }

  Future<void> _fetchAndEmitData(Emitter<HomeState> emit) async {
    try {
      // 1. Get user name
      final currentFbUser = authRepository.currentFirebaseUser;
      String userName = currentFbUser?.displayName ?? 'Shopper';
      if (userName.isEmpty) {
        userName = LocalPreference.userEmail?.split('@').first ?? 'Shopper';
      }

      // 2. Get favorite categories from LocalPreference or defaults
      List<String> categories = LocalPreference.favoriteCategories;
      if (categories.isEmpty && currentFbUser != null) {
        final profile = await authRepository.getUserProfile(currentFbUser.uid);
        categories = profile.favoriteCategories;
        if (categories.isNotEmpty) {
          await LocalPreference.setFavoriteCategories(categories);
        }
      }

      // 3. Fetch real products from DummyJSON API simultaneously
      final results = await Future.wait([
        homeRepository.fetchPersonalizedProducts(categories),
        homeRepository.fetchPopularProducts(limit: 10, skip: 0),
      ]);

      final personalizedProducts = results[0];
      final popularProducts = results[1];

      emit(
        HomeLoaded(
          personalizedProducts: personalizedProducts,
          popularProducts: popularProducts,
          userName: userName,
          favoriteCategories: categories,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
