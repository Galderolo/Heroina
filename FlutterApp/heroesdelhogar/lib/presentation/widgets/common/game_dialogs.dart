import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_theme.dart';

/// Muestra un dialogo de confirmacion generico con estilo Blizzard.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
  Color? confirmColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xF0162140),
              Color(0xF00A0E27),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.goldBright.withValues(alpha: 0.25),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                title,
                style: GoogleFonts.medievalSharp(
                  color: AppColors.goldBright,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              AppDecorations.goldenDivider(),
              const SizedBox(height: 16),
              // Message
              Text(
                message,
                style: TextStyle(
                  color: AppColors.textPrimary.withValues(alpha: 0.9),
                  fontSize: 15,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(ctx).pop(false),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            cancelText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(ctx).pop(true),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (confirmColor ?? AppColors.accent)
                                    .withValues(alpha: 0.5),
                                (confirmColor ?? AppColors.accent)
                                    .withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: (confirmColor ?? AppColors.goldBright)
                                  .withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            confirmText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: confirmColor != null
                                  ? Colors.white
                                  : AppColors.goldBright,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}

/// Muestra un snackbar de resultado con estilo mejorado.
void showGameSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor:
          isError ? Colors.red.shade800 : Colors.green.shade800,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: (isError ? Colors.red : Colors.green).withValues(alpha: 0.3),
        ),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Dialogo de subida de nivel con confeti y estilo Blizzard.
Future<void> showLevelUpDialog(
  BuildContext context, {
  required int newLevel,
  required String title,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _LevelUpDialogContent(
      newLevel: newLevel,
      title: title,
    ),
  );
}

class _LevelUpDialogContent extends StatefulWidget {
  final int newLevel;
  final String title;

  const _LevelUpDialogContent({
    required this.newLevel,
    required this.title,
  });

  @override
  State<_LevelUpDialogContent> createState() => _LevelUpDialogContentState();
}

class _LevelUpDialogContentState extends State<_LevelUpDialogContent> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xF0162140),
                  Color(0xF00A0E27),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.goldBright.withValues(alpha: 0.4),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldBright.withValues(alpha: 0.15),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\u{1F31F} Subida de Nivel! \u{1F31F}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.medievalSharp(
                      color: AppColors.goldBright,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppDecorations.goldenDivider(),
                  const SizedBox(height: 20),
                  // Level number
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A4A8C),
                          Color(0xFF0A1E4A),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.goldBright.withValues(alpha: 0.6),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldBright.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${widget.newLevel}',
                        style: GoogleFonts.medievalSharp(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldBright,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.blueGlow,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\u{2764}\u{FE0F} +1 Vida restaurada',
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppDecorations.goldenDivider(),
                  const SizedBox(height: 16),
                  GoldButton(
                    text: 'Continuar',
                    onPressed: () => Navigator.of(context).pop(),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 30,
          maxBlastForce: 20,
          gravity: 0.1,
          colors: const [
            AppColors.goldBright,
            AppColors.blueGlow,
            AppColors.purpleGlow,
            AppColors.light,
          ],
        ),
      ],
    );
  }
}

/// Dialogo de recompensa obtenida con confeti.
Future<void> showRewardDialog(
  BuildContext context, {
  required String rewardName,
  required String rewardIcon,
}) async {
  await showDialog(
    context: context,
    builder: (ctx) => _RewardDialogContent(
      rewardName: rewardName,
      rewardIcon: rewardIcon,
    ),
  );
}

class _RewardDialogContent extends StatefulWidget {
  final String rewardName;
  final String rewardIcon;

  const _RewardDialogContent({
    required this.rewardName,
    required this.rewardIcon,
  });

  @override
  State<_RewardDialogContent> createState() => _RewardDialogContentState();
}

class _RewardDialogContentState extends State<_RewardDialogContent> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xF0162140),
                  Color(0xF00A0E27),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.goldBright.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\u{1F389} Recompensa Obtenida!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.medievalSharp(
                      color: AppColors.goldBright,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppDecorations.goldenDivider(),
                  const SizedBox(height: 20),
                  Text(
                    widget.rewardIcon,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.rewardName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldBright,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  AppDecorations.goldenDivider(),
                  const SizedBox(height: 16),
                  GoldButton(
                    text: '\u{1F44D} Genial!',
                    onPressed: () => Navigator.of(context).pop(),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 20,
          maxBlastForce: 15,
          gravity: 0.15,
          colors: const [
            AppColors.goldBright,
            AppColors.purpleGlow,
            AppColors.blueGlow,
          ],
        ),
      ],
    );
  }
}

/// Dialogo de mision completada con confeti.
Future<void> showMissionCompleteDialog(
  BuildContext context, {
  required String missionName,
  required String missionIcon,
  required int xpGained,
  required int goldGained,
}) async {
  await showDialog(
    context: context,
    builder: (ctx) => _MissionCompleteContent(
      missionName: missionName,
      missionIcon: missionIcon,
      xpGained: xpGained,
      goldGained: goldGained,
    ),
  );
}

class _MissionCompleteContent extends StatefulWidget {
  final String missionName;
  final String missionIcon;
  final int xpGained;
  final int goldGained;

  const _MissionCompleteContent({
    required this.missionName,
    required this.missionIcon,
    required this.xpGained,
    required this.goldGained,
  });

  @override
  State<_MissionCompleteContent> createState() =>
      _MissionCompleteContentState();
}

class _MissionCompleteContentState extends State<_MissionCompleteContent> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xF0162140),
                  Color(0xF00A0E27),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.goldBright.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\u{2694}\u{FE0F} Mision Completada!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.medievalSharp(
                      color: AppColors.goldBright,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppDecorations.goldenDivider(),
                  const SizedBox(height: 20),
                  Text(widget.missionIcon,
                      style: const TextStyle(fontSize: 52)),
                  const SizedBox(height: 10),
                  Text(
                    widget.missionName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Rewards row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RewardBadge(
                        text: '+${widget.xpGained} XP',
                        color: Colors.green.shade300,
                        icon: '\u{2B50}',
                      ),
                      const SizedBox(width: 12),
                      _RewardBadge(
                        text: '+${widget.goldGained}',
                        color: AppColors.goldBright,
                        icon: '\u{1FA99}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppDecorations.goldenDivider(),
                  const SizedBox(height: 16),
                  GoldButton(
                    text: 'Continuar',
                    onPressed: () => Navigator.of(context).pop(),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 25,
          maxBlastForce: 18,
          gravity: 0.12,
          colors: const [
            AppColors.goldBright,
            AppColors.blueGlow,
            Colors.greenAccent,
          ],
        ),
      ],
    );
  }
}

class _RewardBadge extends StatelessWidget {
  final String text;
  final Color color;
  final String icon;

  const _RewardBadge({
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
