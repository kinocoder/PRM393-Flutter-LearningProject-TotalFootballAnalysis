import 'skill.dart';
class Player {
  final String id;
  final String name;
  final String fullName;
  final String image;
  final String position;
  final String cardVersion;
  final int ovr;
  final int level;
  final Map<String, int?> stats;
  final Map<String, Map<String, int>> statDetails;
  final Map<String,int> positionRatings;
  final List<Skill>? skills;
  final String nation;
  final String club;
  final int age;
  final int heightCm;
  final int weightKg;
  final int skillMoves;

  const Player({
    required this.id,
    required this.name,
    required this.fullName,
    this.image = '',
    required this.position,
    required this.cardVersion,
    required this.ovr,
    required this.level,
    required this.stats,
    required this.statDetails,
    required this.positionRatings,
    this.skills,
    required this.nation,
    required this.club,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.skillMoves,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      position: json['position'] as String? ?? '',
      cardVersion: json['cardVersion'] as String? ?? 'Base',
      ovr: json['ovr'] as int,
      level: json['level'] as int? ?? 1,
      positionRatings: (json['positionRatings'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toInt()),
          ) ??
          {},
      stats: (json['stats'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              value != null ? (value as num).toInt() : null,
            ),
          ) ??
          {},
      statDetails: (json['statDetails'] as Map<String, dynamic>?)?.map(
            (group, items) => MapEntry(
              group,
              (items as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, (value as num).toInt()),
              ),
            ),
          ) ??
          {},
      skills: json['skills'] == null
          ? null
          : (json['skills'] as List)
              .map((e) => Skill.fromJson(e as Map<String, dynamic>))
              .toList(),
      nation: json['nation'] as String? ?? '',
      club: json['club'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      heightCm: json['heightCm'] as int? ?? 0,
      weightKg: json['weightKg'] as int? ?? 0,
      skillMoves: json['skillMoves'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullName': fullName,
      'image': image,
      'position': position,
      'cardVersion': cardVersion,
      'ovr': ovr,
      'level': level,
      'positionRatings': positionRatings,
      'stats': stats,
      'statDetails': statDetails,
      'skills': skills?.map((s) => s.toJson()).toList(),
      'nation': nation,
      'club': club,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'skillMoves': skillMoves,
    };
  }
}
