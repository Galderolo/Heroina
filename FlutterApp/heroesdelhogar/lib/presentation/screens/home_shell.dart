import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../providers/game_provider.dart';
import 'character/character_screen.dart';
import 'missions/missions_screen.dart';
import 'shop/shop_screen.dart';
import 'customize/customize_screen.dart';
import 'character/character_creation_screen.dart';

/// Shell principal con BottomNavigationBar para las 4 pestanas del juego.
/// Si el personaje no esta configurado, muestra la pantalla de creacion.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CharacterScreen(),
    MissionsScreen(),
    ShopScreen(),
    CustomizeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    if (game.loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: kBackgroundGradient),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (!game.hasCharacter) {
      return const CharacterCreationScreen();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.dark],
          ),
          border: Border(
            top: BorderSide(color: AppColors.gold, width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.person,
                  label: 'Personaje',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.assignment,
                  label: 'Misiones',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.store,
                  label: 'Tienda',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.tune,
                  label: 'Personalizar',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active indicator bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 36 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: isActive ? AppColors.goldBright : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.goldBright.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              icon,
              color: isActive ? AppColors.goldBright : AppColors.textSecondary,
              size: isActive ? 26 : 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color:
                    isActive ? AppColors.goldBright : AppColors.textSecondary,
                fontSize: isActive ? 11 : 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
