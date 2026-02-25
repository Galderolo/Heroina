import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/game_data.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/app_title_bar.dart';
import '../../widgets/common/resource_header.dart';
import '../../widgets/common/game_dialogs.dart';
import '../home_shell.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  Future<void> _showEditNameDialog(
      BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        title: Text(
          'Cambiar nombre',
          style: TextStyle(
            color: AppColors.goldBright,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 24,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Nombre del personaje',
            hintStyle:
                TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
            filled: true,
            fillColor: AppColors.dark.withValues(alpha: 0.5),
            counterStyle:
                TextStyle(color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColors.goldBright.withValues(alpha: 0.7)),
            ),
          ),
          onSubmitted: (v) {
            final trimmed = v.trim();
            if (trimmed.isNotEmpty) Navigator.pop(ctx, trimmed);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isNotEmpty) Navigator.pop(ctx, trimmed);
            },
            child: Text(
              'Guardar',
              style: TextStyle(
                color: AppColors.goldBright,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName != null && context.mounted) {
      await context.read<GameProvider>().updateCharacterName(newName);
    }
  }

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
                const AppTitleBar(),
                const SizedBox(height: 16),

                // === Character Card (incluye ORO/ENERGÍA/VIDAS) ===
                _buildCharacterCard(context, character, className, title, progress, game),
                const SizedBox(height: 14),

                // === Inventario (siempre visible) ===
                _buildInventorySection(context, game, inventory),
                const SizedBox(height: 14),

                // === Misiones activas ===
                if (activeMissions.isNotEmpty) ...[
                  _buildActiveMissionsSection(context, game, activeMissions),
                  const SizedBox(height: 14),
                ],

                // === Stats de hoy ===
                _buildStatsSection(
                  context,
                  title: 'Estadísticas de Hoy',
                  headerColor: const Color(0xFF4FC3F7),
                  stats: [
                    _StatData('\u{2694}\u{FE0F}', 'Misiones\nCompletadas', '${todayStats.missions}', const Color(0xFF4FC3F7)),
                    _StatData('\u{2B50}', 'XP\nGanada', '${todayStats.xp}', const Color(0xFFFFD700)),
                    _StatData('\u{1FA99}', 'Oro\nGanado', '${todayStats.gold}', const Color(0xFFFFB300)),
                    _StatData('\u{1F525}', 'Racha\nActual', '$streak d', const Color(0xFFFF6B35)),
                  ],
                ),
                const SizedBox(height: 14),

                // === Total stats ===
                _buildStatsSection(
                  context,
                  title: 'Estadísticas Totales',
                  headerColor: const Color(0xFFA855F7),
                  stats: [
                    _StatData('\u{1F3C6}', 'Misiones\nTotales', '${game.state.stats.totalMissions}', const Color(0xFF4FC3F7)),
                    _StatData('\u{2B50}', 'XP\nTotal', '${game.state.stats.totalXP}', const Color(0xFFFFD700)),
                    _StatData('\u{1FA99}', 'Oro\nGanado', '${game.state.stats.totalGold}', const Color(0xFFFFB300)),
                    _StatData('\u{1F6CD}\u{FE0F}', 'Oro\nGastado', '${game.state.stats.totalSpent}', const Color(0xFFEF4444)),
                  ],
                ),

                // === Botón Reiniciar Progreso (siempre al final) ===
                const SizedBox(height: 28),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showConfirmDialog(
                        context,
                        title: 'Reiniciar Progreso',
                        message:
                            'Se borrarán nivel, XP, oro, misiones completadas y compras. '
                            'El nombre y la clase del personaje se conservan. '
                            '¿Continuar?',
                        confirmText: 'Reiniciar',
                        confirmColor: const Color.fromARGB(255, 255, 23, 6),
                      );
                      if (confirm && context.mounted) {
                        await game.resetProgress();
                      }
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('REINICIAR PROGRESO'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 236, 37, 37),
                      side: BorderSide(
                        color: Colors.red.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
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
    GameProvider game,
  ) {
    final avatarWidget = _buildAvatar(character.avatar);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: AppDecorations.characterCard(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              // Avatar centrado
              _PulsingAvatar(
                child: avatarWidget,
                onTap: () => _pickAvatar(context),
              ),
              const SizedBox(height: 14),

          // Nombre del personaje en amarillo con glow + lápiz para editar
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                character.name,
                style: GoogleFonts.medievalSharp(
                  fontSize: 26,
                  color: AppColors.goldBright,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                  shadows: [
                    Shadow(
                      color: AppColors.goldBright.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                    const Shadow(color: Colors.black, blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showEditNameDialog(context, character.name),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.blueGlow.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Título de clase en botón dorado tipo web
          GoldButton(
            text: title,
            onPressed: null,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            fontSize: 14,
            icon: Icons.emoji_events_outlined,
          ),
          const SizedBox(height: 6),

          // Clase del personaje en pill azul
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.blueGlow.withValues(alpha: 0.25),
                  AppColors.purpleGlow.withValues(alpha: 0.18),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.blueGlow.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              className,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Nivel con texto grande y brillo pulsante
          _PulsingLevelTitle(level: character.level),
          const SizedBox(height: 18),
          AppDecorations.goldenDivider(),
          const SizedBox(height: 14),

          // XP Bar (mismo ancho que las tarjetas ORO/ENERGÍA/VIDAS)
          SizedBox(
            width: double.infinity,
            child: _buildXPBar(progress),
          ),
          const SizedBox(height: 16),
          AppDecorations.goldenDivider(),
          const SizedBox(height: 14),

          // Recursos: ORO / ENERGÍA / VIDAS dentro de la tarjeta
          _buildResourceRows(character, game),
            ],
          ),
          // Botón Perfiles dentro de la tarjeta, arriba a la derecha
          if (ShellScope.maybeOf(context)?.onGoToProfiles != null)
            Positioned(
              top: 0,
              right: 0,
              child: ProfilesButton(
                onTap: ShellScope.maybeOf(context)!.onGoToProfiles,
              ),
            ),
        ],
      ),
    );
  }

  /// Versión de recursos en filas compactas para el interior de la character card
  Widget _buildResourceRows(dynamic character, GameProvider game) {
    final timerInfo = game.energyTimerInfo;
    return Column(
      children: [
        _ResourceRow(
          icon: '\u{1FA99}',
          iconColor: AppColors.goldBright,
          label: 'ORO',
          value: '${character.gold}',
          subtitle: 'Lo puedes gastar en la tienda',
          valueHighlight: true,
        ),
        const SizedBox(height: 8),
        _ResourceRow(
          icon: '\u{26A1}',
          iconColor: AppColors.blueGlow,
          label: 'ENERG\u{00CD}A',
          value: '${character.energy}/${character.maxEnergy}',
          subtitle: timerInfo.isFull
              ? 'Energ\u{00ED}a completa'
              : 'Recarga en ${timerInfo.minutesRemaining}m',
          badge: 'Misiones: 1 \u{26A1}',
        ),
        const SizedBox(height: 8),
        _ResourceRow(
          icon: '\u{2764}\u{FE0F}',
          iconColor: AppColors.light,
          label: 'VIDAS',
          value: '${character.lives}/${character.maxLives}',
          subtitle: 'Se pierden al fracasar',
        ),
      ],
    );
  }

  Widget _buildStatsSection(
    BuildContext context, {
    required String title,
    required Color headerColor,
    required List<_StatData> stats,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xE0162140), Color(0xE60A0E27)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: headerColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: headerColor.withValues(alpha: 0.08),
            blurRadius: 18,
            spreadRadius: 1,
          ),
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
          // Cabecera degradada estilo Blizzard
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  headerColor.withValues(alpha: 0.25),
                  headerColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border(
                bottom: BorderSide(
                  color: headerColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: headerColor.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: headerColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Grid de stats
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: stats
                  .map((s) => Expanded(
                        child: _StatItem(
                          icon: s.icon,
                          label: s.label,
                          value: s.value,
                          color: s.color,
                        ),
                      ))
                  .toList(),
            ),
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
            '\u{1F392}  Inventario de Pociones',
            style: GoogleFonts.medievalSharp(
              color: AppColors.goldBright,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppDecorations.goldenDivider(),
          const SizedBox(height: 14),
          if (inventory.potions.isEmpty)
            Text(
              'No tienes pociones. ¡Cómpralas en la tienda!',
              style: TextStyle(
                color: AppColors.blueGlow.withValues(alpha: 0.85),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
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
    final value = (progress.percentage / 100).clamp(0.0, 1.0);
    const barHeight = 33.0; // 1/4 menos que 44
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final fillWidth = barWidth * value;
        return Container(
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(barHeight / 2),
            border: Border.all(
              color: AppColors.dark.withValues(alpha: 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(barHeight / 2),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fondo oscuro (parte no rellenada)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF0D1320),
                  ),
                ),
                // Parte rellenada con gradiente cyan → púrpura → cyan (borde derecho redondeado + efecto brillo)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: fillWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(barHeight / 2),
                        right: Radius.circular(barHeight / 2),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF00D4FF),
                          Color(0xFFA855F7),
                          Color(0xFF00D4FF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blueGlow.withValues(alpha: 0.5),
                          blurRadius: 14,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: AppColors.purpleGlow.withValues(alpha: 0.35),
                          blurRadius: 20,
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                  ),
                ),
                // Texto "X / Y XP" con sombra paralela para mejor lectura
                Text(
                  '${progress.currentXP} / ${progress.requiredXP} XP',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.9),
                        offset: const Offset(1, 1),
                        blurRadius: 0,
                      ),
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        offset: const Offset(2, 2),
                        blurRadius: 2,
                      ),
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Avatar con brillo pulsante (latido) similar a la web.
class _PulsingAvatar extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PulsingAvatar({
    required this.child,
    required this.onTap,
  });

  @override
  State<_PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<_PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _glow = Tween<double>(begin: 0.25, end: 0.6).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldBright.withValues(alpha: _glow.value),
                      blurRadius: 26,
                      spreadRadius: 6,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: 18,
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.goldBright.withValues(alpha: 0.85),
                    width: 3,
                  ),
                ),
                child: widget.child,
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, Color(0xFF7C3AED)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.goldBright.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Título de nivel con brillo pulsante (latido) y glow amarillo.
class _PulsingLevelTitle extends StatefulWidget {
  final int level;

