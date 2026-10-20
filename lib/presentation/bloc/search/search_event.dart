sealed class SearchEvent {
  const SearchEvent();
}

// Sent every time the user types a letter, or switches Shows / People.
final class SearchQueryChanged extends SearchEvent {
  final String query;
  final bool isPeople; // false = search shows, true = search people

  const SearchQueryChanged(this.query, {this.isPeople = false});
}
