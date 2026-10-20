import '../../../data/show_model.dart';

sealed class SelectedShowEvent {
  const SelectedShowEvent();
}

// A show was tapped (in Home, Search, Watchlist ...).
// The Details, Episodes and Cast screens then show this show.
final class ShowSelected extends SelectedShowEvent {
  final Show show;

  const ShowSelected(this.show);
}
