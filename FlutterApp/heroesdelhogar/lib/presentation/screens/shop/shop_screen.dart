import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_theme.dart';
import '../../../domain/models/reward.dart';
import '../../../domain/services/game_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/common/resource_header.dart';
import '../../widgets/common/game_dialogs.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  RewardCategory? _selectedCategory;
  List<Reward> _allRewards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    final game = context.read<GameProvider>();
    final rewards = await game.getAllRewards();
    if (mounted) {
      setState(() {
        _allRewards = rewards;
        _loading = false;
      });
    }
  }

  List<Reward> get _filteredRewards {
    if (_selectedCategory == null) return _allRewards;
    return _allRewards.where((r) => r.category == _selectedCategory).toList();
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
                  '\u{1F3EA}  Tienda de Recompensas',
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

          // Filtros con scroll horizontal (incluye drag con ratón en web)
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.hardEdge,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Todas',
                    selected: _selectedCategory == null,
                    categoryColor: AppColors.goldBright,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  const SizedBox(width: 8),
                  ...RewardCategory.values.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: cat.displayName,
                          selected: _selectedCategory == cat,
                          categoryColor: _rarityColor(cat),
                          onTap: () =>
                              setState(() => _selectedCategory = cat),
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
                : RefreshIndicator(
                    onRefresh: _loadRewards,
                    child: _selectedCategory == null
                        ? _buildSectionedList()
                        : _buildSimpleList(_filteredRewards),
                  ),
          ),
        ],
      ),
    );
  }

  /// Paleta de colores estilo ARPG (Diablo-like) por rareza
  static Color _rarityColor(RewardCategory cat) {
    switch (cat) {
      case RewardCategory.pequena:
        return const Color(0xFF9E9E9E); // Gris - común
      case RewardCategory.media:
        return const Color(0xFF4FC3F7); // Azul claro - mágico
      case RewardCategory.grande:
        return const Color(0xFFFFD700); // Oro - raro
      case RewardCategory.epica:
        return const Color(0xFFA855F7); // Morado - épico/legendario
      case RewardCategory.potion:
        return const Color(0xFF4CAF50); // Verde - consumible
    }
  }

  Widget _buildSimpleList(List<Reward> rewards) {
    // Cabecera de sección según la categoría filtrada
    final isPotion = _selectedCategory == RewardCategory.potion;
    final header = _SectionHeader(
      icon: isPotion ? '\u{2728}' : '\u{1F3C6}',
      label: isPotion ? 'Consumibles' : 'Recompensas',
      subtitle: isPotion
          ? 'Pociones y objetos de un solo uso'
          : '${_selectedCategory?.displayName ?? ''} \u2022 Caprichos y premios para ti',
    );

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: rewards.length + 2, // +1 header, +1 spacer
      itemBuilder: (ctx, idx) {
        if (idx == 0) return header;
        if (idx == rewards.length + 1) return const SizedBox(height: 80);
        final reward = rewards[idx - 1];
        return _RewardCard(
          reward: reward,
          onPurchase: () => _buyReward(reward),
        );
      },
    );
  }

  Widget _buildSectionedList() {
    final consumables = _allRewards.where((r) => r.isPotion).toList();
    final rewards = _allRewards.where((r) => !r.isPotion).toList();

    // Construimos los items con cabeceras de sección
    final List<Widget> items = [];

    if (consumables.isNotEmpty) {
      items.add(_SectionHeader(
        icon: '\u{2728}',
        label: 'Consumibles',
        subtitle: 'Pociones y objetos de un solo uso',
      ));
      for (final r in consumables) {
        items.add(_RewardCard(reward: r, onPurchase: () => _buyReward(r)));
      }
    }

    if (rewards.isNotEmpty) {
      items.add(_SectionHeader(
        icon: '\u{1F3C6}',
        label: 'Recompensas',
        subtitle: 'Caprichos y premios para ti',
      ));
      for (final r in rewards) {
        items.add(_RewardCard(reward: r, onPurchase: () => _buyReward(r)));
      }
    }

    items.add(const SizedBox(height: 80));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: items,
    );
  }

  Future<void> _buyReward(Reward reward) async {
    final game = context.read<GameProvider>();

    // Cooldown check
    final cooldown = game.getRewardCooldownInfo(reward.id);
    if (cooldown.onCooldown) {
      if (mounted) {
        showGameSnackBar(
          context,
          'Disponible en ${cooldown.hoursRemaining}h ${cooldown.minutesRemaining}m',
          isError: true,
        );
      }
      return;
    }

    final confirm = await showConfirmDialog(
      context,
      title: 'Comprar Recompensa',
      message: 'Comprar "${reward.name}" por ${reward.price} oro?',
      confirmText: 'Comprar',
    );

    if (!confirm) return;

    GameResult result;
    if (reward.isPotion) {
      result = await game.purchasePotion(reward.id);
    } else {
      result = await game.purchaseReward(reward.id);
    }

    if (mounted) {
      if (result.success) {
        await showRewardDialog(
          context,
          rewardName: reward.name,
          rewardIcon: reward.icon,
        );
        _loadRewards();
      } else {
        showGameSnackBar(context, result.message, isError: true);
      }
    }
  }
}

