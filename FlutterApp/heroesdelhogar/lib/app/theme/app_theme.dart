import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colores de la app (extraidos de styles.css de la web).
class AppColors {
  AppColors._();

  static const primary = Color(0xFF0F3460);
  static const secondary = Color(0xFF16213E);
  static const accent = Color(0xFF533483);
  static const gold = Color(0xFFD4AF37);
  static const goldBright = Color(0xFFFFD700);
  static const dark = Color(0xFF0A0E27);
  static const darker = Color(0xFF050816);
  static const light = Color(0xFFE94560);
  static const blueGlow = Color(0xFF00D4FF);
  static const purpleGlow = Color(0xFFA855F7);
  static const legendary = Color(0xFFFF8C00);
  static const textPrimary = Color(0xFFE0E0E0);
  static const textSecondary = Color(0xFFA0A0A0);
  static const surface = Color(0xFF1A1A2E);
  static const cardBg = Color(0xFF16213E);
  static const darkBackground = Color(0xFF0A0E27);

  // Gradient helpers
  static const goldGradient = LinearGradient(
    colors: [gold, goldBright, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const goldButtonGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA800)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const purpleButtonGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const successGradient = LinearGradient(
    colors: [Color(0xFF28A745), Color(0xFF20C997)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const dangerGradient = LinearGradient(
    colors: [Color(0xFFE94560), Color(0xFFD63447)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xE6162140), // rgba(22, 33, 62, 0.9)
      Color(0xCC0F3460), // rgba(15, 52, 96, 0.8)
    ],
  );

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF20F3460), // rgba(15, 52, 96, 0.95)
      Color(0xF2533483), // rgba(83, 52, 131, 0.95)
    ],
  );

  static const xpBarGradient = LinearGradient(
    colors: [blueGlow, purpleGlow, blueGlow],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// Gradiente de fondo principal (igual que el body de la web).
const kBackgroundGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    AppColors.dark,
    AppColors.secondary,
    AppColors.primary,
  ],
);

/// Decoraciones reutilizables estilo Blizzard.
class AppDecorations {
  AppDecorations._();

  /// Card con borde dorado sutil y fondo gradiente.
  static BoxDecoration gameCard({
    Color? borderColor,
    double borderWidth = 1.0,
    double borderRadius = 16.0,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: AppColors.cardGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.gold.withValues(alpha: 0.3),
        width: borderWidth,
      ),
      boxShadow: boxShadow ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.08),
              blurRadius: 15,
            ),
          ],
    );
  }

  /// Card de personaje principal - borde dorado grueso y brillo.
  static BoxDecoration characterCard() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xF20F3460),
          Color(0xF2162140),
        ],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.gold, width: 2),
      boxShadow: [
        BoxShadow(
          color: AppColors.gold.withValues(alpha: 0.35),
          blurRadius: 30,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.6),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Misión en progreso - borde dorado brillante con glow pulsante.
  static BoxDecoration missionInProgress() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x26FFD700), // rgba(255, 215, 0, 0.15)
          Color(0x26FF8C00), // rgba(255, 140, 0, 0.15)
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.goldBright, width: 3),
      boxShadow: [
        BoxShadow(
          color: AppColors.goldBright.withValues(alpha: 0.45),
          blurRadius: 25,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  /// Header de sección con gradiente púrpura (tipo stats-card).
  static BoxDecoration sectionHeader({double borderRadius = 16}) {
    return BoxDecoration(
      gradient: AppColors.headerGradient,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(borderRadius),
        topRight: Radius.circular(borderRadius),
      ),
      border: Border(
        bottom: BorderSide(
          color: AppColors.gold.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
    );
  }

  /// Recurso card (oro, energía, vidas).
  static BoxDecoration resourceCard() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xB30F3460),
          Color(0xB3162140),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.gold.withValues(alpha: 0.2),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.gold.withValues(alpha: 0.12),
          blurRadius: 10,
        ),
      ],
    );
  }

  /// Badge/pill con fondo semi-transparente.
  static BoxDecoration badge(Color color) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: color.withValues(alpha: 0.3),
      ),
    );
  }

  /// Golden divider line (like the web).
  static Widget goldenDivider() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.goldBright.withValues(alpha: 0.85),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// Tema global de la app.
ThemeData buildAppTheme() {
  final baseTextTheme = GoogleFonts.quicksandTextTheme(
    ThemeData.dark().textTheme,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: baseTextTheme.copyWith(
      headlineLarge: GoogleFonts.medievalSharp(
        color: AppColors.goldBright,
        fontSize: 30,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
      headlineMedium: GoogleFonts.medievalSharp(
        color: AppColors.goldBright,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
      headlineSmall: GoogleFonts.medievalSharp(
        color: AppColors.goldBright,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        fontSize: 12,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      titleTextStyle: GoogleFonts.medievalSharp(
        color: AppColors.goldBright,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 8,
        shadowColor: AppColors.accent.withValues(alpha: 0.4),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darker,
      selectedItemColor: AppColors.goldBright,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.gold.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      elevation: 24,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.accent,
      labelStyle: baseTextTheme.bodySmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.blueGlow,
      linearTrackColor: AppColors.surface,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Botón dorado estilo Blizzard (reutilizable).
class GoldButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final EdgeInsets? padding;
  final double fontSize;

  const GoldButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.padding,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.goldButtonGradient,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.goldBright.withValues(alpha: 0.65),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.15),
              blurRadius: 1,
              offset: const Offset(0, -1),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: const Color(0xFF1A1A1A), size: 22),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text.toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w800,
                      fontSize: fontSize,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón gradiente genérico (reutilizable para colores variados).
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final Color textColor;
  final Color? borderColor;
  final IconData? icon;
  final EdgeInsets? padding;

  const GradientButton({
    super.key,
    required this.text,
    required this.gradient,
    this.onPressed,
    this.textColor = Colors.white,
    this.borderColor,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text.toUpperCase(),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
