sealed class DetailsEvent {
  const DetailsEvent();
}

// Load cast and episodes of one show.
final class DetailsRequested extends DetailsEvent {
  final int showId;

  const DetailsRequested(this.showId);
}
