import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/local/local_preference.dart';
import '../../models/product_model.dart';
import '../../repo/product_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ProductRepository productRepository;

  SearchBloc({required this.productRepository})
      : super(SearchInitial(
          recentSearches: LocalPreference.getRecentSearchList(),
        )) {
    on<LoadSearchInitialEvent>(_onLoadSearchInitial);
    on<SearchQuerySubmittedEvent>(_onSearchQuerySubmitted);
    on<ClearSearchEvent>(_onClearSearch);
    on<ClearRecentSearchesEvent>(_onClearRecentSearches);
  }

  void _onLoadSearchInitial(
    LoadSearchInitialEvent event,
    Emitter<SearchState> emit,
  ) {
    final recents = LocalPreference.getRecentSearchList();
    emit(SearchInitial(recentSearches: recents));
  }

  Future<void> _onSearchQuerySubmitted(
    SearchQuerySubmittedEvent event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      final recents = LocalPreference.getRecentSearchList();
      emit(SearchInitial(recentSearches: recents));
      return;
    }

    // Save recent search via LocalPreference
    await LocalPreference.setRecentSearch(query);
    final recents = LocalPreference.getRecentSearchList();

    emit(SearchLoading(recentSearches: recents));
    try {
      final response = await productRepository.searchProducts(query);
      if (response.products.isEmpty) {
        emit(SearchEmpty(query: query, recentSearches: recents));
      } else {
        emit(SearchLoaded(
          results: response.products,
          query: query,
          recentSearches: recents,
        ));
      }
    } catch (e) {
      emit(SearchError(
        e.toString().replaceAll('Exception: ', ''),
        recentSearches: recents,
      ));
    }
  }

  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) {
    final recents = LocalPreference.getRecentSearchList();
    emit(SearchInitial(recentSearches: recents));
  }

  Future<void> _onClearRecentSearches(
    ClearRecentSearchesEvent event,
    Emitter<SearchState> emit,
  ) async {
    await LocalPreference.clearRecentSearches();
    emit(const SearchInitial(recentSearches: []));
  }
}
