import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../bloc/watchlist/watchlist_event.dart';

// Asks "are you sure?" and clears the whole watchlist if the user says yes.
// Used by the trash icon (Watchlist tab) and by the Profile tab.
void confirmClearWatchlist(BuildContext context) {
  final bloc = context.read<WatchlistBloc>();

  showDialog<bool>(
    context: context,
    useRootNavigator: false, // stay inside the phone frame
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Clear watchlist?'),
        content: const Text('All saved shows will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  ).then((confirmed) {
    if (confirmed == true) {
      bloc.add(const WatchlistCleared());
    }
  });
}
