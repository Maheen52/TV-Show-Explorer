import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/show_model.dart';
import '../../domain/watchlist_storage.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/watchlist/watchlist_bloc.dart';
import '../bloc/watchlist/watchlist_event.dart';
import 'app_colors.dart';
import 'details_screen.dart';
import 'home_screen.dart';
import 'phone_frame.dart';
import 'search_page.dart';

// The one page of the app: all 7 screens of the design, side by side.
// Every phone is a working screen. They share the same BLoCs, so:
//  - tap a show anywhere  -> Details, Episodes and Cast show that show
//  - tap the heart        -> it appears in the Watchlist screen
class ShowcasePage extends StatelessWidget {
  const ShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FittedBox shrinks (or grows) the whole page so that all 7 windows
      // fit inside the browser window. No scrolling needed.
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- first row ----------
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),
                    const SizedBox(width: 28),
                    // 1. Home (4 tabs, starts on Home)
                    PhoneFrame(
                      label: '1. Discover / Home',
                      child: _withSearchBloc(const HomeScreen(initialIndex: 0)),
                    ),
                    const SizedBox(width: 28),
                    // 2. Search results (starts with a search for "breaking")
                    PhoneFrame(
                      label: '2. Search Results',
                      child: _withSearchBloc(
                        const SafeArea(
                          child: Scaffold(
                            body: SearchPage(initialQuery: 'breaking'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                    // 3. Details (Overview tab)
                    const PhoneFrame(
                      label: '3. Details',
                      child: DetailsScreen(initialTab: 0),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ---------- second row ----------
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 4. Episodes tab
                    const PhoneFrame(
                      label: '4. Seasons & Episodes',
                      child: DetailsScreen(initialTab: 1),
                    ),
                    const SizedBox(width: 28),
                    // 5. Cast tab
                    const PhoneFrame(
                      label: '5. Cast',
                      child: DetailsScreen(initialTab: 2),
                    ),
                    const SizedBox(width: 28),
                    // 6. Watchlist (the real saved watchlist, starts on the Watchlist tab)
                    PhoneFrame(
                      label: '6. Watchlist',
                      child: _withSearchBloc(const HomeScreen(initialIndex: 2)),
                    ),
                    const SizedBox(width: 28),
                    // 7. Empty watchlist (its own empty list, so the empty
                    //    state is always visible here)
                    PhoneFrame(
                      label: '7. Empty Watchlist',
                      child: MultiBlocProvider(
                        providers: [
                          BlocProvider(create: (_) => SearchBloc()),
                          BlocProvider(
                            create: (_) =>
                                WatchlistBloc(storage: _EmptyWatchlistStorage())
                                  ..add(const WatchlistStarted()),
                          ),
                        ],
                        child: const HomeScreen(initialIndex: 2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Every window that has a search box gets its own SearchBloc,
  // so typing in one window does not change the other windows.
  Widget _withSearchBloc(Widget child) {
    return BlocProvider(create: (_) => SearchBloc(), child: child);
  }

  // Title area (top left of the page)
  Widget _buildIntro() {
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Row(
            children: [
              Icon(Icons.live_tv, size: 44, color: AppColors.primary),
              SizedBox(width: 12),
              Text('TV', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              Text(
                'Maze',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Discover. Explore. Save.',
              style: TextStyle(fontSize: 20, color: AppColors.grey)),
          const SizedBox(height: 20),
          const Text(
            'A modern TV show discovery app using TVMaze API and BLoC.',
            style: TextStyle(color: AppColors.grey, height: 1.4),
          ),
          const SizedBox(height: 24),
          _buildFeature(Icons.search, 'Discover', 'Popular and trending shows'),
          _buildFeature(Icons.search, 'Search', 'Find your favorite shows'),
          _buildFeature(
              Icons.description, 'Details', 'Explore seasons, cast and more'),
          _buildFeature(Icons.favorite, 'Watchlist', 'Save shows locally'),
          const SizedBox(height: 12),
          const Text(
            'Tip: tap any show. It opens in the Details, Episodes and Cast '
            'screens. Tap the heart to add it to the Watchlist screen.',
            style: TextStyle(color: AppColors.grey, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

// Watchlist storage that starts empty and only lives in memory.
// Used by window 7 so the "empty watchlist" screen can always be seen.
class _EmptyWatchlistStorage extends WatchlistStorage {
  List<Show> _shows = [];

  @override
  Future<List<Show>> loadShows() async => _shows;

  @override
  Future<void> saveShows(List<Show> shows) async {
    _shows = shows;
  }
}
