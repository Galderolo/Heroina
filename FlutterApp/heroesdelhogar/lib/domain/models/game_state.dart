import 'character.dart';
import 'mission.dart';
import 'reward.dart';

class GameHistory {
  final List<CompletedMissionRecord> completedMissions;
  final List<PurchasedRewardRecord> purchasedRewards;
  final List<int> levelsReached;

  const GameHistory({
    this.completedMissions = const [],
    this.purchasedRewards = const [],
    this.levelsReached = const [1],
  });

  GameHistory copyWith({
    List<CompletedMissionRecord>? completedMissions,
    List<PurchasedRewardRecord>? purchasedRewards,
    List<int>? levelsReached,
  }) {
    return GameHistory(
      completedMissions: completedMissions ?? this.completedMissions,
      purchasedRewards: purchasedRewards ?? this.purchasedRewards,
      levelsReached: levelsReached ?? this.levelsReached,
    );
  }

  Map<String, dynamic> toJson() => {
        'completedMissions':
            completedMissions.map((m) => m.toJson()).toList(),
        'purchasedRewards':
            purchasedRewards.map((r) => r.toJson()).toList(),
        'levelsReached': levelsReached,
      };

  factory GameHistory.fromJson(Map<String, dynamic> json) {
    return GameHistory(
      completedMissions: (json['completedMissions'] as List<dynamic>?)
              ?.map((e) =>
                  CompletedMissionRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      purchasedRewards: (json['purchasedRewards'] as List<dynamic>?)
              ?.map((e) =>
                  PurchasedRewardRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      levelsReached: (json['levelsReached'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [1],
    );
  }
}

class GameStats {
  final int totalMissions;
  final int totalXP;
  final int totalGold;
  final int totalSpent;
  final int missionsToday;
  final String? lastConnection;
  final String? lastEnergyUpdate;

  const GameStats({
    this.totalMissions = 0,
    this.totalXP = 0,
    this.totalGold = 0,
    this.totalSpent = 0,
    this.missionsToday = 0,
    this.lastConnection,
    this.lastEnergyUpdate,
  });

  GameStats copyWith({
    int? totalMissions,
    int? totalXP,
    int? totalGold,
    int? totalSpent,
    int? missionsToday,
    String? lastConnection,
    String? lastEnergyUpdate,
    bool clearLastEnergyUpdate = false,
  }) {
    return GameStats(
      totalMissions: totalMissions ?? this.totalMissions,
      totalXP: totalXP ?? this.totalXP,
      totalGold: totalGold ?? this.totalGold,
      totalSpent: totalSpent ?? this.totalSpent,
      missionsToday: missionsToday ?? this.missionsToday,
      lastConnection: lastConnection ?? this.lastConnection,
      lastEnergyUpdate: clearLastEnergyUpdate
          ? null
          : (lastEnergyUpdate ?? this.lastEnergyUpdate),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalMissions': totalMissions,
        'totalXP': totalXP,
        'totalGold': totalGold,
        'totalSpent': totalSpent,
        'missionsToday': missionsToday,
        'lastConnection': lastConnection,
        'lastEnergyUpdate': lastEnergyUpdate,
      };

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      totalMissions: (json['totalMissions'] as num?)?.toInt() ?? 0,
      totalXP: (json['totalXP'] as num?)?.toInt() ?? 0,
      totalGold: (json['totalGold'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toInt() ?? 0,
      missionsToday: (json['missionsToday'] as num?)?.toInt() ?? 0,
      lastConnection: json['lastConnection'] as String?,
      lastEnergyUpdate: json['lastEnergyUpdate'] as String?,
    );
  }
}

class Inventory {
  final List<InventoryPotion> potions;

  const Inventory({this.potions = const []});

  Inventory copyWith({List<InventoryPotion>? potions}) {
    return Inventory(potions: potions ?? this.potions);
  }

  Map<String, dynamic> toJson() => {
        'potions': potions.map((p) => p.toJson()).toList(),
      };

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      potions: (json['potions'] as List<dynamic>?)
              ?.map(
                  (e) => InventoryPotion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class GameState {
  final Character character;
  final Inventory inventory;
  final List<ActiveMission> activeMissions;
  final GameHistory history;
  final GameStats stats;

  const GameState({
    this.character = const Character(),
    this.inventory = const Inventory(),
    this.activeMissions = const [],
    this.history = const GameHistory(),
    this.stats = const GameStats(),
  });

  GameState copyWith({
    Character? character,
    Inventory? inventory,
    List<ActiveMission>? activeMissions,
    GameHistory? history,
    GameStats? stats,
  }) {
    return GameState(
      character: character ?? this.character,
      inventory: inventory ?? this.inventory,
      activeMissions: activeMissions ?? this.activeMissions,
      history: history ?? this.history,
      stats: stats ?? this.stats,
    );
  }

  Map<String, dynamic> toJson() => {
        'character': character.toJson(),
        'inventory': inventory.toJson(),
        'activeMissions':
            activeMissions.map((m) => m.toJson()).toList(),
        'history': history.toJson(),
        'stats': stats.toJson(),
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      character: json['character'] != null
          ? Character.fromJson(json['character'] as Map<String, dynamic>)
          : const Character(),
      inventory: json['inventory'] != null
          ? Inventory.fromJson(json['inventory'] as Map<String, dynamic>)
          : const Inventory(),
      activeMissions: (json['activeMissions'] as List<dynamic>?)
              ?.map((e) =>
                  ActiveMission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      history: json['history'] != null
          ? GameHistory.fromJson(json['history'] as Map<String, dynamic>)
          : const GameHistory(),
      stats: json['stats'] != null
          ? GameStats.fromJson(json['stats'] as Map<String, dynamic>)
          : const GameStats(),
    );
  }

  static const GameState defaultState = GameState();
}
