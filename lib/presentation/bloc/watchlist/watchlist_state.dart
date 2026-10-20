import '../../../data/show_model.dart';

sealed class WatchlistState {
  const WatchlistState();
}

final class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

// shows can be empty -> the UI shows the "empty" message
final class WatchlistLoaded extends WatchlistState {
  final List<Show> shows;

  const WatchlistLoaded(this.shows);
}

final class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError(this.message);
}
