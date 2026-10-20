import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/show_list/show_list_bloc.dart';
import '../bloc/show_list/show_list_event.dart';
import '../bloc/show_list/show_list_state.dart';
import 'app_colors.dart';
import 'widgets/error_view.dart';
import 'widgets/show_card.dart';

// "See All" screen: grid of all loaded shows. Also has pagination
// (loads the next page when the user scrolls down).
// arguments: 'trending' (best rated first) or 'popular'
class SeeAllScreen extends StatefulWidget {
  const SeeAllScreen({super.key});

  @override
  State<SeeAllScreen> createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends State<SeeAllScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<ShowListBloc>().add(const ShowsFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    final String type = ModalRoute.of(context)!.settings.arguments as String;
    final bool isTrending = type == 'trending';

    // Responsive: more columns on wide screens (MediaQuery)
    final width = MediaQuery.of(context).size.width;
    final int columns = (width ~/ 120).clamp(3, 7).toInt();

    return Scaffold(
      appBar: AppBar(
        title: Text(isTrending ? 'Trending Now' : 'Popular Shows'),
        backgroundColor: AppColors.background,
      ),
      body: BlocBuilder<ShowListBloc, ShowListState>(
        builder: (context, state) {
          if (state is ShowListError) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ShowListBloc>().add(const ShowsFetched()),
            );
          }

          if (state is ShowListLoaded) {
            final shows = isTrending ? state.topRated : state.shows;

            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: 0.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: shows.length,
                    itemBuilder: (context, index) {
                      return ShowCard(show: shows[index]);
                    },
                  ),
                ),
                if (state.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                if (state.loadMoreFailed)
                  TextButton(
                    onPressed: () =>
                        context.read<ShowListBloc>().add(const ShowsFetched()),
                    child: const Text('Failed to load more. Tap to retry'),
                  ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
