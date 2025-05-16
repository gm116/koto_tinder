class Cat {
  final String url;
  final String breedName;
  final String origin;
  final String temperament;
  final String description;
  final String lifeSpan;
  final int energyLevel;
  final int intelligence;
  final int childFriendly;
  final int dogFriendly;
  final int sheddingLevel;
  final bool hypoallergenic;
  final DateTime? likedAt;

  Cat({
    required this.url,
    required this.breedName,
    required this.origin,
    required this.temperament,
    required this.description,
    required this.lifeSpan,
    required this.energyLevel,
    required this.intelligence,
    required this.childFriendly,
    required this.dogFriendly,
    required this.sheddingLevel,
    required this.hypoallergenic,
    this.likedAt,
  });

  Cat copyWith({DateTime? likedAt}) {
    return Cat(
      url: url,
      breedName: breedName,
      origin: origin,
      temperament: temperament,
      description: description,
      lifeSpan: lifeSpan,
      energyLevel: energyLevel,
      intelligence: intelligence,
      childFriendly: childFriendly,
      dogFriendly: dogFriendly,
      sheddingLevel: sheddingLevel,
      hypoallergenic: hypoallergenic,
      likedAt: likedAt ?? this.likedAt,
    );
  }

  factory Cat.fromMap(Map<String, dynamic> map) {
    return Cat(
      url: map['url'] ?? '',
      breedName: map['breedName'] ?? 'Unknown',
      origin: map['origin'] ?? 'Unknown',
      temperament: map['temperament'] ?? 'Unknown',
      description: map['description'] ?? 'No description available',
      lifeSpan: map['lifeSpan'] ?? 'Unknown',
      energyLevel: map['energyLevel'] ?? 0,
      intelligence: map['intelligence'] ?? 0,
      childFriendly: map['childFriendly'] ?? 0,
      dogFriendly: map['dogFriendly'] ?? 0,
      sheddingLevel: map['sheddingLevel'] ?? 0,
      hypoallergenic: map['hypoallergenic'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'breedName': breedName,
      'origin': origin,
      'temperament': temperament,
      'description': description,
      'lifeSpan': lifeSpan,
      'energyLevel': energyLevel,
      'intelligence': intelligence,
      'childFriendly': childFriendly,
      'dogFriendly': dogFriendly,
      'sheddingLevel': sheddingLevel,
      'hypoallergenic': hypoallergenic,
      'likedAt': likedAt?.toIso8601String(),
    };
  }
}
