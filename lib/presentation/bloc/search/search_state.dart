import '../../../data/person_model.dart';
import '../../../data/show_model.dart';

sealed class SearchState {
  const SearchState();
}

// Nothing typed yet
final class SearchInitial extends SearchState {
  const SearchInitial();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchLoaded extends SearchState {
  final List<Show> shows;

  const SearchLoaded(this.shows);
}

// People search result
final class SearchPeopleLoaded extends SearchState {
  final List<Person> people;

  const SearchPeopleLoaded(this.people);
}

// API worked but found 0 results
final class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty(this.query);
}

final class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);
}
