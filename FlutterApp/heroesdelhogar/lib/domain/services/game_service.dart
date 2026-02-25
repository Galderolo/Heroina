import 'dart:math';

import '../models/game_state.dart';
import '../models/mission.dart';
import '../models/reward.dart';
import '../models/profile.dart';
import '../repositories/game_repository.dart';
import '../repositories/profile_repository.dart';
import '../../core/constants/game_data.dart';
import '../../core/utils/game_calculations.dart';

/// Resultado generico de una operacion del juego.
class GameResult {
  final bool success;
  final String message;
  final Map<String, dynamic> data;

  const GameResult({
    required this.success,
    this.message = '',
    this.data = const {},
  });

  factory GameResult.ok([String message = '']) =>
      GameResult(success: true, message: message);

  factory GameResult.fail(String message) =>
      GameResult(success: false, message: message);
}

/// Estadisticas de hoy.
class TodayStats {
  final int missions;
  final int xp;
  final int gold;

  const TodayStats({this.missions = 0, this.xp = 0, this.gold = 0});
}

/// Informacion del timer de energia.
class EnergyTimerInfo {
  final bool isFull;
  final int minutesRemaining;
  final int secondsRemaining;

  const EnergyTimerInfo({
    this.isFull = true,
    this.minutesRemaining = 0,
    this.secondsRemaining = 0,
  });
}

/// Informacion de cooldown de recompensa.
class CooldownInfo {
  final bool onCooldown;
  final int hoursRemaining;
  final int minutesRemaining;

  const CooldownInfo({
    this.onCooldown = false,
    this.hoursRemaining = 0,
    this.minutesRemaining = 0,
  });
}

/// Servicio principal del juego.
/// Porta toda la logica de game.js.
class GameService {
  final GameRepository gameRepository;
  final ProfileRepository profileRepository;

  GameState _state = const GameState();

  GameService({
    required this.gameRepository,
    required this.profileRepository,
  });

  GameState get state => _state;

  // ===== Inicializacion =====

  Future<GameState> initialize() async {
    _state = await gameRepository.loadGameState();
    return _state;
  }

  Future<void> _save() async {
    await gameRepository.saveGameState(_state);
  }

  // ===== Perfiles =====

  Future<List<Profile>> listProfiles() => profileRepository.listProfiles();

  Future<String?> getActiveProfileId() =>
      profileRepository.getActiveProfileId();

  Future<bool> setActiveProfile(String profileId) async {
    final ok = await profileRepository.setActiveProfile(profileId);
    if (ok) await initialize();
    return ok;
  }

  Future<Profile> createProfile() => profileRepository.createProfile();

  Future<bool> deleteProfile(String profileId) =>
      profileRepository.deleteProfile(profileId);

  Future<ProfileSummary?> getProfileSummary(String profileId) async {
    final data = await profileRepository.getProfileData(profileId);
    if (data == null) return null;

    try {
      final character = data['character'] as Map<String, dynamic>?;
      if (character == null) return null;

      final level = (character['level'] as num?)?.toInt() ?? 1;
      final classId = (character['class'] as String?) ?? '';
      final classInfo = getClassById(classId);
      final title = getTitleByLevel(level);
      final displayTitle =
          classInfo != null ? '${classInfo.name} $title' : title;
      final avatar = character['avatar'] as String?;

      return ProfileSummary(
        level: level,
        classId: classId,
        title: title,
        className: classInfo?.name,
        displayTitle: displayTitle,
        avatar: avatar,
      );
    } catch (_) {
      return null;
    }
  }

  // ===== Personaje =====

  Future<void> createCharacterWithClass({
    required String name,
    required String classId,
    String? avatar,
    String gender = '',
  }) async {
    final selectedClass = getClassById(classId);
    if (selectedClass == null) return;

    _state = _state.copyWith(
      character: _state.character.copyWith(
        name: name,
        classId: classId,
        avatar: avatar,
        gender: gender,
        lives: selectedClass.lives,
        maxLives: selectedClass.maxLives,
        energy: selectedClass.energy,
        maxEnergy: selectedClass.maxEnergy,
      ),
      stats: _state.stats.copyWith(
        lastConnection: DateTime.now().toIso8601String(),
      ),
    );
    await _save();
  }

  Future<void> updateCharacterName(String name) async {
    _state = _state.copyWith(
      character: _state.character.copyWith(name: name),
    );
    await _save();
  }

  Future<void> updateCharacterAvatar(String avatarBase64) async {
    _state = _state.copyWith(
      character: _state.character.copyWith(avatar: avatarBase64),
    );
    await _save();
  }

