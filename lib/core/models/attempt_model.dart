class AttemptModel {
  final String gameId;
  final String userId;
  final double score;
  final double successRate;
  final double difficulty;
  final int duration;
  final DateTime timestamp;
  final String area;

  AttemptModel({
    required this.gameId,
    required this.userId,
    required this.score,
    required this.successRate,
    required this.difficulty,
    required this.duration,
    required this.timestamp,
    required this.area,
  });

  factory AttemptModel.fromMap(Map<String, dynamic> map) {
    return AttemptModel(
      gameId: map['gameId'] ?? '',
      userId: map['userId'] ?? '',
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      successRate: (map['successRate'] as num?)?.toDouble() ?? 0.0,
      difficulty: (map['difficulty'] as num?)?.toDouble() ?? 1.0,
      duration: map['duration'] ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      area: map['area'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'userId': userId,
      'score': score,
      'successRate': successRate,
      'difficulty': difficulty,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
      'area': area,
    };
  }
}

