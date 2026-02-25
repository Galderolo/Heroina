import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../domain/models/game_state.dart';
import '../../domain/models/mission.dart';
import '../../domain/models/reward.dart';
import '../../domain/models/profile.dart';
import '../../domain/services/game_service.dart';

/// Provider principal de estado para toda la app.
/// Conecta GameService con la UI via ChangeNotifier.
class GameProvider extends ChangeNotifier {
  final GameService _service;
  Timer? _energyTimer;

  bool _loading = true;
  String? _error;

  GameProvider(this._service);

  // ===== Getters =====

  bool get loading => _loading;
  String? get error => _error;
  GameState get state => _service.state;
  bool get hasCharacter => _service.hasCharacter;

  String get characterTitle => _service.characterTitle;
  String? get characterClassName => _service.characterClassName;
  TodayStats get todayStats => _service.getTodayStats();
  int get streak => _service.calculateStreak();

  ({int currentXP, int requiredXP, double percentage, int level})
      get levelProgress => _service.getLevelProgress();

  EnergyTimerInfo get energyTimerInfo => _service.getEnergyTimerInfo();

  // ===== Inicializacion =====

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    try {
      await _service.initialize();
      await _service.checkExpiredMissions();
      _error = null;
      _startEnergyTimer();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void _startEnergyTimer() {
    _energyTimer?.cancel();
    _energyTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      notifyListeners(); // Actualiza el timer de energia en la UI
    });
  }

  // ===== Perfiles =====

  Future<List<Profile>> listProfiles() => _service.listProfiles();
  Future<String?> getActiveProfileId() => _service.getActiveProfileId();

  Future<void> setActiveProfile(String profileId) async {
    await _service.setActiveProfile(profileId);
    await _service.checkExpiredMissions();
    notifyListeners();
  }

  Future<Profile> createProfile() async {
    final p = await _service.createProfile();
    notifyListeners();
    return p;
  }

  Future<void> deleteProfile(String profileId) async {
    await _service.deleteProfile(profileId);
    notifyListeners();
  }

  Future<ProfileSummary?> getProfileSummary(String profileId) =>
      _service.getProfileSummary(profileId);

  // ===== Personaje =====

  Future<void> createCharacterWithClass({
    required String name,
    required String classId,
    String? avatar,
    String gender = '',
  }) async {
    await _service.createCharacterWithClass(
      name: name,
      classId: classId,
      avatar: avatar,
      gender: gender,
    );
    notifyListeners();
  }

  Future<void> updateCharacterName(String name) async {
    await _service.updateCharacterName(name);
    notifyListeners();
  }

  Future<void> updateCharacterAvatar(String avatarBase64) async {
    await _service.updateCharacterAvatar(avatarBase64);
    notifyListeners();
  }

  // ===== Misiones =====

  Future<List<Mission>> getAllMissions() => _service.getAllMissionsResolved();

  List<Mission> filterMissions(MissionType? type, List<Mission> all) =>
      _service.getMissionsByType(type, all);

  Future<GameResult> startMission(int missionId) async {
    final result = await _service.startMission(missionId);
    notifyListeners();
    return result;
  }

  Future<GameResult> completeActiveMission(int missionId) async {
    final result = await _service.completeActiveMission(missionId);
    notifyListeners();
    return result;
  }

  Future<GameResult> cancelActiveMission(int missionId) async {
    final result = await _service.cancelActiveMission(missionId);
    notifyListeners();
    return result;
  }

  Future<GameResult> failActiveMission(int missionId) async {
    final result = await _service.failActiveMission(missionId);
    notifyListeners();
    return result;
  }

  // ===== Recompensas =====

  Future<List<Reward>> getAllRewards() => _service.getAllRewardsResolved();

  CooldownInfo getRewardCooldownInfo(int rewardId) =>
      _service.getRewardCooldownInfo(rewardId);

  Future<GameResult> purchaseReward(int rewardId) async {
    final result = await _service.purchaseReward(rewardId);
    notifyListeners();
    return result;
  }

  // ===== Pociones =====

  Future<GameResult> purchasePotion(int potionId) async {
    final result = await _service.purchasePotion(potionId);
    notifyListeners();
    return result;
  }

  Future<GameResult> usePotion(int potionId) async {
    final result = await _service.usePotion(potionId);
    notifyListeners();
    return result;
  }

  // ===== Custom CRUD =====

  Future<void> addCustomMission(Mission mission) async {
    await _service.addCustomMission(mission);
    notifyListeners();
  }

  Future<void> updateCustomMission(int id, Mission mission) async {
    await _service.updateCustomMission(id, mission);
    notifyListeners();
  }

  Future<void> deleteCustomMission(int id) async {
    await _service.deleteCustomMission(id);
    notifyListeners();
  }

  Future<void> addCustomReward(Reward reward) async {
    await _service.addCustomReward(reward);
    notifyListeners();
  }

  Future<void> updateCustomReward(int id, Reward reward) async {
    await _service.updateCustomReward(id, reward);
    notifyListeners();
  }

  Future<void> deleteCustomReward(int id) async {
    await _service.deleteCustomReward(id);
    notifyListeners();
  }

  // ===== Reset =====

  Future<void> resetProgress() async {
    await _service.resetProgress();
    notifyListeners();
  }

  @override
  void dispose() {
    _energyTimer?.cancel();
    super.dispose();
  }
}