  bool get hasCharacter => _state.character.name.trim().isNotEmpty;

  // ===== Misiones =====

  Future<List<Mission>> getAllMissionsResolved() async {
    final custom = await gameRepository.getCustomMissions();
    return getAllMissions(custom);
  }

  List<Mission> getMissionsByType(MissionType? type, List<Mission> all) {
    if (type == null) return all;
    return all.where((m) => m.type == type).toList();
  }

  Future<GameResult> startMission(int missionId) async {
    final allMissions = await getAllMissionsResolved();
    final mission = allMissions.where((m) => m.id == missionId).firstOrNull;
    if (mission == null) return GameResult.fail('Mision no encontrada');

    if (_state.character.energy < 1) {
      return GameResult.fail(
        'No tienes suficiente energia (necesitas 1). Espera a manana, sube de nivel o usa una pocion.',
      );
    }

    final activeMissions = List<ActiveMission>.from(_state.activeMissions);
    if (activeMissions.length >= 3) {
      return GameResult.fail(
        'Ya tienes 3 misiones activas. Completa o cancela alguna primero.',
      );
    }
    if (activeMissions.any((m) => m.missionId == missionId)) {
      return GameResult.fail('Esta mision ya esta en progreso');
    }

    final newEnergy = max(0, _state.character.energy - 1);
    final hadTimer = _state.stats.lastEnergyUpdate != null;

    activeMissions.add(ActiveMission(
      missionId: missionId,
      name: mission.name,
      icon: mission.icon,
      startDate: DateTime.now(),
    ));

    String? newEnergyUpdate = _state.stats.lastEnergyUpdate;
    if (!hadTimer && newEnergy < _state.character.maxEnergy) {
      newEnergyUpdate = DateTime.now().toIso8601String();
    }

    _state = _state.copyWith(
      character: _state.character.copyWith(energy: newEnergy),
      activeMissions: activeMissions,
      stats: _state.stats.copyWith(lastEnergyUpdate: newEnergyUpdate),
    );
    await _save();
    return GameResult(
      success: true,
      message: 'Mision iniciada',
      data: {'mission': mission},
    );
  }

  Future<GameResult> completeActiveMission(int missionId) async {
    final activeMissions = List<ActiveMission>.from(_state.activeMissions);
    final idx = activeMissions.indexWhere((m) => m.missionId == missionId);
    if (idx == -1) return GameResult.fail('Mision no encontrada');

    final allMissions = await getAllMissionsResolved();
    final mission = allMissions.where((m) => m.id == missionId).firstOrNull;
    if (mission == null) return GameResult.fail('Mision no encontrada');

    activeMissions.removeAt(idx);

    // Registrar mision completada + dar XP y oro
    var character = _state.character;
    var history = _state.history;
    var stats = _state.stats;

    final record = CompletedMissionRecord(
      missionId: mission.id,
      date: DateTime.now(),
      xpGained: mission.xp,
      goldGained: mission.gold,
    );

    history = history.copyWith(
      completedMissions: [...history.completedMissions, record],
    );
    stats = stats.copyWith(
      totalMissions: stats.totalMissions + 1,
      missionsToday: stats.missionsToday + 1,
      totalXP: stats.totalXP + mission.xp,
      totalGold: stats.totalGold + mission.gold,
    );

    character = character.copyWith(
      xp: character.xp + mission.xp,
      gold: character.gold + mission.gold,
    );

    // Comprobar subida de nivel
    bool leveledUp = false;
    int newLevel = character.level;
    String? newTitle;

    final check = checkLevelUp(character.level, character.xp);
    if (check.leveledUp) {
      leveledUp = true;
      newLevel = check.newLevel;
      newTitle = getTitleByLevel(newLevel);
      character = character.copyWith(
        level: newLevel,
        xp: 0,
        lives: min(character.lives + 1, character.maxLives),
      );
      history = history.copyWith(
        levelsReached: [...history.levelsReached, newLevel],
      );
    }

    _state = _state.copyWith(
      character: character,
      activeMissions: activeMissions,
      history: history,
      stats: stats,
    );
    await _save();

    return GameResult(
      success: true,
      message: 'Mision completada!',
      data: {
        'mission': mission,
        'xpGained': mission.xp,
        'goldGained': mission.gold,
        'leveledUp': leveledUp,
        'newLevel': newLevel,
        'title': newTitle,
      },
    );
  }

