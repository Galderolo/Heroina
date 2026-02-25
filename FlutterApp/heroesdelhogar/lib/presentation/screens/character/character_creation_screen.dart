import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/game_data.dart';
import '../../../domain/models/character_class.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/game_dialogs.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final _nameController = TextEditingController();
  CharacterClass? _selectedClass;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showGameSnackBar(context, 'Escribe el nombre de tu heroe',
          isError: true);
      return;
    }
    if (_selectedClass == null) {
      showGameSnackBar(context, 'Elige una clase', isError: true);
      return;
    }

    final game = context.read<GameProvider>();
    await game.createCharacterWithClass(
      name: name,
      classId: _selectedClass!.id,
    );
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // === Hero Frame ===
                _buildHeader(),
                const SizedBox(height: 24),

                // === Nombre ===
                _buildNameField(),
                const SizedBox(height: 28),

                // === Clases ===
                _buildClassSection(),
                const SizedBox(height: 32),

                // === Boton ===
                GoldButton(
                  text: '\u{2694}\u{FE0F}  Comenzar Aventura',
                  onPressed: _confirm,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  fontSize: 18,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
          const Text('\u{1F3F0}', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 10),
          AppDecorations.goldenDivider(),
          const SizedBox(height: 12),
          Text(
            'Crea tu Heroe',
            style: GoogleFonts.medievalSharp(
              color: AppColors.goldBright,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: AppColors.goldBright.withValues(alpha: 0.25),
                  blurRadius: 18,
                ),
                const Shadow(color: Colors.black, blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Elige un nombre y una clase para tu personaje',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          AppDecorations.goldenDivider(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xE0162140),
            Color(0xE00A0E27),
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
            '\u{1F4DC}  Nombre del Heroe',
            style: GoogleFonts.medievalSharp(
              color: AppColors.goldBright,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Escribe tu nombre de heroe...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: AppColors.dark.withValues(alpha: 0.6),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.goldBright.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.goldBright.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.goldBright,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                Icons.person_outline,
                color: AppColors.goldBright.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '\u{2694}\u{FE0F}  Elige tu Clase',
            style: GoogleFonts.medievalSharp(
              color: AppColors.goldBright,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...kClasses.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ClassCard(
                characterClass: c,
                selected: _selectedClass?.id == c.id,
                onTap: () => setState(() => _selectedClass = c),
              ),
            )),
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  final CharacterClass characterClass;
  final bool selected;
  final VoidCallback onTap;

  const _ClassCard({
    required this.characterClass,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [
                      AppColors.accent.withValues(alpha: 0.55),
                      AppColors.primary.withValues(alpha: 0.65),
                    ]
                  : [
                      const Color(0xE0162140),
                      const Color(0xE60A0E27),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.goldBright.withValues(alpha: 0.7)
                  : AppColors.goldBright.withValues(alpha: 0.1),
              width: selected ? 2.5 : 1.5,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: AppColors.goldBright.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accent.withValues(alpha: 0.4)
                      : AppColors.primary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? AppColors.goldBright.withValues(alpha: 0.5)
                        : AppColors.goldBright.withValues(alpha: 0.12),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    characterClass.icon,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      characterClass.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: selected
                            ? AppColors.goldBright
                            : AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      characterClass.description,
                      style: TextStyle(
                        color: AppColors.textPrimary.withValues(alpha: 0.75),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatBadge(
                          icon: '\u{2764}\u{FE0F}',
                          value: '${characterClass.lives}',
                          color: AppColors.light,
                        ),
                        const SizedBox(width: 10),
                        _StatBadge(
                          icon: '\u{26A1}',
                          value: '${characterClass.energy}',
                          color: Colors.amberAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Checkmark
              if (selected)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.goldBright.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: AppColors.goldBright.withValues(alpha: 0.6),
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.goldBright,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String icon;
  final String value;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
