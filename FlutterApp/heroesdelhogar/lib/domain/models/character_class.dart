class CharacterClass {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int lives;
  final int maxLives;
  final int energy;
  final int maxEnergy;

  const CharacterClass({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.lives,
    required this.maxLives,
    required this.energy,
    required this.maxEnergy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'lives': lives,
        'maxLives': maxLives,
        'energy': energy,
        'maxEnergy': maxEnergy,
      };

  factory CharacterClass.fromJson(Map<String, dynamic> json) {
    return CharacterClass(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      lives: json['lives'] as int,
      maxLives: json['maxLives'] as int,
      energy: json['energy'] as int,
      maxEnergy: json['maxEnergy'] as int,
    );
  }
}
