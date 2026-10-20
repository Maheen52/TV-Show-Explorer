import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/episode_model.dart';
import '../../../domain/tvmaze_api.dart';
import 'details_event.dart';
import 'details_state.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final TvMazeApi _api;

  DetailsBloc({TvMazeApi? api})
      : _api = api ?? TvMazeApi(),
        super(const DetailsInitial()) {
    on<DetailsRequested>(_onDetailsRequested);
  }

  Future<void> _onDetailsRequested(
    DetailsRequested event,
    Emitter<DetailsState> emit,
  ) async {
    emit(const DetailsLoading());

    try {
      // Start all 3 API calls together (faster than one after another)
      final showFuture = _api.getShowDetails(event.showId);
      final castFuture = _api.getCast(event.showId);
      final episodesFuture = _api.getEpisodes(event.showId);

      // wait until all are finished (if one fails, we go to catch)
      await Future.wait([showFuture, castFuture, episodesFuture]);

      final show = await showFuture;
      final cast = await castFuture;
      final episodes = await episodesFuture;

      // Group the episodes by season number
      final Map<int, List<Episode>> grouped = {};
      for (final episode in episodes) {
        grouped.putIfAbsent(episode.season, () => []).add(episode);
      }

      emit(DetailsLoaded(
        show: show,
        cast: cast,
        episodesBySeason: grouped,
      ));
    } catch (error) {
      emit(const DetailsError(
          'Could not load show details. Please try again.'));
    }
  }
}
