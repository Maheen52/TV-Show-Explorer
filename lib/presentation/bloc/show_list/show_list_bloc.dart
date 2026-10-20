import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/tvmaze_api.dart';
import 'show_list_event.dart';
import 'show_list_state.dart';

class ShowListBloc extends Bloc<ShowListEvent, ShowListState> {
  final TvMazeApi _api;
  int _page = 0; // next page number to load

  ShowListBloc({TvMazeApi? api})
      : _api = api ?? TvMazeApi(),
        super(const ShowListInitial()) {
    on<ShowsFetched>(_onShowsFetched);
  }

  Future<void> _onShowsFetched(
    ShowsFetched event,
    Emitter<ShowListState> emit,
  ) async {
    final current = state;

    if (current is ShowListLoaded) {
      // ---- Pagination: load the next page ----
      if (current.hasReachedMax || current.isLoadingMore) return;

      emit(ShowListLoaded(shows: current.shows, isLoadingMore: true));

      try {
        final newShows = await _api.getShows(_page);
        _page++;
        emit(ShowListLoaded(
          shows: [...current.shows, ...newShows],
          hasReachedMax: newShows.isEmpty,
        ));
      } catch (error) {
        // keep the old shows on screen, only the bottom shows a retry button
        emit(ShowListLoaded(shows: current.shows, loadMoreFailed: true));
      }
    } else {
      // ---- First load (or retry after an error) ----
      if (current is ShowListLoading) return;

      emit(const ShowListLoading());

      try {
        final shows = await _api.getShows(_page);
        _page++;
        emit(ShowListLoaded(shows: shows, hasReachedMax: shows.isEmpty));
      } catch (error) {
        emit(const ShowListError(
            'Could not load shows. Please check your internet connection.'));
      }
    }
  }
}