  const _PulsingLevelTitle({required this.level});

  @override
  State<_PulsingLevelTitle> createState() => _PulsingLevelTitleState();
}

class _PulsingLevelTitleState extends State<_PulsingLevelTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _glow = Tween<double>(begin: 0.35, end: 0.75).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Text(
          'Nivel ${widget.level}',
          style: GoogleFonts.medievalSharp(
            color: AppColors.goldBright,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: AppColors.goldBright.withValues(alpha: _glow.value),
                blurRadius: 24,
              ),
              const Shadow(
                color: Colors.black,
                blurRadius: 6,
              ),
            ],
          ),
        );
      },
    );
  }
}

// === Helper data class ===
class _StatData {
  final String icon;
  final String label;
  final String value;
  final Color color;
  const _StatData(this.icon, this.label, this.value, this.color);
}

// === Stat Item Widget ===
class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icono con fondo degradado de color
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.35),
                color.withValues(alpha: 0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(height: 8),
        // Valor grande y brillante
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: color,
            fontSize: 20,
            shadows: [
              Shadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
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

// === Resource Row (layout como la web: icono | label + subtítulo en fila | valor grande abajo) ===
class _ResourceRow extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;
  final String? badge;
  /// Si true, el valor se muestra en amarillo con brillo (ORO). Si false, en blanco.
  final bool valueHighlight;

  const _ResourceRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
    this.badge,
    this.valueHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final String topRightText = badge ?? subtitle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.dark.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono en círculo (estilo web)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: iconColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          // Columna: fila superior (label + texto derecho) y valor grande debajo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        topRightText,
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueHighlight ? AppColors.goldBright : AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    shadows: valueHighlight
                        ? [
                            Shadow(
                              color: AppColors.goldBright.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
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
