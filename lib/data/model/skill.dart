class Skill {
  final String id;
  final String name;
  final String? type;
  final String description;

  const Skill({
    required this.id,
    required this.name,
    this.type,
    required this.description,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String?,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
    };
  }
}
