import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/show_model.dart';
import '../bloc/watchlist/watchlist_bloc.dart';
import '../bloc/watchlist/watchlist_event.dart';
import '../bloc/watchlist/watchlist_state.dart';
import 'app_colors.dart';
import 'widgets/clear_watchlist_dialog.dart';
import 'widgets/error_view.dart';
import 'widgets/open_show.dart';
import 'widgets/show_tile.dart';

// "Watchlist" tab: shows saved by the user (kept after restarting the app).
class WatchlistPage extends StatelessWidget {
  final VoidCallback onExploreTap; // goes back to the Home tab

  const WatchlistPage({super.key, required this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        if (state is WatchlistError) {
          return Column(
            children: [
              _buildHeader(context, showActions: false),
              Expanded(
                child: ErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<WatchlistBloc>()
                      .add(const WatchlistStarted()),
                ),
              ),
            ],
          );
        }

        if (state is WatchlistLoaded) {
          return Column(
            children: [
              _buildHeader(context, showActions: state.shows.isNotEmpty),
              Expanded(
                child: state.shows.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.shows.length,
                        itemBuilder: (context, index) {
                          return _buildItem(context, state.shows[index]);
                        },
                      ),
              ),
            ],
          );
        }

        // WatchlistLoading
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // Title + trash icon (clear all) + 3 dots menu (sort)
  Widget _buildHeader(BuildContext context, {required bool showActions}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'My Watchlist',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          if (showActions) ...[
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => confirmClearWatchlist(context),
            ),
            PopupMenuButton<WatchlistSort>(
              icon: const Icon(Icons.more_vert),
              onSelected: (sort) {
                context.read<WatchlistBloc>().add(WatchlistSorted(sort));
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: WatchlistSort.name,
                  child: Text('Sort by name (A-Z)'),
                ),
                PopupMenuItem(
                  value: WatchlistSort.rating,
                  child: Text('Sort by rating'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // One saved show: red heart (remove) + 3 dots menu
  Widget _buildItem(BuildContext context, Show show) {
    return ShowTile(
      show: show,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              context.read<WatchlistBloc>().add(WatchlistToggled(show));
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.grey),
            onSelected: (value) {
              if (value == 'details') {
                selectShow(context, show);
              } else {
                context.read<WatchlistBloc>().add(WatchlistToggled(show));
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'details', child: Text('View details')),
              PopupMenuItem(value: 'remove', child: Text('Remove')),
            ],
          ),
        ],
      ),
    );
  }

  // Empty state: shown when nothing is saved yet.
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, size: 36, color: AppColors.primary),
            const Icon(Icons.inventory_2, size: 110, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Your watchlist is empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Discover amazing shows and save them here to watch later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              onPressed: onExploreTap,
              child: const Text('Explore Shows'),
            ),
          ],
        ),
      ),
    );
  }
}
