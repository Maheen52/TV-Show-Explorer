import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/show_model.dart';
import '../../bloc/selected_show/selected_show_bloc.dart';
import '../../bloc/selected_show/selected_show_state.dart';
import '../../bloc/show_list/show_list_bloc.dart';
import '../../bloc/show_list/show_list_event.dart';
import '../../bloc/show_list/show_list_state.dart';
import 'error_view.dart';

// Gives the builder the show that is selected right now.
// If the user has not tapped any show yet, the best rated loaded show is used.
class SelectedShowBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Show show) builder;

  const SelectedShowBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedShowBloc, SelectedShowState>(
      builder: (context, selected) {
        if (selected.show != null) {
          return builder(context, selected.show!);
        }

        // nothing tapped yet -> look at the loaded shows
        return BlocBuilder<ShowListBloc, ShowListState>(
          builder: (context, listState) {
            if (listState is ShowListError) {
              return ErrorView(
                message: listState.message,
                onRetry: () =>
                    context.read<ShowListBloc>().add(const ShowsFetched()),
              );
            }

            if (listState is ShowListLoaded && listState.trending.isNotEmpty) {
              return builder(context, listState.trending.first);
            }

            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}
