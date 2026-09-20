import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../modules/auth/bloc/forgot_password/forgot_password_bloc.dart';
import '../../modules/auth/bloc/login/login_bloc.dart';
import '../../modules/auth/bloc/register/register_bloc.dart';
import '../../modules/auth/bloc/splash/splash_bloc.dart';
import '../../modules/auth/repo/auth_repository.dart';
import '../../modules/home/bloc/home_bloc.dart';
import '../../modules/home/repo/home_repository.dart';
import '../../modules/cart/bloc/cart/cart_bloc.dart';
import '../../modules/cart/bloc/wishlist/wishlist_bloc.dart';
import '../../modules/cart/repo/cart_repository.dart';
import '../../modules/cart/repo/wishlist_repository.dart';
import '../../modules/onboarding/bloc/onboarding_bloc.dart';
import '../../modules/onboarding/repo/onboarding_repository.dart';
import '../../modules/order/bloc/order_bloc.dart';
import '../../modules/order/repo/order_repository.dart';
import '../../modules/product/bloc/product_detail/product_detail_bloc.dart';
import '../../modules/product/bloc/product_list/product_list_bloc.dart';
import '../../modules/product/bloc/search/search_bloc.dart';
import '../../modules/product/repo/product_repository.dart';
import '../../modules/profile/bloc/profile_bloc.dart';
import '../../modules/profile/repo/profile_repository.dart';

class AllBlocProviders extends StatelessWidget {
  final Widget child;

  const AllBlocProviders({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<OnboardingRepository>(
          create: (_) => OnboardingRepository(),
        ),
        RepositoryProvider<HomeRepository>(
          create: (_) => HomeRepository(),
        ),
        RepositoryProvider<ProductRepository>(
          create: (_) => ProductRepository(),
        ),
        RepositoryProvider<WishlistRepository>(
          create: (_) => WishlistRepository(),
        ),
        RepositoryProvider<CartRepository>(
          create: (_) => CartRepository(),
        ),
        RepositoryProvider<OrderRepository>(
          create: (_) => OrderRepository(),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (_) => ProfileRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SplashBloc>(
            create: (context) => SplashBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<RegisterBloc>(
            create: (context) => RegisterBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<ForgotPasswordBloc>(
            create: (context) => ForgotPasswordBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<OnboardingBloc>(
            create: (context) => OnboardingBloc(
              onboardingRepository: context.read<OnboardingRepository>(),
            )..add(const LoadInterestsEvent()),
          ),
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(
              homeRepository: context.read<HomeRepository>(),
              authRepository: context.read<AuthRepository>(),
            )..add(const LoadHomeDataEvent()),
          ),
          BlocProvider<ProductListBloc>(
            create: (context) => ProductListBloc(
              productRepository: context.read<ProductRepository>(),
            ),
          ),
          BlocProvider<ProductDetailBloc>(
            create: (context) => ProductDetailBloc(
              productRepository: context.read<ProductRepository>(),
            ),
          ),
          BlocProvider<SearchBloc>(
            create: (context) => SearchBloc(
              productRepository: context.read<ProductRepository>(),
            ),
          ),
          BlocProvider<WishlistBloc>(
            create: (context) => WishlistBloc(
              wishlistRepository: context.read<WishlistRepository>(),
            )..add(const LoadWishlistEvent()),
          ),
          BlocProvider<CartBloc>(
            create: (context) => CartBloc(
              cartRepository: context.read<CartRepository>(),
            )..add(const LoadCartEvent()),
          ),
          BlocProvider<OrderBloc>(
            create: (context) => OrderBloc(
              orderRepository: context.read<OrderRepository>(),
            )..add(const LoadOrderHistoryEvent()),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              profileRepository: context.read<ProfileRepository>(),
            )..add(const LoadProfileEvent()),
          ),
        ],
        child: child,
      ),
    );
  }
}