  Future<GameResult> cancelActiveMission(int missionId) async {
    final activeMissions = List<ActiveMission>.from(_state.activeMissions);
    final idx = activeMissions.indexWhere((m) => m.missionId == missionId);
    if (idx == -1) return GameResult.fail('Mision no encontrada');

    activeMissions.removeAt(idx);
    _state = _state.copyWith(activeMissions: activeMissions);
    await _save();
    return GameResult.ok('Mision cancelada');
  }

  Future<GameResult> failActiveMission(int missionId) async {
    final activeMissions = List<ActiveMission>.from(_state.activeMissions);
    final idx = activeMissions.indexWhere((m) => m.missionId == missionId);
    if (idx == -1) return GameResult.fail('Mision no encontrada');

    activeMissions.removeAt(idx);
    final newLives = max(0, _state.character.lives - 1);

    _state = _state.copyWith(
      character: _state.character.copyWith(lives: newLives),
      activeMissions: activeMissions,
    );
    await _save();

    return GameResult(
      success: true,
      message: 'Mision fallada',
      data: {
        'remainingLives': newLives,
        'noLives': newLives == 0,
      },
    );
  }

  /// Comprueba y falla misiones expiradas (>12h).
  Future<List<ActiveMission>> checkExpiredMissions() async {
    final activeMissions = List<ActiveMission>.from(_state.activeMissions);
    final expired = <ActiveMission>[];
    final remaining = <ActiveMission>[];
    var lives = _state.character.lives;

    for (final m in activeMissions) {
      if (m.isExpired) {
        expired.add(m);
        lives = max(0, lives - 1);
      } else {
        remaining.add(m);
      }
    }

    if (expired.isNotEmpty) {
      _state = _state.copyWith(
        character: _state.character.copyWith(lives: lives),
        activeMissions: remaining,
      );
      await _save();
    }
    return expired;
  }

  // ===== Recompensas =====

  Future<List<Reward>> getAllRewardsResolved() async {
    final custom = await gameRepository.getCustomRewards();
    return getAllRewards(custom);
  }

  Future<GameResult> purchaseReward(int rewardId) async {
    final allRewards = await getAllRewardsResolved();
    final reward = allRewards.where((r) => r.id == rewardId).firstOrNull;
    if (reward == null) return GameResult.fail('Recompensa no encontrada');

    if (_state.character.level < reward.requiredLevel) {
      return GameResult.fail(
        'Necesitas nivel ${reward.requiredLevel} para desbloquear esto',
      );
    }

    final cooldown = getRewardCooldownInfo(rewardId);
    if (cooldown.onCooldown) {
      if (cooldown.hoursRemaining > 0) {
        return GameResult.fail(
          'Disponible en ${cooldown.hoursRemaining}h ${cooldown.minutesRemaining}m',
        );
      }
      return GameResult.fail(
        'Disponible en ${cooldown.minutesRemaining}m',
      );
    }

    if (_state.character.gold < reward.price) {
      return GameResult.fail('No tienes suficiente oro');
    }

    final record = PurchasedRewardRecord(
      rewardId: rewardId,
      date: DateTime.now(),
      priceSpent: reward.price,
    );

    _state = _state.copyWith(
      character: _state.character.copyWith(
        gold: _state.character.gold - reward.price,
      ),
      history: _state.history.copyWith(
        purchasedRewards: [..._state.history.purchasedRewards, record],
      ),
      stats: _state.stats.copyWith(
        totalSpent: _state.stats.totalSpent + reward.price,
      ),
    );
    await _save();
    return GameResult(
      success: true,
      message: 'Recompensa comprada!',
      data: {'reward': reward},
    );
  }

  // ===== Pociones =====

  Future<GameResult> purchasePotion(int potionId) async {
    final allRewards = await getAllRewardsResolved();
    final potion = allRewards
        .where((r) => r.id == potionId && r.isPotion)
        .firstOrNull;
    if (potion == null) return GameResult.fail('Pocion no encontrada');

    if (_state.character.gold < potion.price) {
      return GameResult.fail('No tienes suficiente oro');
    }

    // Compra
    final purchaseRecord = PurchasedRewardRecord(
      rewardId: potionId,
      date: DateTime.now(),
      priceSpent: potion.price,
    );

    // Agregar al inventario
    final potions = List<InventoryPotion>.from(_state.inventory.potions);
    final existingIdx = potions.indexWhere((p) => p.id == potionId);
    if (existingIdx >= 0) {
      potions[existingIdx] =
          potions[existingIdx].copyWith(quantity: potions[existingIdx].quantity + 1);
    } else {
      potions.add(InventoryPotion(id: potionId, quantity: 1));
    }

    _state = _state.copyWith(
      character: _state.character.copyWith(
        gold: _state.character.gold - potion.price,
      ),
      inventory: _state.inventory.copyWith(potions: potions),
      history: _state.history.copyWith(
        purchasedRewards: [..._state.history.purchasedRewards, purchaseRecord],
      ),
      stats: _state.stats.copyWith(
        totalSpent: _state.stats.totalSpent + potion.price,
      ),
    );
    await _save();
    return GameResult(
      success: true,
      message: 'Pocion comprada!',
      data: {'potion': potion},
    );
  }

