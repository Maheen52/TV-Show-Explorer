// All TVMaze API calls are written here (NOT inside the UI widgets).
// The BLoCs call these methods and the UI only listens to BLoC states.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/cast_model.dart';
import '../data/episode_model.dart';
import '../data/person_model.dart';
import '../data/show_model.dart';

class TvMazeApi {
  static const String _baseUrl = 'https://api.tvmaze.com';

  // GET /shows?page=0  -> 250 shows per page (used for pagination)
  Future<List<Show>> getShows(int page) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/shows?page=$page'))
        .timeout(const Duration(seconds: 15));

    // The API returns 404 when there are no more pages.
    if (response.statusCode == 404) {
      return [];
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to load shows (code ${response.statusCode})');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((json) => Show.fromJson(json)).toList();
  }

  // GET /search/shows?q=girls  -> each item looks like { score: 0.9, show: {...} }
  Future<List<Show>> searchShows(String query) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/search/shows?q=${Uri.encodeQueryComponent(query)}'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Search failed (code ${response.statusCode})');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((item) => Show.fromJson(item['show'])).toList();
  }

  // GET /search/people?q=bryan  -> each item looks like { score: 0.9, person: {...} }
  Future<List<Person>> searchPeople(String query) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/search/people?q=${Uri.encodeQueryComponent(query)}'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Search failed (code ${response.statusCode})');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((item) => Person.fromJson(item['person'])).toList();
  }

  // GET /shows/82  -> full details of one show
  Future<Show> getShowDetails(int showId) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/shows/$showId'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to load show (code ${response.statusCode})');
    }

    return Show.fromJson(jsonDecode(response.body));
  }

  // GET /shows/1/cast
  Future<List<CastMember>> getCast(int showId) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/shows/$showId/cast'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to load cast (code ${response.statusCode})');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((json) => CastMember.fromJson(json)).toList();
  }

  // GET /shows/1/episodes
  Future<List<Episode>> getEpisodes(int showId) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/shows/$showId/episodes'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to load episodes (code ${response.statusCode})');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((json) => Episode.fromJson(json)).toList();
  }
}
