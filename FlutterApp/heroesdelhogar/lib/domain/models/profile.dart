class Profile {
  final String id;
  final String name;
  final String? avatar;
  final DateTime createdAt;
  final DateTime lastUsedAt;

  const Profile({
    required this.id,
    this.name = '',
    this.avatar,
    required this.createdAt,
    required this.lastUsedAt,
  });

  Profile copyWith({
    String? name,
    String? avatar,
    DateTime? lastUsedAt,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  bool get hasCharacter => name.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'createdAt': createdAt.toIso8601String(),
        'lastUsedAt': lastUsedAt.toIso8601String(),
      };

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? '',
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
    );
  }
}

class ProfileSummary {
  final int level;
  final String classId;
  final String title;
  final String? className;
  final String displayTitle;
  final String? avatar;

  const ProfileSummary({
    required this.level,
    required this.classId,
    required this.title,
    this.className,
    required this.displayTitle,
    this.avatar,
  });
}
