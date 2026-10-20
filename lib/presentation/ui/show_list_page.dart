import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/show_list/show_list_bloc.dart';
import '../bloc/show_list/show_list_event.dart';
import '../bloc/show_list/show_list_state.dart';
import 'app_colors.dart';
import 'app_routes.dart';
import 'widgets/error_view.dart';
import 'widgets/message_view.dart';
import 'widgets/section_header.dart';
import 'widgets/show_card.dart';

// "Home" tab: greeting, search bar, "Trending Now" and "Popular Shows".
// Pagination: when the user scrolls the Popular Shows row to the end,
// the next page of shows is loaded.
class ShowListPage extends StatefulWidget {
  final VoidCallback onSearchTap; // opens the Search tab
  final VoidCallback onSettingsTap; // opens the Profile tab

  const ShowListPage({
    super.key,
    required this.onSearchTap,
    required this.onSettingsTap,
  });

  @override
  State<ShowListPage> createState() => _ShowListPageState();
}

class _ShowListPageState extends State<ShowListPage> {
  final ScrollController _popularController = ScrollController();

  @override
  void initState() {
    super.initState();
    _popularController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _popularController.dispose();
    super.dispose();
  }

  // When the user is near the end of the row, ask the BLoC for the next page.
  void _onScroll() {
    final position = _popularController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<ShowListBloc>().add(const ShowsFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShowListBloc, ShowListState>(
      builder: (context, state) {
        if (state is ShowListInitial || state is ShowListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ShowListError) {
          return ErrorView(
            message: state.message,
            onRetry: () =>
                context.read<ShowListBloc>().add(const ShowsFetched()),
          );
        }

        if (state is ShowListLoaded) {
          if (state.shows.isEmpty) {
            return const MessageView(
              icon: Icons.tv_off,
              message: 'No shows found.',
            );
          }
          return _buildContent(state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildContent(ShowListLoaded state) {
    final trending = state.trending;
    // extra item at the end of the row: spinner (loading) or retry button
    final bool hasFooter = state.isLoadingMore || state.loadMoreFailed;

    return ListView(
      children: [
        _buildHeader(),

        // ---------- Trending Now ----------
        SectionHeader(
          title: 'Trending Now',
          onSeeAll: () =>
              Navigator.pushNamed(context, AppRoutes.seeAll, arguments: 'trending'),
        ),
        SizedBox(
          height: 225,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: trending.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 112,
                  child: ShowCard(show: trending[index]),
                ),
              );
            },
          ),
        ),

        // ---------- Popular Shows (with pagination) ----------
        SectionHeader(
          title: 'Popular Shows',
          onSeeAll: () =>
              Navigator.pushNamed(context, AppRoutes.seeAll, arguments: 'popular'),
        ),
        SizedBox(
          height: 225,
          child: ListView.builder(
            controller: _popularController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.shows.length + (hasFooter ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.shows.length) {
                return SizedBox(
                  width: 60,
                  child: Center(
                    child: state.loadMoreFailed
                        ? IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => context
                                .read<ShowListBloc>()
                                .add(const ShowsFetched()),
                          )
                        : const CircularProgressIndicator(),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 112,
                  child: ShowCard(show: state.shows[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello,', style: TextStyle(fontSize: 18)),
                  Text(
                    'TV Explorer! 👋',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // settings button (opens the Profile tab)
              CircleAvatar(
                backgroundColor: AppColors.card,
                child: IconButton(
                  icon: const Icon(Icons.settings, size: 20),
                  onPressed: widget.onSettingsTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // looks like a search bar, tapping it opens the Search tab
          Material(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onSearchTap,
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.grey),
                    SizedBox(width: 10),
                    Text('Search shows...',
                        style: TextStyle(color: AppColors.grey)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
