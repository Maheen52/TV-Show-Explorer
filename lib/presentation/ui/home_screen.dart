import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'show_list_page.dart';
import 'watchlist_page.dart';

// Home screen = Scaffold with body + BottomNavigationBar (4 tabs).
// _currentIndex is ephemeral state (only this screen needs it),
// so we use setState() here instead of a BLoC.
class HomeScreen extends StatefulWidget {
  final int initialIndex; // which tab is open first (0 = Home ... 3 = Profile)

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex = widget.initialIndex;

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps every tab alive, so the scroll position
      // and the search text are not lost when we switch tabs.
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            ShowListPage(
              onSearchTap: () => _goToTab(1),
              onSettingsTap: () => _goToTab(3),
            ),
            const SearchPage(),
            WatchlistPage(onExploreTap: () => _goToTab(0)),
            ProfilePage(onWatchlistTap: () => _goToTab(2)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _goToTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
