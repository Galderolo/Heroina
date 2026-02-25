import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_theme.dart';
import '../../../domain/models/profile.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/game_dialogs.dart';
import '../home_shell.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List<Profile> _profiles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final game = context.read<GameProvider>();
    final profiles = await game.listProfiles();
    if (mounted) {
      setState(() {
        _profiles = profiles;
        _loading = false;
      });
    }
  }

  Future<void> _selectProfile(String profileId) async {
    final game = context.read<GameProvider>();
    await game.setActiveProfile(profileId);
    await game.initialize();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    }
  }

  Future<void> _createProfile() async {
    final game = context.read<GameProvider>();
    final newProfile = await game.createProfile();
    await game.setActiveProfile(newProfile.id);
    await game.initialize();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    }
  }

  Future<void> _deleteProfile(Profile profile) async {
    if (_profiles.length <= 1) {
      showGameSnackBar(context, 'Necesitas al menos un perfil', isError: true);
      return;
    }
    final confirm = await showConfirmDialog(
      context,
      title: 'Eliminar Perfil',
      message:
          'Se eliminara el perfil "${profile.name.isEmpty ? "Sin nombre" : profile.name}" y todo su progreso. Esta seguro?',
      confirmText: 'Eliminar',
      confirmColor: Colors.red,
    );
    if (confirm && mounted) {
      final game = context.read<GameProvider>();
      await game.deleteProfile(profile.id);
      _loadProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // === Hero Frame ===
                _buildHeroFrame(),
                const SizedBox(height: 24),

                // === Profile List or Empty ===
                _loading
                    ? const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: CircularProgressIndicator(),
                      )
                    : _profiles.isEmpty
                        ? _buildEmptyState()
                        : _buildProfileList(),

                const SizedBox(height: 20),

                // === Create Button ===
                GoldButton(
                  text: 'Crear Perfil',
                  icon: Icons.add,
                  onPressed: _createProfile,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroFrame() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xD9162140),
            Color(0xD90A0E27),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.goldBright.withValues(alpha: 0.22),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.goldBright.withValues(alpha: 0.18),
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/splash_banner.png',
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Golden line
          AppDecorations.goldenDivider(),
          const SizedBox(height: 14),
          // Title
          Text(
            'Guardianes del Hogar',
            style: GoogleFonts.medievalSharp(
              color: AppColors.goldBright,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: AppColors.goldBright.withValues(alpha: 0.25),
                  blurRadius: 18,
                ),
                const Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Selecciona un perfil para continuar',
            style: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          AppDecorations.goldenDivider(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('\u{1F9D1}\u{200D}\u{1F527}',
              style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No hay perfiles todavia',
            style: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea uno para comenzar la aventura!',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList() {
    return Column(
      children: _profiles
          .map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProfileCard(
                  profile: p,
                  onTap: () => _selectProfile(p.id),
                  onDelete: () => _deleteProfile(p),
                  gameProvider: context.read<GameProvider>(),
                ),
              ))
          .toList(),
    );
  }
}

class _ProfileCard extends StatefulWidget {
  final Profile profile;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final GameProvider gameProvider;

  const _ProfileCard({
    required this.profile,
    required this.onTap,
    required this.onDelete,
    required this.gameProvider,
  });

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  ProfileSummary? _summary;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final summary =
        await widget.gameProvider.getProfileSummary(widget.profile.id);
    if (mounted) setState(() => _summary = summary);
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        widget.profile.name.isEmpty ? 'Nuevo Heroe' : widget.profile.name;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xE0162140),
                Color(0xE60A0E27),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.goldBright.withValues(alpha: 0.14),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.goldBright.withValues(alpha: 0.35),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    displayName.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.medievalSharp(
                      fontSize: 24,
                      color: AppColors.goldBright,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_summary != null) ...[
                          const SizedBox(width: 8),
                          _LevelBadge(level: _summary!.level),
                        ],
                      ],
                    ),
                    if (_summary != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          _summary!.displayTitle,
                          style: TextStyle(
                            color: AppColors.textPrimary.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Delete
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x40FF5050),
                      Color(0x38B41919),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0x73FF5050),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: const Color(0xF2FFD2D2),
                  onPressed: widget.onDelete,
                  tooltip: 'Eliminar perfil',
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xF20F3460),
            Color(0xF20A0E27),
          ],
        ),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColors.goldBright.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.goldBright.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        'Lv $level',
        style: TextStyle(
          color: AppColors.goldBright.withValues(alpha: 0.95),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
