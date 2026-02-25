import '../models/profile.dart';

/// Interfaz abstracta para la gestion de perfiles.
/// Implementaciones: local (SharedPreferences), futuro: Firebase.
abstract class ProfileRepository {
  /// Lista todos los perfiles disponibles.
  Future<List<Profile>> listProfiles();

  /// Obtiene el ID del perfil activo (null si no hay).
  Future<String?> getActiveProfileId();

  /// Establece el perfil activo.
  Future<bool> setActiveProfile(String profileId);

  /// Crea un nuevo perfil y lo activa.
  Future<Profile> createProfile();

  /// Elimina un perfil.
  Future<bool> deleteProfile(String profileId);

  /// Obtiene un resumen de un perfil (nivel, clase, titulo).
  Future<Map<String, dynamic>?> getProfileData(String profileId);
}