// === Section Header ===
class _SectionHeader extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xE60F3460), Color(0xE6162140)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.goldBright.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.medievalSharp(
                      color: AppColors.goldBright,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === Filter Chip ===
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color categoryColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.categoryColor,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [
                      categoryColor.withValues(alpha: 0.8),
                      categoryColor.withValues(alpha: 0.5),
                    ],
                  )
                : null,
            color: selected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? categoryColor
                  : categoryColor.withValues(alpha: 0.3),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: categoryColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : categoryColor,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// === Reward Card ===
class _RewardCard extends StatelessWidget {
  final Reward reward;
  final VoidCallback onPurchase;

  const _RewardCard({required this.reward, required this.onPurchase});

  /// Colores ARPG (Diablo-like) por rareza
  Color get _rarityColor {
    switch (reward.category) {
      case RewardCategory.pequena:
        return const Color(0xFF9E9E9E); // Gris - común
      case RewardCategory.media:
        return const Color(0xFF4FC3F7); // Azul - mágico
      case RewardCategory.grande:
        return const Color(0xFFFFD700); // Oro - raro
      case RewardCategory.epica:
        return const Color(0xFFA855F7); // Morado - épico/legendario
      case RewardCategory.potion:
        return const Color(0xFF4CAF50); // Verde - consumible
    }
  }


  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final character = game.state.character;
    final locked = character.level < reward.requiredLevel;
    final cooldown = game.getRewardCooldownInfo(reward.id);
    final canAfford = character.gold >= reward.price;
    final isDisabled = locked || cooldown.onCooldown;

    final rarity = _rarityColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: locked ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xE0162140),
                const Color(0xE60A0E27),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: locked
                  ? Colors.grey.withValues(alpha: 0.15)
                  : rarity.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
              if (!locked)
                BoxShadow(
                  color: rarity.withValues(alpha: 0.08),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon container con gradiente de rareza ARPG
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          rarity.withValues(alpha: 0.35),
                          rarity.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: rarity.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: rarity.withValues(alpha: 0.25),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(reward.icon,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          reward.description,
                          style: TextStyle(
                            color:
                                AppColors.textPrimary.withValues(alpha: 0.7),
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
                  _PriceBadge(
                    price: reward.price,
                    canAfford: canAfford,
                  ),
                  _Badge(
                    text: reward.category.displayName,
                    color: rarity,
                  ),
                  if (locked)
                    _Badge(
                      text: '\u{1F512} Lv ${reward.requiredLevel}',
                      color: Colors.red,
                    ),
                  if (cooldown.onCooldown)
                    _Badge(
                      text:
                          '\u{23F3} ${cooldown.hoursRemaining}h ${cooldown.minutesRemaining}m',
                      color: Colors.orangeAccent,
                    ),
                  if (reward.isCustom)
                    _Badge(
                      text: '\u{2728} Custom',
                      color: AppColors.purpleGlow,
                    ),
                  if (reward.isPotion)
                    _Badge(
                      text: '\u{1F9EA} Pocion',
                      color: AppColors.purpleGlow,
                    ),
                ],
              ),

              // Buy button
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
                    _BuyButton(
                      locked: locked,
                      onCooldown: cooldown.onCooldown,
                      hoursRemaining: cooldown.hoursRemaining,
                      minutesRemaining: cooldown.minutesRemaining,
                      price: reward.price,
                      canAfford: canAfford,
                      requiredLevel: reward.requiredLevel,
                      onTap: isDisabled ? null : onPurchase,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// === Buy Button ===
class _BuyButton extends StatelessWidget {
  final bool locked;
  final bool onCooldown;
  final int hoursRemaining;
  final int minutesRemaining;
  final int price;
  final bool canAfford;
  final int requiredLevel;
  final VoidCallback? onTap;

  const _BuyButton({
    required this.locked,
    required this.onCooldown,
    required this.hoursRemaining,
    required this.minutesRemaining,
    required this.price,
    required this.canAfford,
    required this.requiredLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar estado y apariencia
    final Color btnColor;
    final String label;
    final String emoji;

    if (locked) {
      btnColor = Colors.grey;
      emoji = '\u{1F512}';
      label = 'Lv $requiredLevel';
    } else if (onCooldown) {
      btnColor = Colors.orangeAccent;
      emoji = '\u{23F3}';
      label = '${hoursRemaining}h ${minutesRemaining}m';
    } else if (!canAfford) {
      btnColor = Colors.red.shade400;
      emoji = '\u{1FA99}';
      label = '$price';
    } else {
      btnColor = AppColors.goldBright;
      emoji = '\u{1FA99}';
      label = '$price';
    }

    final isDisabled = onTap == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 90),
          child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            gradient: isDisabled
                ? null
                : LinearGradient(
                    colors: [
                      btnColor.withValues(alpha: 0.25),
                      btnColor.withValues(alpha: 0.12),
                    ],
                  ),
            color: isDisabled ? AppColors.surface.withValues(alpha: 0.4) : null,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: btnColor.withValues(alpha: isDisabled ? 0.25 : 0.6),
              width: 1.5,
            ),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: btnColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: btnColor.withValues(alpha: isDisabled ? 0.5 : 1.0),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
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

// === Price badge ===
class _PriceBadge extends StatelessWidget {
  final int price;
  final bool canAfford;

  const _PriceBadge({required this.price, required this.canAfford});

  @override
  Widget build(BuildContext context) {
    final color = canAfford ? AppColors.goldBright : Colors.red.shade300;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('\u{1FA99}', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 3),
          Text(
            '$price',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
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
