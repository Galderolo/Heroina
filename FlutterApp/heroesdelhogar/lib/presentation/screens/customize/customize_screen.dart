import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/game_data.dart';
import '../../../core/utils/game_calculations.dart';
import '../../../domain/models/mission.dart';
import '../../../domain/models/reward.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/game_dialogs.dart';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '\u{2699}\u{FE0F}  Personalizar',
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
          // Custom styled tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.dark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.goldBright.withValues(alpha: 0.1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.goldBright,
              indicatorWeight: 2.5,
              labelColor: AppColors.goldBright,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '\u{2694}\u{FE0F} Misiones'),
                Tab(text: '\u{1F381} Recompensas'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _CustomMissionsTab(),
                _CustomRewardsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Custom Missions Tab =====

class _CustomMissionsTab extends StatefulWidget {
  const _CustomMissionsTab();

  @override
  State<_CustomMissionsTab> createState() => _CustomMissionsTabState();
}

class _CustomMissionsTabState extends State<_CustomMissionsTab> {
  List<Mission> _customMissions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final game = context.read<GameProvider>();
    final all = await game.getAllMissions();
    if (mounted) {
      setState(() {
        _customMissions = all.where((m) => m.isCustom).toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: GoldButton(
            text: '\u{2795}  Nueva Mision',
            onPressed: () => _showMissionEditor(context),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.goldBright),
                  ),
                )
              : _customMissions.isEmpty
                  ? _buildEmptyState(
                      '\u{1F4DC}', 'No hay misiones personalizadas',
                      'Crea misiones adaptadas a tus tareas!')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _customMissions.length + 1,
                      itemBuilder: (ctx, idx) {
                        if (idx == _customMissions.length) {
                          return const SizedBox(height: 80);
                        }
                        final m = _customMissions[idx];
                        return _CustomItemCard(
                          icon: m.icon,
                          name: m.name,
                          subtitle:
                              '${m.type.displayName}  \u{2022}  +${m.xp} XP, +${m.gold} oro',
                          onDelete: () => _deleteMission(m),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Future<void> _deleteMission(Mission m) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Eliminar Mision',
      message: 'Eliminar "${m.name}"?',
      confirmText: 'Eliminar',
      confirmColor: Colors.red,
    );
    if (confirm && context.mounted) {
      final game = context.read<GameProvider>();
      await game.deleteCustomMission(m.id);
      _load();
    }
  }

  Future<void> _showMissionEditor(BuildContext context) async {
    final result = await showDialog<Mission>(
      context: context,
      builder: (ctx) => const _MissionEditorDialog(),
    );
    if (result != null && mounted) {
      final game = context.read<GameProvider>();
      await game.addCustomMission(result);
      _load();
    }
  }
}

// ===== Mission Editor Dialog =====

class _MissionEditorDialog extends StatefulWidget {
  const _MissionEditorDialog();

  @override
  State<_MissionEditorDialog> createState() => _MissionEditorDialogState();
}

class _MissionEditorDialogState extends State<_MissionEditorDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  MissionType _type = MissionType.diaria;
  String _icon = kAvailableIcons.first;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final values = getStandardMissionValues(_type);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '\u{2694}\u{FE0F}  Nueva Mision',
                  style: GoogleFonts.medievalSharp(
                    color: AppColors.goldBright,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                AppDecorations.goldenDivider(),
                const SizedBox(height: 18),

                // Name field
                _buildTextField(_nameController, 'Nombre de la mision'),
                const SizedBox(height: 12),
                _buildTextField(_descController, 'Descripcion'),
                const SizedBox(height: 16),

                // Type dropdown
                DropdownButtonFormField<MissionType>(
                  initialValue: _type,
                  decoration: _dropdownDecoration('Tipo'),
                  items: MissionType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.displayName),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _type = v);
                  },
                  dropdownColor: AppColors.cardBg,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),

                // Icon picker
                Text(
                  'Icono',
                  style: TextStyle(
                    color: AppColors.goldBright.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildIconPicker(),
                const SizedBox(height: 14),

                // Reward info
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.blueGlow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.blueGlow.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Recompensa:  +${values.xp} XP  \u{2022}  +${values.gold} oro',
                        style: TextStyle(
                          color: AppColors.blueGlow,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppDecorations.goldenDivider(),
                const SizedBox(height: 16),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
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
                            child: const Text(
                              'Cancelar',
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
                      child: GoldButton(
                        text: 'Crear',
                        onPressed: _submit,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) return;
    final values = getStandardMissionValues(_type);
    Navigator.of(context).pop(Mission(
      id: 0,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      type: _type,
      xp: values.xp,
      gold: values.gold,
      icon: _icon,
      isCustom: true,
    ));
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: AppColors.dark.withValues(alpha: 0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.goldBright.withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.goldBright.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.goldBright, width: 1.5),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.7),
      ),
      filled: true,
      fillColor: AppColors.dark.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.goldBright.withValues(alpha: 0.15),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.goldBright.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.goldBright, width: 1.5),
      ),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: kAvailableIcons
          .map((i) => GestureDetector(
                onTap: () => setState(() => _icon = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _icon == i
                        ? AppColors.accent.withValues(alpha: 0.5)
                        : AppColors.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: _icon == i
                        ? Border.all(
                            color: AppColors.goldBright.withValues(alpha: 0.6),
                            width: 2,
                          )
                        : Border.all(
                            color: AppColors.goldBright.withValues(alpha: 0.08),
                          ),
                    boxShadow: _icon == i
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.goldBright.withValues(alpha: 0.15),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(i, style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ===== Custom Rewards Tab =====

class _CustomRewardsTab extends StatefulWidget {
  const _CustomRewardsTab();

  @override
  State<_CustomRewardsTab> createState() => _CustomRewardsTabState();
}

class _CustomRewardsTabState extends State<_CustomRewardsTab> {
  List<Reward> _customRewards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final game = context.read<GameProvider>();
    final all = await game.getAllRewards();
    if (mounted) {
      setState(() {
        _customRewards = all.where((r) => r.isCustom).toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: GoldButton(
            text: '\u{2795}  Nueva Recompensa',
            onPressed: () => _showRewardEditor(context),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.goldBright),
                  ),
                )
              : _customRewards.isEmpty
                  ? _buildEmptyState(
                      '\u{1F381}', 'No hay recompensas personalizadas',
                      'Crea recompensas a tu medida!')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _customRewards.length + 1,
                      itemBuilder: (ctx, idx) {
                        if (idx == _customRewards.length) {
                          return const SizedBox(height: 80);
                        }
                        final r = _customRewards[idx];
                        return _CustomItemCard(
                          icon: r.icon,
                          name: r.name,
                          subtitle:
                              '${r.category.displayName}  \u{2022}  ${r.price} oro',
                          onDelete: () => _deleteReward(r),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Future<void> _deleteReward(Reward r) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Eliminar Recompensa',
      message: 'Eliminar "${r.name}"?',
      confirmText: 'Eliminar',
      confirmColor: Colors.red,
    );
    if (confirm && context.mounted) {
      final game = context.read<GameProvider>();
      await game.deleteCustomReward(r.id);
      _load();
    }
  }

  Future<void> _showRewardEditor(BuildContext context) async {
    final result = await showDialog<Reward>(
      context: context,
      builder: (ctx) => const _RewardEditorDialog(),
    );
    if (result != null && mounted) {
      final game = context.read<GameProvider>();
      await game.addCustomReward(result);
      _load();
    }
  }
}

// ===== Reward Editor Dialog =====

class _RewardEditorDialog extends StatefulWidget {
  const _RewardEditorDialog();

  @override
  State<_RewardEditorDialog> createState() => _RewardEditorDialogState();
}

class _RewardEditorDialogState extends State<_RewardEditorDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  RewardCategory _category = RewardCategory.pequena;
  String _icon = kAvailableIcons.first;

  static const _allowedCategories = [
    RewardCategory.pequena,
    RewardCategory.media,
    RewardCategory.grande,
    RewardCategory.epica,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = getStandardRewardPrice(_category);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '\u{1F381}  Nueva Recompensa',
                  style: GoogleFonts.medievalSharp(
                    color: AppColors.goldBright,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                AppDecorations.goldenDivider(),
                const SizedBox(height: 18),

                _buildTextField(_nameController, 'Nombre'),
                const SizedBox(height: 12),
                _buildTextField(_descController, 'Descripcion'),
                const SizedBox(height: 16),

                DropdownButtonFormField<RewardCategory>(
                  initialValue: _category,
                  decoration: _dropdownDecoration('Categoria'),
                  items: _allowedCategories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.displayName),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                  dropdownColor: AppColors.cardBg,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),

                Text(
                  'Icono',
                  style: TextStyle(
                    color: AppColors.goldBright.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildIconPicker(),
                const SizedBox(height: 14),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.goldBright.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.goldBright.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\u{1FA99}  Precio: $price oro',
                        style: TextStyle(
                          color: AppColors.goldBright,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppDecorations.goldenDivider(),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
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
                            child: const Text(
                              'Cancelar',
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
                      child: GoldButton(
                        text: 'Crear',
                        onPressed: _submit,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) return;
    final price = getStandardRewardPrice(_category);
    Navigator.of(context).pop(Reward(
      id: 0,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: price,
      category: _category,
      icon: _icon,
      isCustom: true,
    ));
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: AppColors.dark.withValues(alpha: 0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.goldBright.withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.goldBright.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.goldBright, width: 1.5),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.7),
      ),
      filled: true,
      fillColor: AppColors.dark.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.goldBright.withValues(alpha: 0.15),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.goldBright.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.goldBright, width: 1.5),
      ),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: kAvailableIcons
          .map((i) => GestureDetector(
                onTap: () => setState(() => _icon = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _icon == i
                        ? AppColors.accent.withValues(alpha: 0.5)
                        : AppColors.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: _icon == i
                        ? Border.all(
                            color: AppColors.goldBright.withValues(alpha: 0.6),
                            width: 2,
                          )
                        : Border.all(
                            color: AppColors.goldBright.withValues(alpha: 0.08),
                          ),
                    boxShadow: _icon == i
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.goldBright.withValues(alpha: 0.15),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(i, style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ===== Shared Widgets =====

Widget _buildEmptyState(String emoji, String title, String subtitle) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.85),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _CustomItemCard extends StatelessWidget {
  final String icon;
  final String name;
  final String subtitle;
  final VoidCallback onDelete;

  const _CustomItemCard({
    required this.icon,
    required this.name,
    required this.subtitle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xE0162140),
              Color(0xE60A0E27),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.goldBright.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
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
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
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
                onPressed: onDelete,
                tooltip: 'Eliminar',
                constraints: const BoxConstraints(
                  minWidth: 38,
                  minHeight: 38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
