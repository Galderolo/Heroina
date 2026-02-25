import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_theme.dart';
import '../../../domain/models/mission.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/resource_header.dart';
import '../../widgets/common/game_dialogs.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  MissionType? _selectedType;
  List<Mission> _allMissions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    final game = context.read<GameProvider>();
    final missions = await game.getAllMissions();
    if (mounted) {
      setState(() {
        _allMissions = missions;
        _loading = false;
      });
    }
  }

  List<Mission> get _filteredMissions {
    final game = context.read<GameProvider>();
    return game.filterMissions(_selectedType, _allMissions);
  }

  /// Colores por tipo de misión
  static Color _typeColor(MissionType? type) {
    switch (type) {
      case MissionType.diaria:
        return const Color(0xFF4FC3F7); // Azul
      case MissionType.ayuda:
        return const Color(0xFFFFD700); // Amarillo
      case MissionType.epica:
        return const Color(0xFFA855F7); // Morado
      case null:
        return AppColors.goldBright;
    }
  }

  /// Check if a mission is currently active
  bool _isMissionActive(int missionId) {
    final game = context.read<GameProvider>();
    return game.state.activeMissions.any((m) => m.missionId == missionId);
  }

  /// Get the active mission data for a given mission id
  ActiveMission? _getActiveMission(int missionId) {
    final game = context.read<GameProvider>();
    try {
      return game.state.activeMissions
          .firstWhere((m) => m.missionId == missionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Resource header
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ResourceHeader(),
          ),
          const SizedBox(height: 14),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '\u{2694}\u{FE0F}  Tablero de Misiones',
                  style: GoogleFonts.medievalSharp(
                    color: AppColors.goldBright,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Filtros con scroll horizontal (funciona con ratón en web)
          ClipRect(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.hardEdge,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Todas',
                      selected: _selectedType == null,
                      typeColor: AppColors.goldBright,
                      onTap: () => setState(() => _selectedType = null),
                    ),
                    const SizedBox(width: 8),
                    ...MissionType.values.map((type) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: type.displayName,
                            selected: _selectedType == type,
                            typeColor: _typeColor(type),
                            onTap: () =>
                                setState(() => _selectedType = type),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Lista
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.goldBright),
                    ),
                  )
                : Consumer<GameProvider>(
                    builder: (context, game, _) {
                      final missions = _filteredMissions;
                      return RefreshIndicator(
                        onRefresh: _loadMissions,
                        child: _selectedType == null
                            ? _buildSectionedList(missions, game)
                            : _buildSimpleList(missions, game,
                                _selectedType),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionedList(List<Mission> all, GameProvider game) {
    final diarias =
        all.where((m) => m.type == MissionType.diaria).toList();
    final ayuda = all.where((m) => m.type == MissionType.ayuda).toList();
    final epicas =
        all.where((m) => m.type == MissionType.epica).toList();

    final List<Widget> items = [];

    void addSection(MissionType type, List<Mission> missions) {
      if (missions.isEmpty) return;
      items.add(_SectionHeader(
        typeColor: _typeColor(type),
        label: type.displayName,
      ));
      for (final m in missions) {
        items.add(_buildMissionCard(m, game));
      }
    }

    addSection(MissionType.diaria, diarias);
    addSection(MissionType.ayuda, ayuda);
    addSection(MissionType.epica, epicas);
    items.add(const SizedBox(height: 80));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: items,
    );
  }

  Widget _buildSimpleList(
      List<Mission> missions, GameProvider game, MissionType? type) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: missions.length + 2,
      itemBuilder: (ctx, idx) {
        if (idx == 0) {
          return _SectionHeader(
            typeColor: _typeColor(type),
            label: type?.displayName ?? 'Todas',
          );
        }
        if (idx == missions.length + 1) return const SizedBox(height: 80);
        return _buildMissionCard(missions[idx - 1], game);
      },
    );
  }

  Widget _buildMissionCard(Mission mission, GameProvider game) {
    final isActive = _isMissionActive(mission.id);
    final activeMission = isActive ? _getActiveMission(mission.id) : null;
    final maxReached = game.state.activeMissions.length >= 3;
    return _MissionCard(
      mission: mission,
      isActive: isActive,
      activeMission: activeMission,
      isStartBlocked: !isActive && maxReached,
      onStart: () => _startMission(mission),
      onComplete: isActive ? () => _completeMission(mission, game) : null,
      onFail: isActive ? () => _failMission(mission, game) : null,
      onCancel: isActive ? () => _cancelMission(mission, game) : null,
    );
  }

  Future<void> _startMission(Mission mission) async {
    final game = context.read<GameProvider>();
    final result = await game.startMission(mission.id);
    if (mounted) {
      showGameSnackBar(
        context,
        result.success
            ? '\u{2694}\u{FE0F} Mision "${mission.name}" iniciada!'
            : result.message,
        isError: !result.success,
      );
      if (result.success) {
        setState(() {});
      }
    }
  }

  Future<void> _completeMission(Mission mission, GameProvider game) async {
    final result = await game.completeActiveMission(mission.id);
    if (mounted) {
      if (result.success) {
        await showMissionCompleteDialog(
          context,
          missionName: result.data['mission']?.name ?? mission.name,
          missionIcon: mission.icon,
          xpGained: result.data['xpGained'] ?? 0,
          goldGained: result.data['goldGained'] ?? 0,
        );
        if (result.data['leveledUp'] == true && mounted) {
          await showLevelUpDialog(
            context,
            newLevel: result.data['newLevel'],
            title: result.data['title'] ?? '',
          );
        }
        setState(() {});
      } else {
        showGameSnackBar(context, result.message, isError: true);
      }
    }
  }

  Future<void> _failMission(Mission mission, GameProvider game) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Fallar Mision',
      message: 'Perderas 1 vida. Continuar?',
      confirmText: 'Fallar',
      confirmColor: Colors.red,
    );
    if (confirm && mounted) {
      final result = await game.failActiveMission(mission.id);
      if (mounted) {
        showGameSnackBar(context, result.message, isError: !result.success);
        setState(() {});
      }
    }
  }

  Future<void> _cancelMission(Mission mission, GameProvider game) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Cancelar Mision',
      message: 'Cancelar esta mision sin penalizacion?',
      confirmText: 'Cancelar Mision',
    );
    if (confirm && mounted) {
      await game.cancelActiveMission(mission.id);
      if (mounted) setState(() {});
    }
  }
}

