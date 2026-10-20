// Model class for a person found with the "People" search.

class Person {
  final int id;
  final String name;
  final String? imageUrl;
  final String? country;
  final String? birthday;

  const Person({
    required this.id,
    required this.name,
    this.imageUrl,
    this.country,
    this.birthday,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    final country = json['country'] as Map<String, dynamic>?;

    return Person(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      imageUrl: (image?['medium'] as String?)?.replaceFirst('http://', 'https://'),
      country: country?['name'] as String?,
      birthday: json['birthday'] as String?,
    );
  }
}
