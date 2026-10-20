import 'show_model.dart';

// Model class for one episode of a show.

class Episode {
  final int id;
  final String name;
  final int season;
  final int? number;
  final String? airdate;
  final double? rating;
  final String? imageUrl;
  final String summary;
  final int? runtime; // minutes

  const Episode({
    required this.id,
    required this.name,
    required this.season,
    this.number,
    this.airdate,
    this.rating,
    this.imageUrl,
    this.summary = '',
    this.runtime,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    final ratingMap = json['rating'] as Map<String, dynamic>?;
    final image = json['image'] as Map<String, dynamic>?;

    return Episode(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Untitled',
      season: json['season'] as int? ?? 0,
      number: json['number'] as int?,
      airdate: json['airdate'] as String?,
      rating: (ratingMap?['average'] as num?)?.toDouble(),
      imageUrl: (image?['medium'] as String?)?.replaceFirst('http://', 'https://'),
      summary: removeHtmlTags(json['summary'] as String? ?? ''),
      runtime: json['runtime'] as int?,
    );
  }
}
