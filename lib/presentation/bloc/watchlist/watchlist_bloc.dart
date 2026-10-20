import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/show_model.dart';
import '../../../domain/watchlist_storage.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistStorage _storage;

  WatchlistBloc({WatchlistStorage? storage})
      : _storage = storage ?? WatchlistStorage(),
        super(const WatchlistLoading()) {
    on<WatchlistStarted>(_onStarted);
    on<WatchlistToggled>(_onToggled);
    on<WatchlistCleared>(_onCleared);
    on<WatchlistSorted>(_onSorted);
  }

  Future<void> _onStarted(
    WatchlistStarted event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoading());

    try {
      final shows = await _storage.loadShows();
      emit(WatchlistLoaded(shows));
    } catch (error) {
      emit(const WatchlistError('Could not load your watchlist.'));
    }
  }

  Future<void> _onToggled(
    WatchlistToggled event,
    Emitter<WatchlistState> emit,
  ) async {
    final current = state;
    if (current is! WatchlistLoaded) return;

    final bool alreadySaved = current.shows.any((s) => s.id == event.show.id);

    final List<Show> newShows;
    if (alreadySaved) {
      // remove
      newShows = current.shows.where((s) => s.id != event.show.id).toList();
    } else {
      // add
      newShows = [...current.shows, event.show];
    }

    // 1) save on the phone  2) tell the UI
    await _storage.saveShows(newShows);
    emit(WatchlistLoaded(newShows));
  }

  Future<void> _onCleared(
    WatchlistCleared event,
    Emitter<WatchlistState> emit,
  ) async {
    if (state is! WatchlistLoaded) return;

    await _storage.saveShows([]);
    emit(const WatchlistLoaded([]));
  }

  Future<void> _onSorted(
    WatchlistSorted event,
    Emitter<WatchlistState> emit,
  ) async {
    final current = state;
    if (current is! WatchlistLoaded) return;

    final List<Show> sorted = List.of(current.shows);

    if (event.sort == WatchlistSort.name) {
      sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else {
      sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }

    await _storage.saveShows(sorted);
    emit(WatchlistLoaded(sorted));
  }
}
