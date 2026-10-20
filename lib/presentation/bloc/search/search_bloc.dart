import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/tvmaze_api.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final TvMazeApi _api;

  // Counts the searches. Every new letter typed makes a new number.
  int _latestSearchId = 0;

  SearchBloc({TvMazeApi? api})
      : _api = api ?? TvMazeApi(),
        super(const SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    // this search gets its own number
    final int myId = ++_latestSearchId;
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    // DEBOUNCE: wait 500 ms. If the user types another letter in this time,
    // _latestSearchId changes, so this search stops and makes no API call.
    await Future.delayed(const Duration(milliseconds: 500));
    if (myId != _latestSearchId) return;

    emit(const SearchLoading());

    try {
      if (event.isPeople) {
        final people = await _api.searchPeople(query);
        if (myId != _latestSearchId) return;

        emit(people.isEmpty ? SearchEmpty(query) : SearchPeopleLoaded(people));
        return;
      }

      final shows = await _api.searchShows(query);

      // user typed something new while we were waiting for the API
      if (myId != _latestSearchId) return;

      emit(shows.isEmpty ? SearchEmpty(query) : SearchLoaded(shows));
    } catch (error) {
      if (myId != _latestSearchId) return;
      emit(const SearchError(
          'Search failed. Please check your internet connection.'));
    }
  }
}