// === Filter Chip ===
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color typeColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.typeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(colors: [
                    typeColor.withValues(alpha: 0.35),
                    typeColor.withValues(alpha: 0.15),
                  ])
                : null,
            color: selected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? typeColor.withValues(alpha: 0.7)
                  : typeColor.withValues(alpha: 0.2),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: typeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? typeColor : AppColors.textSecondary,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// === Section Header ===
class _SectionHeader extends StatelessWidget {
  final Color typeColor;
  final String label;

  const _SectionHeader({required this.typeColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: typeColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  typeColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === Mission Card ===
class _MissionCard extends StatelessWidget {
  final Mission mission;
  final bool isActive;
  final bool isStartBlocked;
  final ActiveMission? activeMission;
  final VoidCallback onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onFail;
  final VoidCallback? onCancel;

  const _MissionCard({
    required this.mission,
    required this.isActive,
    this.isStartBlocked = false,
    this.activeMission,
    required this.onStart,
    this.onComplete,
    this.onFail,
    this.onCancel,
  });

  Color get _typeColor {
    switch (mission.type) {
      case MissionType.diaria:
        return const Color(0xFF4FC3F7); // Azul
      case MissionType.ayuda:
        return const Color(0xFFFFD700); // Amarillo dorado
      case MissionType.epica:
        return const Color(0xFFA855F7); // Morado épico
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [
                    AppColors.accent.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.45),
                  ]
                : isStartBlocked
                    ? [
                        const Color(0xE00D1020),
                        const Color(0xE6080B18),
                      ]
                    : [
                        const Color(0xE0162140),
                        const Color(0xE60A0E27),
                      ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppColors.blueGlow.withValues(alpha: 0.7)
                : isStartBlocked
                    ? Colors.grey.withValues(alpha: 0.2)
                    : AppColors.blueGlow.withValues(alpha: 0.6),
            width: isActive ? 2 : 1.5,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.15),
                blurRadius: 18,
                spreadRadius: 2,
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
            Row(
              children: [
                // Icon container con gradiente de rareza
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _typeColor.withValues(alpha: 0.35),
                        _typeColor.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _typeColor.withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _typeColor.withValues(alpha: 0.25),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(mission.icon,
                        style: const TextStyle(fontSize: 26)),
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
                              mission.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isActive
                                    ? AppColors.goldBright
                                    : AppColors.textPrimary,
                                fontSize: 16,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            _ActiveBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        mission.description,
                        style: TextStyle(
                          color: AppColors.textPrimary.withValues(alpha: 0.7),
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tags row
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Badge(
                  text: '+${mission.xp} XP',
                  color: Colors.green.shade300,
                ),
                _Badge(
                  text: '+${mission.gold} \u{1FA99}',
                  color: AppColors.goldBright,
                ),
                _Badge(
                  text: mission.type.displayName,
                  color: _typeColor,
                ),
                if (mission.isCustom)
                  _Badge(
                    text: '\u{2728} Custom',
                    color: AppColors.purpleGlow,
                  ),
                if (isActive && activeMission != null) ...[
                  _TimeBadge(startDate: activeMission!.startDate),
                ],
              ],
            ),

            // Action buttons (different depending on active state)
            if (isActive) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.goldBright.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _MissionActionButton(
                      label: 'Cancelar',
                      onPressed: onCancel,
                      color: AppColors.textSecondary,
                      outlined: true,
                    ),
                    const SizedBox(width: 6),
                    _MissionActionButton(
                      label: '\u{274C} Fallar',
                      onPressed: onFail,
                      color: AppColors.light,
                    ),
                    const SizedBox(width: 6),
                    _MissionActionButton(
                      label: '\u{2705} Completar',
                      onPressed: onComplete,
                      color: Colors.green.shade400,
                      filled: true,
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.goldBright.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isStartBlocked)
                      // Botón deshabilitado: límite de misiones alcanzado
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline,
                                size: 14,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.5)),
                            const SizedBox(width: 6),
                            Text(
                              'Límite alcanzado',
                              style: TextStyle(
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      GradientButton(
                        text: '\u{25B6} INICIAR MISIÓN (-1 \u{26A1})',
                        onPressed: onStart,
                        gradient: AppColors.purpleButtonGradient,
                        textColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// === Active badge ===
class _ActiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.6),
            const Color(0xFF7C3AED).withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColors.goldBright.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.25),
            blurRadius: 6,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_top, size: 11, color: AppColors.goldBright),
          SizedBox(width: 3),
          Text(
            'EN CURSO',
            style: TextStyle(
              color: AppColors.goldBright,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// === Time badge ===
class _TimeBadge extends StatelessWidget {
  final DateTime startDate;
  const _TimeBadge({required this.startDate});

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(startDate);
    final String timeStr;
    if (elapsed.inMinutes < 60) {
      timeStr = '${elapsed.inMinutes}m';
    } else {
      timeStr = '${(elapsed.inMinutes / 60).toStringAsFixed(1)}h';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
              size: 12,
              color: AppColors.blueGlow.withValues(alpha: 0.8)),
          const SizedBox(width: 3),
          Text(
            timeStr,
            style: TextStyle(
              color: AppColors.blueGlow,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// === Generic badge ===
class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// === Mission action button ===
class _MissionActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool outlined;
  final bool filled;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  const _MissionActionButton({
    required this.label,
    required this.onPressed,
    required this.color,
    this.outlined = false,
    this.filled = false,
    this.padding,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: filled ? color.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: outlined
                  ? color.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fontSize ?? 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
