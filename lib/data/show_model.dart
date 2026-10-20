// Model class for a TV show.
// fromJson  -> converts the API's Map (JSON) into a Show object
// toJson    -> converts a Show back into a Map (used to save in SharedPreferences)

class Show {
  final int id;
  final String name;
  final String? imageUrl; // small poster (used in lists)
  final String? largeImageUrl; // big poster (used in details screen)
  final List<String> genres;
  final double? rating;
  final String summary;
  final String? premiered;
  final String? ended;
  final String? status;
  final String? network;
  final String? language;

  const Show({
    required this.id,
    required this.name,
    this.imageUrl,
    this.largeImageUrl,
    this.genres = const [],
    this.rating,
    this.summary = '',
    this.premiered,
    this.ended,
    this.status,
    this.network,
    this.language,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    // Some fields can be null in the API, so we check before using them.
    final image = json['image'] as Map<String, dynamic>?;
    final ratingMap = json['rating'] as Map<String, dynamic>?;
    final genreList = json['genres'] as List<dynamic>? ?? [];

    return Show(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      imageUrl: _toHttps(image?['medium'] as String?),
      largeImageUrl: _toHttps(image?['original'] as String?),
      genres: genreList.map((g) => g.toString()).toList(),
      rating: (ratingMap?['average'] as num?)?.toDouble(),
      summary: _removeHtmlTags(json['summary'] as String? ?? ''),
      premiered: json['premiered'] as String?,
      ended: json['ended'] as String?,
      status: json['status'] as String?,
      language: json['language'] as String?,
      // network (TV channel) or webChannel (Netflix etc.), one of them can be null
      network: _channelName(json['network']) ?? _channelName(json['webChannel']),
    );
  }

  // Same structure as the API, so fromJson can read it back.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genres': genres,
      'summary': summary,
      'premiered': premiered,
      'ended': ended,
      'status': status,
      'language': language,
      'network': network == null ? null : {'name': network},
      'rating': {'average': rating},
      'image': imageUrl == null
          ? null
          : {'medium': imageUrl, 'original': largeImageUrl},
    };
  }

  static String? _channelName(dynamic channel) {
    if (channel is Map<String, dynamic>) {
      return channel['name'] as String?;
    }
    return null;
  }

  // Example: "2008 - 2013", "2020 - Present" or "2015"
  String get years {
    if (premiered == null || premiered!.length < 4) return '';
    final start = premiered!.substring(0, 4);

    if (ended != null && ended!.length >= 4) {
      final end = ended!.substring(0, 4);
      return start == end ? start : '$start - $end';
    }
    return status == 'Running' ? '$start - Present' : start;
  }

  // API summary comes with HTML like <p><b>Text</b></p>. We remove the tags.
  static String _removeHtmlTags(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  // Android blocks http:// images by default, so we change them to https://
  static String? _toHttps(String? url) {
    return url?.replaceFirst('http://', 'https://');
  }
}

// Same as Show's html cleaner, used by other models (episode summary).
String removeHtmlTags(String text) => Show._removeHtmlTags(text);
