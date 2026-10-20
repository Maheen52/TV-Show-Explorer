import '../../../data/show_model.dart';

// show is null until the user taps a show.
// (Then the best rated show is used, see SelectedShowBuilder.)
class SelectedShowState {
  final Show? show;

  const SelectedShowState({this.show});
}
