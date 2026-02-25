import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/profile.dart';
import '../../domain/models/game_state.dart';
import '../../domain/repositories/profile_repository.dart';

class LocalProfileRepository implements ProfileRepository {
  static const _profilesIndexKey = 'heroina_profiles_index';
  static const _activeProfileIdKey = 'heroina_active_profile_id';
  static const _profileKeyPrefix = 'heroina_profile_';

  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  LocalProfileRepository(this._prefs);

  String _profileDataKey(String profileId) =>
      '$_profileKeyPrefix$profileId';

  @override
  Future<List<Profile>> listProfiles() async {
    final raw = _prefs.getString(_profilesIndexKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Profile.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> _saveProfilesIndex(List<Profile> profiles) async {
    final json = jsonEncode(profiles.map((p) => p.toJson()).toList());
    return _prefs.setString(_profilesIndexKey, json);
  }

  @override
  Future<String?> getActiveProfileId() async {
    return _prefs.getString(_activeProfileIdKey);
  }

  @override
  Future<bool> setActiveProfile(String profileId) async {
    final profiles = await listProfiles();
    if (!profiles.any((p) => p.id == profileId)) return false;
    return _prefs.setString(_activeProfileIdKey, profileId);
  }

  @override
  Future<Profile> createProfile() async {
    final id = 'p_${_uuid.v4().substring(0, 8)}';
    final now = DateTime.now();
    final profile = Profile(
      id: id,
      createdAt: now,
      lastUsedAt: now,
    );

    final profiles = await listProfiles();
    profiles.add(profile);
    await _saveProfilesIndex(profiles);
    await _prefs.setString(_activeProfileIdKey, id);

    // Guardar estado inicial vacio para el perfil
    final freshState = const GameState();
    final stateJson = jsonEncode(freshState.toJson());
    await _prefs.setString(_profileDataKey(id), stateJson);

    return profile;
  }

  @override
  Future<bool> deleteProfile(String profileId) async {
    final profiles = await listProfiles();
    profiles.removeWhere((p) => p.id == profileId);
    await _saveProfilesIndex(profiles);
    await _prefs.remove(_profileDataKey(profileId));

    final activeId = await getActiveProfileId();
    if (activeId == profileId) {
      if (profiles.length == 1) {
        await _prefs.setString(_activeProfileIdKey, profiles.first.id);
      } else {
        await _prefs.remove(_activeProfileIdKey);
      }
    }
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getProfileData(String profileId) async {
    final raw = _prefs.getString(_profileDataKey(profileId));
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Sincroniza la metadata del perfil (nombre, avatar) desde el estado.
  Future<void> syncProfileMetadata(
      String profileId, String name, String? avatar) async {
    final profiles = await listProfiles();
    final idx = profiles.indexWhere((p) => p.id == profileId);
    if (idx >= 0) {
      profiles[idx] = profiles[idx].copyWith(
        name: name,
        avatar: avatar,
        lastUsedAt: DateTime.now(),
      );
      await _saveProfilesIndex(profiles);
    }
  }
}
