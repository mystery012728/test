part of 'search_bloc.dart';

abstract class SearchState {
  final List<String> recentSearches;

  const SearchState({this.recentSearches = const []});
}

class SearchInitial extends SearchState {
  const SearchInitial({super.recentSearches});
}

class SearchLoading extends SearchState {
  const SearchLoading({super.recentSearches});
}

class SearchLoaded extends SearchState {
  final List<ProductModel> results;
  final String query;

  const SearchLoaded({
    required this.results,
    required this.query,
    super.recentSearches,
  });
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty({
    required this.query,
    super.recentSearches,
  });
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message, {super.recentSearches});
}
