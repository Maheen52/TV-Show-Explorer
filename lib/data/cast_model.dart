// Model class for one cast member (actor + the character he/she plays).

class CastMember {
  final String personName;
  final String characterName;
  final String? imageUrl;
  final String? country;
  final String? birthday;

  const CastMember({
    required this.personName,
    required this.characterName,
    this.imageUrl,
    this.country,
    this.birthday,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>? ?? {};
    final character = json['character'] as Map<String, dynamic>? ?? {};
    final image = person['image'] as Map<String, dynamic>?;
    final country = person['country'] as Map<String, dynamic>?;

    return CastMember(
      personName: person['name'] as String? ?? 'Unknown',
      characterName: character['name'] as String? ?? '',
      imageUrl: (image?['medium'] as String?)?.replaceFirst('http://', 'https://'),
      country: country?['name'] as String?,
      birthday: person['birthday'] as String?,
    );
  }
}
