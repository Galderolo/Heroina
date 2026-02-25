import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/local_game_repository.dart';
import '../data/repositories/local_profile_repository.dart';
import '../domain/repositories/game_repository.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/services/game_service.dart';

final getIt = GetIt.instance;

/// Inicializa todas las dependencias de la app.
Future<void> setupServiceLocator() async {
  // SharedPreferences (singleton)
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Repositorios
  final profileRepo = LocalProfileRepository(prefs);
  getIt.registerSingleton<LocalProfileRepository>(profileRepo);
  getIt.registerSingleton<ProfileRepository>(profileRepo);

  final gameRepo = LocalGameRepository(prefs, profileRepo);
  getIt.registerSingleton<GameRepository>(gameRepo);

  // Servicio del juego
  getIt.registerSingleton<GameService>(
    GameService(
      gameRepository: gameRepo,
      profileRepository: profileRepo,
    ),
  );
}
