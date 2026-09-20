part of 'search_bloc.dart';

abstract class SearchEvent {
  const SearchEvent();
}

class LoadSearchInitialEvent extends SearchEvent {
  const LoadSearchInitialEvent();
}

class SearchQuerySubmittedEvent extends SearchEvent {
  final String query;

  const SearchQuerySubmittedEvent(this.query);
}

class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
}

class ClearRecentSearchesEvent extends SearchEvent {
  const ClearRecentSearchesEvent();
}
