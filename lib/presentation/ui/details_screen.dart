import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/episode_model.dart';
import '../../data/show_model.dart';
import '../bloc/details/details_bloc.dart';
import '../bloc/details/details_event.dart';
import '../bloc/details/details_state.dart';
import '../bloc/show_list/show_list_bloc.dart';
import '../bloc/show_list/show_list_state.dart';
import '../bloc/watchlist/watchlist_bloc.dart';
import '../bloc/watchlist/watchlist_event.dart';
import '../bloc/watchlist/watchlist_state.dart';
import 'app_colors.dart';
import 'widgets/error_view.dart';
import 'widgets/message_view.dart';
import 'widgets/person_sheet.dart';
import 'widgets/person_tile.dart';
import 'widgets/poster_image.dart';
import 'widgets/rating_text.dart';
import 'widgets/selected_show_builder.dart';
import 'widgets/show_tile.dart';

// Details screen. It shows the selected show (see SelectedShowBloc).
// Show details, cast and episodes are loaded by DetailsBloc.
// initialTab: 0 Overview (screen 3), 1 Episodes (screen 4), 2 Cast (screen 5)
class DetailsScreen extends StatelessWidget {
  final int initialTab;

  const DetailsScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return SelectedShowBuilder(
      builder: (context, show) {
        // a new DetailsBloc is created every time another show is selected
        return BlocProvider(
          key: ValueKey(show.id),
          create: (_) => DetailsBloc()..add(DetailsRequested(show.id)),
          child: _DetailsView(
            key: ValueKey(show.id),
            show: show,
            initialTab: initialTab,
          ),
        );
      },
    );
  }
}

class _DetailsView extends StatefulWidget {
  final Show show;
  final int initialTab;

  const _DetailsView({super.key, required this.show, required this.initialTab});