  Future<GameResult> usePotion(int potionId) async {
    final allRewards = await getAllRewardsResolved();
    final potion = allRewards
        .where((r) => r.id == potionId && r.isPotion)
        .firstOrNull;
    if (potion == null) return GameResult.fail('Pocion no encontrada');

    final potions = List<InventoryPotion>.from(_state.inventory.potions);
    final existingIdx = potions.indexWhere((p) => p.id == potionId);
    if (existingIdx < 0 || potions[existingIdx].quantity <= 0) {
      return GameResult.fail('No tienes esta pocion');
    }

    // Consumir pocion
    if (potions[existingIdx].quantity == 1) {
      potions.removeAt(existingIdx);
    } else {
      potions[existingIdx] =
          potions[existingIdx].copyWith(quantity: potions[existingIdx].quantity - 1);
    }

    var character = _state.character;
    String effectMessage = '';

    if (potion.effect == PotionEffect.restoreLife && potion.value != null) {
      final restored =
          min(potion.value!, character.maxLives - character.lives);
      character = character.copyWith(
        lives: min(character.lives + potion.value!, character.maxLives),
      );
      effectMessage = 'Recuperaste $restored corazon(es) de vida';
    } else if (potion.effect == PotionEffect.restoreEnergy &&
        potion.value != null) {
      final restored =
          min(potion.value!, character.maxEnergy - character.energy);
      final newEnergy =
          min(character.energy + potion.value!, character.maxEnergy);
      character = character.copyWith(energy: newEnergy);
      effectMessage = 'Recuperaste $restored punto(s) de energia';
    }

    // Actualizar timer de energia
    String? newEnergyUpdate = _state.stats.lastEnergyUpdate;
    if (character.energy >= character.maxEnergy) {
      newEnergyUpdate = null;
    } else {
      newEnergyUpdate ??= DateTime.now().toIso8601String();
    }

    _state = _state.copyWith(
      character: character,
      inventory: _state.inventory.copyWith(potions: potions),
      stats: newEnergyUpdate == null
          ? _state.stats.copyWith(clearLastEnergyUpdate: true)
          : _state.stats.copyWith(lastEnergyUpdate: newEnergyUpdate),
    );
    await _save();
    return GameResult(
      success: true,
      message: effectMessage,
      data: {'potion': potion},
    );
  }

  // ===== Progresion =====

  ({int currentXP, int requiredXP, double percentage, int level})
      getLevelProgress() {
    final requiredXP = calculateXPForLevel(_state.character.level);
    final progress = (_state.character.xp / requiredXP) * 100;
    return (
      currentXP: _state.character.xp,
      requiredXP: requiredXP,
      percentage: min(progress, 100),
      level: _state.character.level,
    );
  }

  TodayStats getTodayStats() {
    final today = DateTime.now();
    final todayMissions = _state.history.completedMissions.where((m) {
      return m.date.year == today.year &&
          m.date.month == today.month &&
          m.date.day == today.day;
    }).toList();

    return TodayStats(
      missions: todayMissions.length,
      xp: todayMissions.fold(0, (sum, m) => sum + m.xpGained),
      gold: todayMissions.fold(0, (sum, m) => sum + m.goldGained),
    );
  }

  int calculateStreak() {
    final missions = _state.history.completedMissions;
    if (missions.isEmpty) return 0;

    int streak = 1;
    var currentDay = DateTime.now();
    currentDay = DateTime(currentDay.year, currentDay.month, currentDay.day);

    for (int i = missions.length - 1; i >= 0; i--) {
      final missionDate = missions[i].date;
      final missionDay =
          DateTime(missionDate.year, missionDate.month, missionDate.day);
      final daysDiff = currentDay.difference(missionDay).inDays;

      if (daysDiff == 1) {
        streak++;
        currentDay = missionDay;
      } else if (daysDiff > 1) {
        break;
      }
    }
    return streak;
  }

