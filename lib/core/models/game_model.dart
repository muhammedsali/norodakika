class GameModel {
  final String id;
  final String name;
  final String area;
  final String unityScene;
  final String description;

  GameModel({
    required this.id,
    required this.name,
    required this.area,
    required this.unityScene,
    required this.description,
  });

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      area: map['area'] ?? '',
      unityScene: map['unityScene'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'unityScene': unityScene,
      'description': description,
    };
  }
}

