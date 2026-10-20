import '../../../data/show_model.dart';

sealed class ShowListState {
  const ShowListState();
}

final class ShowListInitial extends ShowListState {
  const ShowListInitial();
}

// First page is loading (full screen spinner)
final class ShowListLoading extends ShowListState {
  const ShowListLoading();
}

final class ShowListLoaded extends ShowListState {
  final List<Show> shows;
  final bool hasReachedMax; // true when there are no more pages
  final bool isLoadingMore; // true while the next page is loading
  final bool loadMoreFailed; // true if loading the next page failed

  const ShowListLoaded({
    required this.shows,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  // All loaded shows that have a rating, best rating first.
  List<Show> get topRated {
    final rated = shows.where((s) => s.rating != null).toList();
    rated.sort((a, b) => b.rating!.compareTo(a.rating!));
    return rated;
  }

  // "Trending Now": the 10 highest rated shows among the loaded shows.
  List<Show> get trending => topRated.take(10).toList();

  // "Similar" tab: loaded shows that share genres with the given show.
  // More shared genres first, then higher rating first.
  List<Show> similarTo(Show show) {
    int shared(Show s) => s.genres.where((g) => show.genres.contains(g)).length;

    final similar =
        shows.where((s) => s.id != show.id && shared(s) > 0).toList();

    similar.sort((a, b) {
      final byGenres = shared(b).compareTo(shared(a));
      if (byGenres != 0) return byGenres;
      return (b.rating ?? 0).compareTo(a.rating ?? 0);
    });
    return similar.take(10).toList();
  }
}

final class ShowListError extends ShowListState {
  final String message;

  const ShowListError(this.message);
}