  EnergyTimerInfo getEnergyTimerInfo() {
    final maxEnergy = _state.character.maxEnergy;
    final currentEnergy = _state.character.energy;

    if (currentEnergy >= maxEnergy) {
      return const EnergyTimerInfo(isFull: true);
    }

    final lastUpdateStr = _state.stats.lastEnergyUpdate;
    if (lastUpdateStr == null) {
      return const EnergyTimerInfo(isFull: true);
    }

    try {
      final lastUpdate = DateTime.parse(lastUpdateStr);
      final nextUpdate = lastUpdate.add(const Duration(hours: 1));
      final now = DateTime.now();
      final totalSeconds = max(0, nextUpdate.difference(now).inSeconds);

      return EnergyTimerInfo(
        isFull: false,
        minutesRemaining: totalSeconds ~/ 60,
        secondsRemaining: totalSeconds % 60,
      );
    } catch (_) {
      return const EnergyTimerInfo(isFull: true);
    }
  }

  CooldownInfo getRewardCooldownInfo(int rewardId) {
    // Buscar en las recompensas base
    Reward? reward;
    for (final r in kRewards) {
      if (r.id == rewardId) {
        reward = r;
        break;
      }
    }
    if (reward == null || reward.cooldownHours == null) {
      return const CooldownInfo();
    }

    final purchases = _state.history.purchasedRewards
        .where((r) => r.rewardId == rewardId)
        .toList();
    if (purchases.isEmpty) return const CooldownInfo();

    final lastPurchase = purchases.last;
    final hoursElapsed =
        DateTime.now().difference(lastPurchase.date).inMinutes / 60.0;

    if (hoursElapsed >= reward.cooldownHours!) return const CooldownInfo();

    final hoursRemainingFloat = reward.cooldownHours! - hoursElapsed;
    return CooldownInfo(
      onCooldown: true,
      hoursRemaining: hoursRemainingFloat.floor(),
      minutesRemaining:
          ((hoursRemainingFloat - hoursRemainingFloat.floor()) * 60).floor(),
    );
  }

  String get characterTitle => getTitleByLevel(_state.character.level);

  String? get characterClassName {
    final classInfo = getClassById(_state.character.classId);
    return classInfo?.name;
  }

  // ===== Custom missions/rewards CRUD =====

  Future<void> addCustomMission(Mission mission) async {
    final missions = await gameRepository.getCustomMissions();
    final newId = DateTime.now().millisecondsSinceEpoch;
    final newMission = Mission(
      id: newId,
      name: mission.name,
      description: mission.description,
      type: mission.type,
      xp: mission.xp,
      gold: mission.gold,
      icon: mission.icon,
      isCustom: true,
    );
    missions.add(newMission);
    await gameRepository.saveCustomMissions(missions);
  }

  Future<void> updateCustomMission(int id, Mission mission) async {
    final missions = await gameRepository.getCustomMissions();
    final idx = missions.indexWhere((m) => m.id == id);
    if (idx >= 0) {
      missions[idx] = Mission(
        id: id,
        name: mission.name,
        description: mission.description,
        type: mission.type,
        xp: mission.xp,
        gold: mission.gold,
        icon: mission.icon,
        isCustom: true,
      );
      await gameRepository.saveCustomMissions(missions);
    }
  }

  Future<void> deleteCustomMission(int id) async {
    final missions = await gameRepository.getCustomMissions();
    missions.removeWhere((m) => m.id == id);
    await gameRepository.saveCustomMissions(missions);
  }

  Future<void> addCustomReward(Reward reward) async {
    final rewards = await gameRepository.getCustomRewards();
    final newId = DateTime.now().millisecondsSinceEpoch;
    final newReward = Reward(
      id: newId,
      name: reward.name,
      description: reward.description,
      price: reward.price,
      category: reward.category,
      icon: reward.icon,
      isCustom: true,
    );
    rewards.add(newReward);
    await gameRepository.saveCustomRewards(rewards);
  }

  Future<void> updateCustomReward(int id, Reward reward) async {
    final rewards = await gameRepository.getCustomRewards();
    final idx = rewards.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      rewards[idx] = Reward(
        id: id,
        name: reward.name,
        description: reward.description,
        price: reward.price,
        category: reward.category,
        icon: reward.icon,
        isCustom: true,
      );
      await gameRepository.saveCustomRewards(rewards);
    }
  }

  Future<void> deleteCustomReward(int id) async {
    final rewards = await gameRepository.getCustomRewards();
    rewards.removeWhere((r) => r.id == id);
    await gameRepository.saveCustomRewards(rewards);
  }

  // ===== Reset =====

  Future<void> resetProgress() async {
    await gameRepository.resetProgress();
    _state = await gameRepository.loadGameState();
  }
}
