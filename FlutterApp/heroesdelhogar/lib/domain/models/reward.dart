enum RewardCategory {
  pequena,
  media,
  grande,
  epica,
  potion;

  String get displayName {
    switch (this) {
      case RewardCategory.pequena:
        return 'Diaria';
      case RewardCategory.media:
        return 'Mágica';
      case RewardCategory.grande:
        return 'Rara';
      case RewardCategory.epica:
        return 'Épica';
      case RewardCategory.potion:
        return 'Consumible';
    }
  }

  static RewardCategory fromString(String value) {
    switch (value) {
      case 'pequena':
      case 'pequeña':
        return RewardCategory.pequena;
      case 'media':
        return RewardCategory.media;
      case 'grande':
        return RewardCategory.grande;
      case 'epica':
        return RewardCategory.epica;
      case 'potion':
        return RewardCategory.potion;
      default:
        return RewardCategory.pequena;
    }
  }
}

enum PotionEffect {
  restoreLife,
  restoreEnergy;

  static PotionEffect? fromString(String? value) {
    switch (value) {
      case 'restoreLife':
        return PotionEffect.restoreLife;
      case 'restoreEnergy':
        return PotionEffect.restoreEnergy;
      default:
        return null;
    }
  }
}

class Reward {
  final int id;
  final String name;
  final String description;
  final int price;
  final RewardCategory category;
  final String icon;
  final int requiredLevel;
  final PotionEffect? effect;
  final int? value;
  final int? cooldownHours;
  final bool isCustom;

  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.icon,
    this.requiredLevel = 1,
    this.effect,
    this.value,
    this.cooldownHours,
    this.isCustom = false,
  });

  bool get isPotion => category == RewardCategory.potion;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category == RewardCategory.pequena
            ? 'pequeña'
            : category.name,
        'icon': icon,
        'requiredLevel': requiredLevel,
        if (effect != null) 'effect': effect!.name,
        if (value != null) 'value': value,
        if (cooldownHours != null) 'cooldownHours': cooldownHours,
        'isCustom': isCustom,
      };

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toInt(),
      category: RewardCategory.fromString(json['category'] as String),
      icon: json['icon'] as String,
      requiredLevel: (json['requiredLevel'] as num?)?.toInt() ?? 1,
      effect: PotionEffect.fromString(json['effect'] as String?),
      value: (json['value'] as num?)?.toInt(),
      cooldownHours: (json['cooldownHours'] as num?)?.toInt(),
      isCustom: (json['isCustom'] as bool?) ?? false,
    );
  }
}

class PurchasedRewardRecord {
  final int rewardId;
  final DateTime date;
  final int priceSpent;

  const PurchasedRewardRecord({
    required this.rewardId,
    required this.date,
    required this.priceSpent,
  });

  Map<String, dynamic> toJson() => {
        'rewardId': rewardId,
        'date': date.toIso8601String(),
        'priceSpent': priceSpent,
      };

  factory PurchasedRewardRecord.fromJson(Map<String, dynamic> json) {
    return PurchasedRewardRecord(
      rewardId: (json['rewardId'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      priceSpent: (json['priceSpent'] as num).toInt(),
    );
  }
}

class InventoryPotion {
  final int id;
  final int quantity;

  const InventoryPotion({required this.id, required this.quantity});

  InventoryPotion copyWith({int? quantity}) =>
      InventoryPotion(id: id, quantity: quantity ?? this.quantity);

  Map<String, dynamic> toJson() => {'id': id, 'quantity': quantity};

  factory InventoryPotion.fromJson(Map<String, dynamic> json) {
    return InventoryPotion(
      id: (json['id'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );
  }
}
