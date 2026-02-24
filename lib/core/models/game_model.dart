class GameModel {
  final String id;
  final String name;
  final String area;
  final String description;
  final String intelligence;

  GameModel({
    required this.id,
    required this.name,
    required this.area,
    required this.description,
    required this.intelligence,
  });

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      area: map['area'] ?? '',
      description: map['description'] ?? '',
      intelligence: map['intelligence'] ?? 'intrapersonal',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'description': description,
      'intelligence': intelligence,
    };
  }
}

