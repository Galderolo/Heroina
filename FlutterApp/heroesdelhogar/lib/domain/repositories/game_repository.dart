import '../models/game_state.dart';
import '../models/mission.dart';
import '../models/reward.dart';

/// Interfaz abstracta para el almacenamiento del estado del juego.
/// Implementaciones: local (SharedPreferences), futuro: Firebase.
abstract class GameRepository {
  /// Carga el estado del juego para el perfil activo.
  Future<GameState> loadGameState();

  /// Guarda el estado completo del juego.
  Future<bool> saveGameState(GameState state);

  /// Reinicia el progreso manteniendo nombre/avatar/clase.
  Future<bool> resetProgress();

  // --- Misiones personalizadas ---
  Future<List<Mission>> getCustomMissions();
  Future<bool> saveCustomMissions(List<Mission> missions);

  // --- Recompensas personalizadas ---
  Future<List<Reward>> getCustomRewards();
  Future<bool> saveCustomRewards(List<Reward> rewards);
}
