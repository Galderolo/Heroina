import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/game_state.dart';
import '../../domain/models/mission.dart';
import '../../domain/models/reward.dart';
import '../../domain/repositories/game_repository.dart';
import '../../core/utils/game_calculations.dart';
import 'local_profile_repository.dart';

class LocalGameRepository implements GameRepository {
  static const _profileKeyPrefix = 'heroina_profile_';
  static const _customMissionsKey = 'custom_missions';
  static const _customRewardsKey = 'custom_rewards';

  final SharedPreferences _prefs;
  final LocalProfileRepository _profileRepo;

  LocalGameRepository(this._prefs, this._profileRepo);

  String _profileDataKey(String profileId) =>
      '$_profileKeyPrefix$profileId';

  Future<String?> get _activeProfileId => _profileRepo.getActiveProfileId();

  @override
  Future<GameState> loadGameState() async {
    final profileId = await _activeProfileId;
    if (profileId == null) return const GameState();

    final raw = _prefs.getString(_profileDataKey(profileId));
    if (raw == null) {
      final fresh = _createFreshState();
      await saveGameState(fresh);
      return fresh;
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      var state = GameState.fromJson(json);
      state = _applyDailyReset(state);
      state = _applyEnergyRestoration(state);
      return state;
    } catch (_) {
      final fresh = _createFreshState();
      await saveGameState(fresh);
      return fresh;
    }
  }

  @override
  Future<bool> saveGameState(GameState state) async {
    final profileId = await _activeProfileId;
    if (profileId == null) return false;

    try {
      final json = jsonEncode(state.toJson());
      await _prefs.setString(_profileDataKey(profileId), json);

      // Sync profile metadata
      await _profileRepo.syncProfileMetadata(
        profileId,
        state.character.name,
        state.character.avatar,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> resetProgress() async {
    final current = await loadGameState();
    final classInfo = getClassById(current.character.classId);

    var fresh = _createFreshState();
    fresh = fresh.copyWith(
      character: fresh.character.copyWith(
        name: current.character.name,
        avatar: current.character.avatar,
        classId: current.character.classId,
        gender: current.character.gender,
        lives: classInfo?.lives ?? 6,
        maxLives: classInfo?.maxLives ?? 6,
        energy: classInfo?.energy ?? 6,
        maxEnergy: classInfo?.maxEnergy ?? 6,
      ),
    );
    return saveGameState(fresh);
  }

  // --- Misiones personalizadas ---

  @override
  Future<List<Mission>> getCustomMissions() async {
    final raw = _prefs.getString(_customMissionsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Mission.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> saveCustomMissions(List<Mission> missions) async {
    final json = jsonEncode(missions.map((m) => m.toJson()).toList());
    return _prefs.setString(_customMissionsKey, json);
  }

  // --- Recompensas personalizadas ---

  @override
  Future<List<Reward>> getCustomRewards() async {
    final raw = _prefs.getString(_customRewardsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Reward.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> saveCustomRewards(List<Reward> rewards) async {
    final json = jsonEncode(rewards.map((r) => r.toJson()).toList());
    return _prefs.setString(_customRewardsKey, json);
  }

  // --- Helpers privados ---

  GameState _createFreshState() {
    return GameState(
      stats: GameStats(
        lastConnection: DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Aplica reset diario: si cambio el dia, reset energia y misiones de hoy.
  GameState _applyDailyReset(GameState state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? lastConnection;
    if (state.stats.lastConnection != null) {
      try {
        lastConnection = DateTime.parse(state.stats.lastConnection!);
      } catch (_) {}
    }

    if (lastConnection == null ||
        DateTime(lastConnection.year, lastConnection.month, lastConnection.day)
                .compareTo(today) !=
            0) {
      return state.copyWith(
        character: state.character.copyWith(
          energy: state.character.maxEnergy,
        ),
        stats: state.stats.copyWith(
          missionsToday: 0,
          lastConnection: now.toIso8601String(),
          clearLastEnergyUpdate: true,
        ),
      );
    }
    return state;
  }

  /// Aplica restauracion de energia por tiempo (1/hora).
  GameState _applyEnergyRestoration(GameState state) {
    final maxEnergy = state.character.maxEnergy;
    final currentEnergy = state.character.energy;

    if (currentEnergy >= maxEnergy) {
      // Ya esta full, quitar timer
      if (state.stats.lastEnergyUpdate != null) {
        return state.copyWith(
          stats: state.stats.copyWith(clearLastEnergyUpdate: true),
        );
      }
      return state;
    }

    final lastUpdateStr = state.stats.lastEnergyUpdate;
    if (lastUpdateStr == null) {
      // Falta energia pero no hay timer -> iniciar timer
      return state.copyWith(
        stats: state.stats.copyWith(
          lastEnergyUpdate: DateTime.now().toIso8601String(),
        ),
      );
    }

    try {
      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();
      final hoursElapsed =
          now.difference(lastUpdate).inMinutes / 60.0;

      if (hoursElapsed >= 1) {
        final hoursToRestore = hoursElapsed.floor();
        final missing = maxEnergy - currentEnergy;
        final energyToAdd =
            hoursToRestore < missing ? hoursToRestore : missing;

        if (energyToAdd > 0) {
          final newEnergy = currentEnergy + energyToAdd;
          final newUpdateTime = lastUpdate.add(
            Duration(hours: energyToAdd),
          );

          return state.copyWith(
            character: state.character.copyWith(energy: newEnergy),
            stats: newEnergy >= maxEnergy
                ? state.stats.copyWith(clearLastEnergyUpdate: true)
                : state.stats.copyWith(
                    lastEnergyUpdate: newUpdateTime.toIso8601String(),
                  ),
          );
        }
      }
    } catch (_) {
      // Timer invalido, reiniciar
      return state.copyWith(
        stats: state.stats.copyWith(
          lastEnergyUpdate: DateTime.now().toIso8601String(),
        ),
      );
    }

    return state;
  }
}