  @override
  State<_DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<_DetailsView> {
  // ephemeral state (only this screen needs it) -> setState
  final ScrollController _scrollController = ScrollController();
  bool _collapsed = false; // true when the big poster is scrolled away
  late int _tabIndex = widget.initialTab; // 0 Overview, 1 Episodes, 2 Cast, 3 Similar
  int? _selectedSeason; // season chosen in the dropdown

  Show get show => widget.show;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final bool collapsed = _scrollController.offset > 300;
      if (collapsed != _collapsed) {
        setState(() {
          _collapsed = collapsed;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Add or remove the show, then show a small message.
  void _toggleWatchlist(BuildContext context, bool isSaved) {
    context.read<WatchlistBloc>().add(WatchlistToggled(show));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSaved ? 'Removed from watchlist' : 'Added to watchlist'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Switch between the tabs. Overview = big poster page (screen 3),
  // Episodes / Cast / Similar = compact page (screens 4 and 5).
  void _changeTab(int index) {
    setState(() {
      _tabIndex = index;
      _collapsed = false;
    });
  }

  Widget _buildTabBar() {
    return TabBar(
      labelColor: Colors.white,
      unselectedLabelColor: AppColors.grey,
      indicatorColor: AppColors.primary,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 13),
      onTap: _changeTab,
      tabs: const [
        Tab(text: 'Overview'),
        Tab(text: 'Episodes'),
        Tab(text: 'Cast'),
        Tab(text: 'Similar'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: _tabIndex,
      child: _tabIndex == 0 ? _buildOverviewPage() : _buildCompactPage(),
    );
  }

  // ---------------- Screen 3: Overview (big poster) ----------------

  Widget _buildOverviewPage() {
    return Scaffold(
      // CustomScrollView = big poster app bar, info, sticky tabs, content
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildInfoRow(),
                  const SizedBox(height: 12),
                  if (show.genres.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: show.genres
                          .map((g) => Chip(
                                label: Text(g),
                                backgroundColor: AppColors.card,
                                side: BorderSide.none,
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    show.summary.isEmpty
                        ? 'No summary available.'
                        : show.summary,
                    style: const TextStyle(color: AppColors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  _buildWatchlistButton(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // tabs stay at the top when the page is scrolled
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(tabBar: _buildTabBar()),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Screens 4 and 5: Episodes / Cast / Similar ----------------

  Widget _buildCompactPage() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text(show.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [_buildHeart(circle: false)],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [_buildTabContent()],
            ),
          ),
        ],
      ),
    );
  }

  // Heart button: add / remove from watchlist
  Widget _buildHeart({required bool circle}) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        final bool isSaved = state is WatchlistLoaded &&
            state.shows.any((s) => s.id == show.id);

        final button = IconButton(
          icon: Icon(
            isSaved ? Icons.favorite : Icons.favorite_border,
            color: isSaved ? Colors.red : Colors.white,
          ),
          onPressed: () => _toggleWatchlist(context, isSaved),
        );

        if (!circle) return button;

        return Padding(
          padding: const EdgeInsets.all(6),
          child: CircleAvatar(backgroundColor: Colors.black45, child: button),
        );
      },
    );
  }

  // ---------------- App bar (big poster, back button, heart) ----------------

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 380,
      backgroundColor: AppColors.background,
      centerTitle: true,
      // the show name appears in the bar only after the poster is scrolled away
      title: AnimatedOpacity(
        opacity: _collapsed ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Text(show.name),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(6),
        child: CircleAvatar(
          backgroundColor: Colors.black45,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
      ),
      actions: [
        _buildHeart(circle: true),
        const SizedBox(width: 6),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PosterImage(url: show.largeImageUrl ?? show.imageUrl),
            // dark gradient so the title is readable
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black38,
                    Colors.transparent,
                    AppColors.background,
                  ],
                  stops: [0, 0.4, 1],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 8,
              child: Text(
                show.name,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // years, number of seasons (known after episodes are loaded), rating
  Widget _buildInfoRow() {
    return BlocBuilder<DetailsBloc, DetailsState>(
      builder: (context, state) {
        final int seasons =
            state is DetailsLoaded ? state.episodesBySeason.length : 0;

        return Wrap(
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (show.years.isNotEmpty) Text(show.years),
            if (seasons > 0) Text('$seasons Seasons'),
            RatingText(rating: show.rating, suffix: '/10'),
          ],
        );
      },
    );
  }

  // Purple button: changes between "Add" and "Remove"
  Widget _buildWatchlistButton() {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        final bool isSaved = state is WatchlistLoaded &&
            state.shows.any((s) => s.id == show.id);

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _toggleWatchlist(context, isSaved),
            icon: Icon(isSaved ? Icons.remove : Icons.add),
            label: Text(isSaved ? 'Remove from Watchlist' : 'Add to Watchlist'),
          ),
        );
      },
    );
  }

  // ---------------- Tab content ----------------

  Widget _buildTabContent() {
    // Similar tab: uses the shows already loaded by ShowListBloc
    if (_tabIndex == 3) {
      return BlocBuilder<ShowListBloc, ShowListState>(
        builder: (context, state) {
          final List<Show> similar =
              state is ShowListLoaded ? state.similarTo(show) : [];

          if (similar.isEmpty) {
            return const MessageView(
              icon: Icons.tv_off,
              message: 'No similar shows found.',
            );
          }
          return Column(
            children: similar.map((s) => ShowTile(show: s)).toList(),
          );
        },
      );
    }

    // Overview, Episodes and Cast come from DetailsBloc
    return BlocBuilder<DetailsBloc, DetailsState>(
      builder: (context, state) {
        // Overview: uses the show from the list until the full details load
        if (_tabIndex == 0) {
          return _buildOverview(state is DetailsLoaded ? state.show : show);
        }

        if (state is DetailsError) {
          return ErrorView(
            message: state.message,
            onRetry: () =>
                context.read<DetailsBloc>().add(DetailsRequested(show.id)),
          );
        }

        if (state is DetailsLoaded) {
          return _tabIndex == 1 ? _buildEpisodes(state) : _buildCast(state);
        }

        // DetailsInitial / DetailsLoading
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildOverview(Show details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Info',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              _infoRow(Icons.radio_button_checked, 'Status',
                  details.status ?? 'N/A'),
              const Divider(height: 1, color: Colors.white12),
              _infoRow(Icons.tv, 'Network', details.network ?? 'N/A'),
              const Divider(height: 1, color: Colors.white12),
              _infoRow(
                  Icons.theater_comedy,
                  'Genres',
                  details.genres.isEmpty ? 'N/A' : details.genres.join(', ')),
              const Divider(height: 1, color: Colors.white12),
              _infoRow(Icons.language, 'Language', details.language ?? 'N/A'),
              const Divider(height: 1, color: Colors.white12),
              _infoRow(Icons.calendar_month, 'Premiered',
                  details.premiered ?? 'N/A'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.grey),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.grey)),
          const SizedBox(width: 16),
          Expanded(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // Episodes grouped by season: choose a season in the dropdown.
  Widget _buildEpisodes(DetailsLoaded state) {
    // season numbers in order: 1, 2, 3 ...
    final seasons = state.episodesBySeason.keys.toList()..sort();

    if (seasons.isEmpty) {
      return const MessageView(
        icon: Icons.video_library,
        message: 'No episodes available.',
      );
    }

    final int selected =
        seasons.contains(_selectedSeason) ? _selectedSeason! : seasons.first;
    final episodes = state.episodesBySeason[selected]!;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButton<int>(
            value: selected,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppColors.card,
            items: seasons.map((season) {
              final int count = state.episodesBySeason[season]!.length;
              return DropdownMenuItem(
                value: season,
                child: Text('Season $season ($count episodes)'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSeason = value;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        ...episodes.map((episode) => _buildEpisodeRow(episode)),
      ],
    );
  }

  Widget _buildEpisodeRow(Episode episode) {
    return InkWell(
      onTap: () => _showEpisodeSheet(episode),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // episode picture with the episode number on top
            SizedBox(
              width: 100,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PosterImage(url: episode.imageUrl),
                    Center(
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black54,
                        child: Text(
                          '${episode.number ?? '-'}',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    episode.airdate ?? 'Unknown date',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            // play button (opens the episode information)
            IconButton(
              icon: const Icon(Icons.play_circle_outline, size: 32),
              onPressed: () => _showEpisodeSheet(episode),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom sheet with episode information
  void _showEpisodeSheet(Episode episode) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false, // stay inside the phone frame
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'S${episode.season} • E${episode.number ?? '-'}',
                style: const TextStyle(color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                episode.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${episode.airdate ?? 'Unknown date'}'
                '${episode.runtime == null ? '' : '  •  ${episode.runtime} min'}',
                style: const TextStyle(color: AppColors.grey),
              ),
              const SizedBox(height: 12),
              Text(episode.summary.isEmpty
                  ? 'No summary available.'
                  : episode.summary),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCast(DetailsLoaded state) {
    if (state.cast.isEmpty) {
      return const MessageView(
        icon: Icons.people_outline,
        message: 'No cast information available.',
      );
    }

    return Column(
      children: state.cast.map((member) {
        return PersonTile(
          imageUrl: member.imageUrl,
          name: member.personName,
          subtitle: member.characterName,
          onTap: () => showPersonSheet(
            context,
            name: member.personName,
            imageUrl: member.imageUrl,
            subtitle: 'as ${member.characterName}',
            country: member.country,
            birthday: member.birthday,
          ),
        );
      }).toList(),
    );
  }
}

// Tab bar that stays at the top (pinned) while the page scrolls.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _TabBarDelegate({required this.tabBar});

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.background, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => true;
}
