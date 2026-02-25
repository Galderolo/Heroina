import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_theme.dart';

/// Barra de título de la app: escudo dorado + "Guardianes del Hogar" y línea dorada debajo.
/// Se usa en la pantalla Personaje en lugar del ResourceHeader.
class AppTitleBar extends StatelessWidget {
  const AppTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
              color: AppColors.gold.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_rounded,
                color: AppColors.goldBright,
                size: 28,
                shadows: [
                  Shadow(
                    color: AppColors.goldBright.withValues(alpha: 0.6),
                    blurRadius: 12,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Text(
                'Guardianes del Hogar',
                style: GoogleFonts.medievalSharp(
                  color: AppColors.goldBright,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: AppColors.goldBright.withValues(alpha: 0.5),
                      blurRadius: 14,
                    ),
                    const Shadow(color: Colors.black, blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        AppDecorations.goldenDivider(),
      ],
    );
  }
}
