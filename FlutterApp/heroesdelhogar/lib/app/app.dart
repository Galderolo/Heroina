import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../di/service_locator.dart';
import '../domain/services/game_service.dart';
import '../presentation/providers/game_provider.dart';
import '../presentation/screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

class GuardianesApp extends StatelessWidget {
  const GuardianesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(getIt<GameService>()),
      child: MaterialApp(
        title: 'Guardianes del Hogar',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
