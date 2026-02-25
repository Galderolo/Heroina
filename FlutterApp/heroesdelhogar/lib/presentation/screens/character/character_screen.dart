import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/game_data.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/resource_header.dart';
import '../../widgets/common/game_dialogs.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  Future<void> _pickAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 256,
      maxHeight: 256,
      imageQuality: 70,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final base64Str = base64Encode(bytes);

    if (context.mounted) {
      await context.read<GameProvider>().updateCharacterAvatar(base64Str);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        final character = game.state.character;
        final progress = game.levelProgress;
        final todayStats = game.todayStats;
        final streak = game.streak;
        final title = game.characterTitle;
        final className = game.characterClassName ?? '';
        final activeMissions = game.state.activeMissions;
        final inventory = game.state.inventory;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ResourceHeader(),
                const SizedBox(height: 16),

                // === Character Card ===
                _buildCharacterCard(context, character, className, title, progress),
                const SizedBox(height: 14),

                // === Stats de hoy ===
                _buildStatsSection(
                  context,
                  title: '\u{1F4C5}  Hoy',
                  stats: [
                    _StatData('\u{2694}\u{FE0F}', 'Misiones', '${todayStats.missions}'),
                    _StatData('\u{2B50}', 'XP', '${todayStats.xp}'),
                    _StatData('\u{1FA99}', 'Oro', '${todayStats.gold}'),
                    _StatData('\u{1F525}', 'Racha', '$streak dia(s)'),
                  ],
                ),
                const SizedBox(height: 14),

                // === Total stats ===
                _buildStatsSection(
                  context,
                  title: '\u{1F4CA}  Totales',
                  stats: [
                    _StatData('\u{2694}\u{FE0F}', 'Misiones', '${game.state.stats.totalMissions}'),
                    _StatData('\u{2B50}', 'XP', '${game.state.stats.totalXP}'),
                    _StatData('\u{1FA99}', 'Oro', '${game.state.stats.totalGold}'),
                    _StatData('\u{1F6CD}\u{FE0F}', 'Gastado', '${game.state.stats.totalSpent}'),
                  ],
                ),
                const SizedBox(height: 14),

                // === Misiones activas ===
                if (activeMissions.isNotEmpty) ...[
                  _buildActiveMissionsSection(context, game, activeMissions),
                  const SizedBox(height: 14),
                ],

                // === Inventario ===
                if (inventory.potions.isNotEmpty) ...[
                  _buildInventorySection(context, game, inventory),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCharacterCard(
    BuildContext context,
    dynamic character,
    String className,
    String title,
    dynamic progress,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xD9162140),
            Color(0xD90A0E27),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.goldBright.withValues(alpha: 0.2),
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
          // Avatar (tappable) with golden glow
          GestureDetector(
            onTap: () => _pickAvatar(context),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldBright.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 15,
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.goldBright.withValues(alpha: 0.6),
                      width: 3,
                    ),
                  ),
                  child: _buildAvatar(character.avatar),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, Color(0xFF7C3AED)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.goldBright.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Name
          Text(
            character.name,
            style: GoogleFonts.medievalSharp(
              fontSize: 26,
              color: AppColors.goldBright,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: AppColors.goldBright.withValues(alpha: 0.25),
                  blurRadius: 15,
                ),
                const Shadow(color: Colors.black, blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Class + Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.blueGlow.withValues(alpha: 0.15),
                  AppColors.purpleGlow.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.blueGlow.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              '$className  \u{2022}  $title',
              style: TextStyle(
                color: AppColors.blueGlow,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xF20F3460), Color(0xF20A0E27)],
              ),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: AppColors.goldBright.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldBright.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              '\u{2694}\u{FE0F}  Nivel ${character.level}',
              style: TextStyle(
                color: AppColors.goldBright.withValues(alpha: 0.95),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 18),
          AppDecorations.goldenDivider(),
          const SizedBox(height: 14),

          // XP Bar
          _buildXPBar(progress),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context, {
    required String title,
    required List<_StatData> stats,
  }) {
    return Container(
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
          color: AppColors.goldBright.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.medievalSharp(
              color: AppColors.goldBright,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: stats
                .map((s) => _StatItem(
                      icon: s.icon,
                      label: s.label,
                      value: s.value,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveMissionsSection(
    BuildContext context,
    GameProvider game,
    List<dynamic> activeMissions,
  ) {
    return Container(
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
          color: AppColors.goldBright.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\u{1F3AF}  Misiones Activas',
            style: GoogleFonts.medievalSharp(
              color: AppColors.goldBright,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...activeMissions.map((m) => _ActiveMissionTile(
                name: m.name,
                icon: m.icon,
                hoursElapsed: m.hoursElapsed,
                onComplete: () async {
                  final result =
                      await game.completeActiveMission(m.missionId);
                  if (context.mounted) {
                    if (result.success) {
                      await showMissionCompleteDialog(
                        context,
                        missionName:
                            result.data['mission']?.name ?? m.name,
                        missionIcon: m.icon,
                        xpGained: result.data['xpGained'] ?? 0,
                        goldGained: result.data['goldGained'] ?? 0,
                      );
                      if (result.data['leveledUp'] == true) {
                        if (context.mounted) {
                          await showLevelUpDialog(
                            context,
                            newLevel: result.data['newLevel'],
                            title: result.data['title'] ?? '',
                          );
                        }
                      }
                    } else {
                      showGameSnackBar(context, result.message,
                          isError: true);
                    }
                  }
                },
                onFail: () async {
                  final confirm = await showConfirmDialog(
                    context,
                    title: 'Fallar Mision',
                    message: 'Perderas 1 vida. Continuar?',
                    confirmText: 'Fallar',
                    confirmColor: Colors.red,
                  );
                  if (confirm && context.mounted) {
                    final result =
                        await game.failActiveMission(m.missionId);
                    if (context.mounted) {
                      showGameSnackBar(
                        context,
                        result.message,
                        isError: !result.success,
                      );
                    }
                  }
                },
                onCancel: () async {
                  final confirm = await showConfirmDialog(
                    context,
                    title: 'Cancelar Mision',
                    message:
                        'Cancelar esta mision sin penalizacion?',
                    confirmText: 'Cancelar Mision',
                  );
                  if (confirm && context.mounted) {
                    await game.cancelActiveMission(m.missionId);
                  }
                },
              )),
        ],
      ),
    );
  }

  Widget _buildInventorySection(
    BuildContext context,
    GameProvider game,
    dynamic inventory,
  ) {
    return Container(
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
          color: AppColors.goldBright.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\u{1F392}  Inventario',
            style: GoogleFonts.medievalSharp(
              color: AppColors.goldBright,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...inventory.potions.map((p) {
            final potionReward =
                kRewards.where((r) => r.id == p.id).firstOrNull;
            if (potionReward == null) return const SizedBox.shrink();

            return _InventoryTile(
              icon: potionReward.icon,
              name: potionReward.name,
              description: potionReward.description,
              quantity: p.quantity,
              onUse: () async {
                final result = await game.usePotion(p.id);
                if (context.mounted) {
                  showGameSnackBar(
                    context,
                    result.message,
                    isError: !result.success,
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? avatar) {
    if (avatar != null && avatar.isNotEmpty) {
      try {
        final bytes = base64Decode(avatar);
        return CircleAvatar(
          radius: 52,
          backgroundImage: MemoryImage(bytes),
          backgroundColor: AppColors.accent.withValues(alpha: 0.3),
        );
      } catch (_) {}
    }
    return CircleAvatar(
      radius: 52,
      backgroundColor: AppColors.accent.withValues(alpha: 0.3),
      child: const Icon(Icons.person, size: 52, color: AppColors.goldBright),
    );
  }

  Widget _buildXPBar(
      ({int currentXP, int requiredXP, double percentage, int level})
          progress) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '\u{2B50}  XP',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${progress.currentXP} / ${progress.requiredXP}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.goldBright.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.15),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.percentage / 100,
              minHeight: 14,
              backgroundColor: AppColors.dark,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.green.shade400),
            ),
          ),
        ),
      ],
    );
  }
}

// === Helper data class ===
class _StatData {
  final String icon;
  final String label;
  final String value;
  const _StatData(this.icon, this.label, this.value);
}

// === Stat Item Widget ===
class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.dark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldBright.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// === Active Mission Tile ===
class _ActiveMissionTile extends StatelessWidget {
  final String name;
  final String icon;
  final double hoursElapsed;
  final VoidCallback onComplete;
  final VoidCallback onFail;
  final VoidCallback onCancel;

  const _ActiveMissionTile({
    required this.name,
    required this.icon,
    required this.hoursElapsed,
    required this.onComplete,
    required this.onFail,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = hoursElapsed < 1
        ? '${(hoursElapsed * 60).round()}m'
        : '${hoursElapsed.toStringAsFixed(1)}h';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accent.withValues(alpha: 0.2),
              AppColors.primary.withValues(alpha: 0.35),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.goldBright.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.08),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.goldBright.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.blueGlow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.blueGlow.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 13,
                          color: AppColors.blueGlow.withValues(alpha: 0.8)),
                      const SizedBox(width: 3),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: AppColors.blueGlow,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  label: 'Cancelar',
                  onPressed: onCancel,
                  color: AppColors.textSecondary,
                  outlined: true,
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  label: 'Fallar',
                  onPressed: onFail,
                  color: AppColors.light,
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  label: '\u{2705} Completar',
                  onPressed: onComplete,
                  color: Colors.green.shade400,
                  filled: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// === Action Button for mission tiles ===
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool outlined;
  final bool filled;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.color,
    this.outlined = false,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: filled ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: outlined
                  ? color.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// === Inventory Tile ===
class _InventoryTile extends StatelessWidget {
  final String icon;
  final String name;
  final String description;
  final int quantity;
  final VoidCallback onUse;

  const _InventoryTile({
    required this.icon,
    required this.name,
    required this.description,
    required this.quantity,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dark.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.goldBright.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.goldBright.withValues(alpha: 0.15),
                ),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'x$quantity',
              style: const TextStyle(
                color: AppColors.goldBright,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: 'Usar',
              onPressed: onUse,
              color: Colors.green.shade400,
              filled: true,
            ),
          ],
        ),
      ),
    );
  }
}
