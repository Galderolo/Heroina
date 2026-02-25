import '../constants/game_data.dart';
import '../../domain/models/character_class.dart';
import '../../domain/models/mission.dart';
import '../../domain/models/reward.dart';

/// XP necesaria para subir del nivel [level] al siguiente.
int calculateXPForLevel(int level) => 5 + level * 5;

/// Titulo correspondiente al nivel [level].
String getTitleByLevel(int level) {
  for (final t in kTitles) {
    if (t.level == level) return t.title;
  }
  return kTitles.first.title;
}

/// Recompensas desbloqueadas para el nivel [level].
List<Reward> getUnlockedRewards(int level, [List<Reward>? rewards]) {
  final allRewards = rewards ?? kRewards;
  return allRewards.where((r) => r.requiredLevel <= level).toList();
}

/// Valores estandar de XP y oro para misiones personalizadas.
({int xp, int gold}) getStandardMissionValues(MissionType type) {
  switch (type) {
    case MissionType.diaria:
      return (xp: 3, gold: 20);
    case MissionType.ayuda:
      return (xp: 5, gold: 30);
    case MissionType.epica:
      return (xp: 12, gold: 75);
  }
}

/// Precio estandar para recompensas personalizadas.
int getStandardRewardPrice(RewardCategory category) {
  switch (category) {
    case RewardCategory.pequena:
      return 60;
    case RewardCategory.media:
      return 220;
    case RewardCategory.grande:
      return 400;
    case RewardCategory.epica:
      return 600;
    case RewardCategory.potion:
      return 100;
  }
}

/// Combina misiones base + personalizadas.
List<Mission> getAllMissions([List<Mission> customMissions = const []]) {
  return [...kMissions, ...customMissions];
}

/// Combina recompensas base + personalizadas.
List<Reward> getAllRewards([List<Reward> customRewards = const []]) {
  return [...kRewards, ...customRewards];
}

/// Busca una clase por ID.
CharacterClass? getClassById(String classId) {
  for (final c in kClasses) {
    if (c.id == classId) return c;
  }
  return null;
}

/// Comprueba si se puede subir de nivel.
({bool leveledUp, int newLevel}) checkLevelUp(int currentLevel, int currentXP) {
  final requiredXP = calculateXPForLevel(currentLevel);
  if (currentXP >= requiredXP) {
    return (leveledUp: true, newLevel: currentLevel + 1);
  }
  return (leveledUp: false, newLevel: currentLevel);
}
