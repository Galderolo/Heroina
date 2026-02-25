class Character {
  final String name;
  final String? avatar;
  final String gender;
  final String classId;
  final int level;
  final int xp;
  final int gold;
  final int energy;
  final int maxEnergy;
  final int lives;
  final int maxLives;

  const Character({
    this.name = '',
    this.avatar,
    this.gender = '',
    this.classId = '',
    this.level = 1,
    this.xp = 0,
    this.gold = 0,
    this.energy = 6,
    this.maxEnergy = 6,
    this.lives = 6,
    this.maxLives = 6,
  });

  Character copyWith({
    String? name,
    String? avatar,
    String? gender,
    String? classId,
    int? level,
    int? xp,
    int? gold,
    int? energy,
    int? maxEnergy,
    int? lives,
    int? maxLives,
  }) {
    return Character(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      gender: gender ?? this.gender,
      classId: classId ?? this.classId,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      gold: gold ?? this.gold,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatar': avatar,
        'gender': gender,
        'class': classId,
        'level': level,
        'xp': xp,
        'gold': gold,
        'energy': energy,
        'maxEnergy': maxEnergy,
        'lives': lives,
        'maxLives': maxLives,
      };

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: (json['name'] as String?) ?? '',
      avatar: json['avatar'] as String?,
      gender: (json['gender'] as String?) ?? '',
      classId: (json['class'] as String?) ?? '',
      level: (json['level'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      gold: (json['gold'] as num?)?.toInt() ?? 0,
      energy: (json['energy'] as num?)?.toInt() ?? 6,
      maxEnergy: (json['maxEnergy'] as num?)?.toInt() ?? 6,
      lives: (json['lives'] as num?)?.toInt() ?? 6,
      maxLives: (json['maxLives'] as num?)?.toInt() ?? 6,
    );
  }
}
