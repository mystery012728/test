part of 'home_bloc.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<ProductModel> personalizedProducts;
  final List<ProductModel> popularProducts;
  final String userName;
  final List<String> favoriteCategories;

  const HomeLoaded({
    required this.personalizedProducts,
    required this.popularProducts,
    required this.userName,
    required this.favoriteCategories,
  });

  HomeLoaded copyWith({
    List<ProductModel>? personalizedProducts,
    List<ProductModel>? popularProducts,
    String? userName,
    List<String>? favoriteCategories,
  }) {
    return HomeLoaded(
      personalizedProducts: personalizedProducts ?? this.personalizedProducts,
      popularProducts: popularProducts ?? this.popularProducts,
      userName: userName ?? this.userName,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}
