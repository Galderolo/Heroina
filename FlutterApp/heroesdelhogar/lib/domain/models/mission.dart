enum MissionType {
  diaria,
  ayuda,
  epica;

  String get displayName {
    switch (this) {
      case MissionType.diaria:
        return 'Diaria';
      case MissionType.ayuda:
        return 'Ayuda';
      case MissionType.epica:
        return 'Epica';
    }
  }

  static MissionType fromString(String value) {
    switch (value) {
      case 'diaria':
        return MissionType.diaria;
      case 'ayuda':
        return MissionType.ayuda;
      case 'epica':
        return MissionType.epica;
      default:
        return MissionType.diaria;
    }
  }
}

class Mission {
  final int id;
  final String name;
  final String description;
  final MissionType type;
  final int xp;
  final int gold;
  final String icon;
  final bool repeatable;
  final bool isCustom;

  const Mission({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.xp,
    required this.gold,
    required this.icon,
    this.repeatable = true,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.name,
        'xp': xp,
        'gold': gold,
        'icon': icon,
        'repeatable': repeatable,
        'isCustom': isCustom,
      };

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      type: MissionType.fromString(json['type'] as String),
      xp: (json['xp'] as num).toInt(),
      gold: (json['gold'] as num).toInt(),
      icon: json['icon'] as String,
      repeatable: (json['repeatable'] as bool?) ?? true,
      isCustom: (json['isCustom'] as bool?) ?? false,
    );
  }
}

class ActiveMission {
  final int missionId;
  final String name;
  final String icon;
  final DateTime startDate;

  const ActiveMission({
    required this.missionId,
    required this.name,
    required this.icon,
    required this.startDate,
  });

  Map<String, dynamic> toJson() => {
        'missionId': missionId,
        'name': name,
        'icon': icon,
        'startDate': startDate.toIso8601String(),
      };

  factory ActiveMission.fromJson(Map<String, dynamic> json) {
    return ActiveMission(
      missionId: (json['missionId'] as num).toInt(),
      name: json['name'] as String,
      icon: json['icon'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
    );
  }

  double get hoursElapsed {
    return DateTime.now().difference(startDate).inMinutes / 60.0;
  }

  bool get isExpired => hoursElapsed >= 12;
}

class CompletedMissionRecord {
  final int missionId;
  final DateTime date;
  final int xpGained;
  final int goldGained;

  const CompletedMissionRecord({
    required this.missionId,
    required this.date,
    required this.xpGained,
    required this.goldGained,
  });

  Map<String, dynamic> toJson() => {
        'missionId': missionId,
        'date': date.toIso8601String(),
        'xpGained': xpGained,
        'goldGained': goldGained,
      };

  factory CompletedMissionRecord.fromJson(Map<String, dynamic> json) {
    return CompletedMissionRecord(
      missionId: (json['missionId'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      xpGained: (json['xpGained'] as num).toInt(),
      goldGained: (json['goldGained'] as num).toInt(),
    );
  }
}
