import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_theme.dart';
import '../providers/game_provider.dart';
import 'character/character_screen.dart';
import 'missions/missions_screen.dart';
import 'shop/shop_screen.dart';
import 'customize/customize_screen.dart';
import 'character/character_creation_screen.dart';
import 'profiles/profiles_screen.dart';

/// InheritedWidget para propagar callbacks del Shell a widgets descendientes.
class ShellScope extends InheritedWidget {
  final VoidCallback onGoToProfiles;

  const ShellScope({
    super.key,
    required this.onGoToProfiles,
    required super.child,
  });

  static ShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellScope>();

  @override
  bool updateShouldNotify(ShellScope old) =>
      onGoToProfiles != old.onGoToProfiles;
}

/// Shell principal con BottomNavigationBar de 5 pestañas.
/// Orden: Misiones | Tienda | Personaje (centro) | WIP | Personalizar
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // Personaje en el centro (índice 2)
  int _currentIndex = 2;

  final List<Widget> _screens = const [
    MissionsScreen(),
    ShopScreen(),
    CharacterScreen(),
    _WipScreen(),
    CustomizeScreen(),
  ];

  void _goToProfiles() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ProfilesScreen()),
    );
  }

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
        child: ShellScope(
          onGoToProfiles: _goToProfiles,
          child: _screens[_currentIndex],
        ),
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
                  icon: Icons.assignment,
                  label: 'Misiones',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.store,
                  label: 'Tienda',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                // Botón central destacado (Personaje)
                _NavItemCenter(
                  icon: Icons.person,
                  label: 'Personaje',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.diamond_outlined,
                  label: 'Premium',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                  isWip: true,
                ),
                _NavItem(
                  icon: Icons.tune,
                  label: 'Personalizar',
                  isActive: _currentIndex == 4,
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────
// WIP Screen placeholder
// ─────────────────────────────────────────────
class _WipScreen extends StatelessWidget {
  const _WipScreen();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xD9162140), Color(0xD90A0E27)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.goldBright.withValues(alpha: 0.25),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('\u{1F48E}', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 16),
                  Text(
                    'Premium',
                    style: GoogleFonts.medievalSharp(
                      color: AppColors.goldBright,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Próximamente...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Suscripciones y tienda de contenido\nexclusivo en desarrollo.',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.goldBright.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: AppColors.goldBright.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      '🚧  WIP',
                      style: TextStyle(
                        color: AppColors.goldBright,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Nav items
// ─────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isWip;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isWip = false,
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? AppColors.goldBright
                      : AppColors.textSecondary,
                  size: isActive ? 26 : 24,
                ),
                if (isWip)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'WIP',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppColors.goldBright
                    : AppColors.textSecondary,
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

/// Botón central destacado para Personaje
class _NavItemCenter extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItemCenter({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFD4AF37),
                          Color(0xFFB8860B),
                        ],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF162140), Color(0xFF0A0E27)],
                      ),
                border: Border.all(
                  color: isActive
                      ? AppColors.goldBright
                      : AppColors.goldBright.withValues(alpha: 0.3),
                  width: isActive ? 2.5 : 1.5,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.goldBright.withValues(alpha: 0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.black : AppColors.textSecondary,
                size: 26,
              ),
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
