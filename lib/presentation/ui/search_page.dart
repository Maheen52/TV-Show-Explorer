import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/person_model.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/search/search_event.dart';
import '../bloc/search/search_state.dart';
import 'app_colors.dart';
import 'widgets/error_view.dart';
import 'widgets/message_view.dart';
import 'widgets/person_sheet.dart';
import 'widgets/person_tile.dart';
import 'widgets/show_tile.dart';

// "Search" tab: text field, Shows / People switch and results.
// The BLoC waits 500 ms (debounce) before calling the API.
class SearchPage extends StatefulWidget {
  final String? initialQuery; // optional text to search when the page opens

  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isPeople = false; // ephemeral state: which switch is selected

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _controller.text = widget.initialQuery!;
      // start the search after the first build
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // send the current text + selected switch to the BLoC
  void _search() {
    context
        .read<SearchBloc>()
        .add(SearchQueryChanged(_controller.text, isPeople: _isPeople));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search shows...',
              filled: true,
              fillColor: AppColors.card,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  _controller.clear();
                  _search();
                },
              ),
            ),
            // runs every time a letter is typed
            onChanged: (text) => _search(),
          ),
        ),

        // Shows | People switch
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildSwitchButton('Shows', !_isPeople, () {
                  setState(() {
                    _isPeople = false;
                  });
                  _search();
                }),
                _buildSwitchButton('People', _isPeople, () {
                  setState(() {
                    _isPeople = true;
                  });
                  _search();
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SearchEmpty) {
                return MessageView(
                  icon: Icons.search_off,
                  message: 'No results found for "${state.query}"',
                );
              }

              if (state is SearchError) {
                return ErrorView(message: state.message, onRetry: _search);
              }

              if (state is SearchLoaded) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.shows.length,
                  itemBuilder: (context, index) {
                    return ShowTile(show: state.shows[index]);
                  },
                );
              }

              if (state is SearchPeopleLoaded) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.people.length,
                  itemBuilder: (context, index) {
                    final Person person = state.people[index];
                    return PersonTile(
                      imageUrl: person.imageUrl,
                      name: person.name,
                      subtitle: person.country ?? 'Unknown country',
                      onTap: () => showPersonSheet(
                        context,
                        name: person.name,
                        imageUrl: person.imageUrl,
                        country: person.country,
                        birthday: person.birthday,
                      ),
                    );
                  },
                );
              }

              // SearchInitial: nothing typed yet
              return MessageView(
                icon: Icons.search,
                message: _isPeople
                    ? 'Type a name to search people'
                    : 'Type a show name to search',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchButton(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
