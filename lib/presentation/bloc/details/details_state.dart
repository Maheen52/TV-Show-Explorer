import '../../../data/cast_model.dart';
import '../../../data/episode_model.dart';
import '../../../data/show_model.dart';

sealed class DetailsState {
  const DetailsState();
}

final class DetailsInitial extends DetailsState {
  const DetailsInitial();
}

final class DetailsLoading extends DetailsState {
  const DetailsLoading();
}

final class DetailsLoaded extends DetailsState {
  final Show show; // full show details from /shows/:id
  final List<CastMember> cast;

  // Example: { 1: [episode1, episode2], 2: [episode1, ...] }
  final Map<int, List<Episode>> episodesBySeason;

  const DetailsLoaded({
    required this.show,
    required this.cast,
    required this.episodesBySeason,
  });
}

final class DetailsError extends DetailsState {
  final String message;

  const DetailsError(this.message);
}
