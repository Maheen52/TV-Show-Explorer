import '../../../data/show_model.dart';

sealed class WatchlistEvent {
  const WatchlistEvent();
}

// Read the saved watchlist from the phone storage (app start).
final class WatchlistStarted extends WatchlistEvent {
  const WatchlistStarted();
}

// Add the show if it is not in the watchlist, remove it if it is.
final class WatchlistToggled extends WatchlistEvent {
  final Show show;

  const WatchlistToggled(this.show);
}

// Remove every show from the watchlist.
final class WatchlistCleared extends WatchlistEvent {
  const WatchlistCleared();
}

enum WatchlistSort { name, rating }

// Sort the watchlist by name (A-Z) or by rating (best first).
final class WatchlistSorted extends WatchlistEvent {
  final WatchlistSort sort;

  const WatchlistSorted(this.sort);
}
