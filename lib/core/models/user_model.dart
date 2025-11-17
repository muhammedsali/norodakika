import '../memory/memory_bank.dart';

class UserModel {
  final String uid;
  final List<Map<String, dynamic>> dailyPlan;
  final Map<String, double> stats;
  final List<Map<String, dynamic>> history;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.dailyPlan,
    required this.stats,
    required this.history,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      dailyPlan: List<Map<String, dynamic>>.from(json['dailyPlan'] ?? []),
      stats: Map<String, double>.from(
        (json['stats'] ?? MemoryBank.createUserModel(json['uid'] ?? '')['stats'])
            .map((key, value) => MapEntry(key, (value as num).toDouble())),
      ),
      history: List<Map<String, dynamic>>.from(json['history'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'dailyPlan': dailyPlan,
      'stats': stats.map((key, value) => MapEntry(key, value)),
      'history': history,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    List<Map<String, dynamic>>? dailyPlan,
    Map<String, double>? stats,
    List<Map<String, dynamic>>? history,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      dailyPlan: dailyPlan ?? this.dailyPlan,
      stats: stats ?? this.stats,
      history: history ?? this.history,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

