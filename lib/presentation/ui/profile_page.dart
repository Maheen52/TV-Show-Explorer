import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/watchlist/watchlist_bloc.dart';
import '../bloc/watchlist/watchlist_state.dart';
import 'app_colors.dart';
import 'widgets/clear_watchlist_dialog.dart';

// "Profile" tab: small summary of the watchlist + settings.
class ProfilePage extends StatelessWidget {
  final VoidCallback onWatchlistTap; // opens the Watchlist tab

  const ProfilePage({super.key, required this.onWatchlistTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        // numbers are calculated from the saved watchlist
        final int savedCount = state is WatchlistLoaded ? state.shows.length : 0;
        final int genreCount = state is WatchlistLoaded
            ? state.shows.expand((show) => show.genres).toSet().length
            : 0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'TV Explorer',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Center(
              child: Text(
                'Discover. Explore. Save.',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildStat('Saved shows', '$savedCount'),
                const SizedBox(width: 12),
                _buildStat('Genres', '$genreCount'),
              ],
            ),
            const SizedBox(height: 24),
            _buildOption(
              icon: Icons.favorite,
              text: 'My Watchlist',
              onTap: onWatchlistTap,
            ),
            _buildOption(
              icon: Icons.delete_outline,
              text: 'Clear watchlist',
              onTap: () => confirmClearWatchlist(context),
            ),
            _buildOption(
              icon: Icons.info_outline,
              text: 'About',
              onTap: () {
                showAboutDialog(
                  context: context,
                  useRootNavigator: false,
                  applicationName: 'TV Explorer',
                  applicationVersion: '1.0.0',
                  children: const [
                    Text('Built with Flutter, BLoC and the TVMaze API.'),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: AppColors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(text),
          trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}
