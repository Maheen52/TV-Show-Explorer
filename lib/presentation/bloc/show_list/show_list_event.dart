sealed class ShowListEvent {
  const ShowListEvent();
}

// Load the first page, or the next page when the user scrolls to the bottom.
final class ShowsFetched extends ShowListEvent {
  const ShowsFetched();
}
