import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_theme.dart';
import '../../providers/game_provider.dart';

/// Header reutilizable estilo HUD de juego que muestra
/// Nivel, Vidas, Energia, Oro y barra de XP.
class ResourceHeader extends StatelessWidget {
  const ResourceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        final character = game.state.character;
        final progress = game.levelProgress;
        final timerInfo = game.energyTimerInfo;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xE60F3460),
                Color(0xE6162140),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Row de recursos
              Row(
                children: [
                  _HudChip(
                    emoji: '\u{2694}\u{FE0F}',
                    value: 'Lv ${character.level}',
                    color: AppColors.blueGlow,
                  ),
                  const SizedBox(width: 4),
                  _HudSeparator(),
                  const SizedBox(width: 4),
                  _HudChip(
                    emoji: '\u{2764}\u{FE0F}',
                    value: '${character.lives}/${character.maxLives}',
                    color: AppColors.light,
                  ),
                  const SizedBox(width: 4),
                  _HudSeparator(),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _HudChip(
                      emoji: '\u{26A1}',
                      value: '${character.energy}/${character.maxEnergy}',
                      color: Colors.amberAccent,
                      subtitle: timerInfo.isFull
                          ? null
                          : '${timerInfo.minutesRemaining}m',
                    ),
                  ),
                  const SizedBox(width: 4),
                  _HudSeparator(),
                  const SizedBox(width: 4),
                  _HudChip(
                    emoji: '\u{1FA99}',
                    value: '${character.gold}',
                    color: AppColors.goldBright,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Barra de XP estilo web
              _XPBar(
                percentage: progress.percentage,
                currentXP: progress.currentXP,
                requiredXP: progress.requiredXP,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HudChip extends StatelessWidget {
  final String emoji;
  final String value;
  final Color color;
  final String? subtitle;

  const _HudChip({
    required this.emoji,
    required this.value,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HudSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      '|',
      style: TextStyle(
        color: AppColors.gold.withValues(alpha: 0.3),
        fontSize: 18,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}

class _XPBar extends StatelessWidget {
  final double percentage;
  final int currentXP;
  final int requiredXP;

  const _XPBar({
    required this.percentage,
    required this.currentXP,
    required this.requiredXP,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Stack(
        children: [
          // Track
          Container(
            decoration: BoxDecoration(
              color: AppColors.dark.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          // Fill
          FractionallySizedBox(
            widthFactor: (percentage / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.xpBarGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blueGlow.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          // Text overlay
          Center(
            child: Text(
              '$currentXP / $requiredXP XP',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.9),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
