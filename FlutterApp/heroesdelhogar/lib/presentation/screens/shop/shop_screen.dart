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

          // Filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Todas',
                    selected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  ...RewardCategory.values.map((cat) => _FilterChip(
                        label: cat.displayName,
                        selected: _selectedCategory == cat,
                        onTap: () => setState(() => _selectedCategory = cat),
                      )),
                ],
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
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredRewards.length + 1,
                      itemBuilder: (ctx, idx) {
                        if (idx == _filteredRewards.length) {
                          return const SizedBox(height: 80);
                        }
                        final reward = _filteredRewards[idx];
                        return _RewardCard(
                          reward: reward,
                          onPurchase: () => _buyReward(reward),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
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

// === Filter Chip ===
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      colors: [AppColors.accent, Color(0xFF7C3AED)],
                    )
                  : null,
              color: selected ? null : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? AppColors.goldBright.withValues(alpha: 0.5)
                    : AppColors.goldBright.withValues(alpha: 0.1),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
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

  Color get _categoryColor {
    switch (reward.category) {
      case RewardCategory.pequena:
        return Colors.cyan;
      case RewardCategory.media:
        return Colors.green;
      case RewardCategory.grande:
        return Colors.orange;
      case RewardCategory.epica:
        return AppColors.legendary;
      case RewardCategory.potion:
        return AppColors.purpleGlow;
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
                  : AppColors.goldBright.withValues(alpha: 0.1),
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
              Row(
                children: [
                  // Icon container
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _categoryColor.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(reward.icon,
                          style: const TextStyle(fontSize: 26)),
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
                    color: _categoryColor,
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
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isDisabled ? null : onPurchase,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isDisabled
                                ? null
                                : LinearGradient(
                                    colors: [
                                      AppColors.goldBright
                                          .withValues(alpha: 0.2),
                                      AppColors.gold.withValues(alpha: 0.15),
                                    ],
                                  ),
                            color: isDisabled
                                ? AppColors.surface.withValues(alpha: 0.5)
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDisabled
                                  ? Colors.grey.withValues(alpha: 0.3)
                                  : AppColors.goldBright
                                      .withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                reward.isPotion
                                    ? Icons.science
                                    : Icons.shopping_cart,
                                size: 16,
                                color: isDisabled
                                    ? AppColors.textSecondary
                                    : AppColors.goldBright,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                locked
                                    ? 'Bloqueado'
                                    : cooldown.onCooldown
                                        ? 'En enfriamiento'
                                        : 'Comprar',
                                style: TextStyle(
                                  color: isDisabled
                                      ? AppColors.textSecondary
                                      : AppColors.goldBright,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
