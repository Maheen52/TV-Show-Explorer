// Saves the watchlist on the phone using SharedPreferences,
// so the shows are still there after the app is restarted.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/show_model.dart';

class WatchlistStorage {
  static const String _key = 'watchlist';

  Future<List<Show>> loadShows() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList(_key) ?? [];

    // every saved item is a JSON string -> decode -> Show object
    return savedList.map((item) => Show.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveShows(List<Show> shows) async {
    final prefs = await SharedPreferences.getInstance();

    // every Show -> Map -> JSON string
    final stringList = shows.map((show) => jsonEncode(show.toJson())).toList();
    await prefs.setStringList(_key, stringList);
  }
}
