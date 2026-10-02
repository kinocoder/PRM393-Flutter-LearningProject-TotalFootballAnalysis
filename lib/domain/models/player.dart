/// DATA-01 — mô hình dữ liệu cầu thủ dùng chung cho mảng A, B, C, E.
///
/// Nguyên tắc:
/// * `id` là khóa duy nhất của một thẻ (cầu thủ + phiên bản thẻ).
/// * Chỉ số thiếu là `null` và hiển thị `N/A`, **không** biến thành 0.
/// * `skills == null` nghĩa là *chưa có dữ liệu*; `skills` rỗng nghĩa là
///   *không sở hữu kỹ thuật nào* (A03 phải phân biệt hai trường hợp).
library;

/// Nhóm chỉ số chính. Thẻ trong game chỉ hiện 6 nhóm tuỳ vị trí
/// (hậu vệ hiện DEF, tiền đạo cánh hiện ATK) nên nhóm nào cũng có thể thiếu.
enum StatKey {
  pac('PAC', 'Tốc độ'),
  sho('SHO', 'Sút'),
  pas('PAS', 'Chuyền'),
  dri('DRI', 'Rê bóng'),
  def('DEF', 'Phòng ngự'),
  phy('PHY', 'Thể lực'),
  atk('ATK', 'Tấn công');

  const StatKey(this.code, this.label);

  final String code;
  final String label;

  static StatKey? fromCode(String code) {
    for (final k in StatKey.values) {
      if (k.code == code.toUpperCase()) return k;
    }
    return null;
  }

  /// 6 chỉ số so sánh ở A02 theo đặc tả KAN-8 (ATK hiển thị thêm nếu có).
  static const core = [pac, sho, pas, dri, def, phy];
}

enum SkillType {
  skill('skill', 'Kỹ năng'),
  style('style', 'Phong cách');

  const SkillType(this.value, this.label);
  final String value;
  final String label;

  static SkillType fromValue(String? v) =>
      v == style.value ? SkillType.style : SkillType.skill;
}

/// Kỹ thuật đặc biệt (kỹ năng hoặc phong cách chơi).
class Skill {
  const Skill({
    required this.id,
    required this.name,
    this.description,
    this.type = SkillType.skill,
  });

  final String id;
  final String name;
  final String? description;
  final SkillType type;

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        type: SkillType.fromValue(json['type'] as String?),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.value,
      };

  @override
  bool operator ==(Object other) => other is Skill && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Nguồn dữ liệu của một thẻ (bắt buộc ghi rõ theo KAN-25).
class DataSource {
  const DataSource({required this.name, this.note, this.capturedAt});

  final String name;
  final String? note;
  final DateTime? capturedAt;

  factory DataSource.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DataSource(name: 'Không rõ');
    final captured = json['capturedAt'] as String?;
    return DataSource(
      name: (json['name'] as String?) ?? 'Không rõ',
      note: json['note'] as String?,
      capturedAt: captured == null ? null : DateTime.tryParse(captured),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'note': note,
        'capturedAt': capturedAt?.toIso8601String(),
      };
}

int? _asInt(Object? v) => v is num ? v.toInt() : null;

class Player {
  const Player({
    required this.id,
    required this.name,
    required this.position,
    required this.dataVersion,
    this.fullName,
    this.cardVersion,
    this.ovr,
    this.baseOvr,
    this.level,
    this.positionRatings = const {},
    this.stats = const {},
    this.statDetails = const {},
    this.skills,
    this.nation,
    this.club,
    this.age,
    this.heightCm,
    this.weightKg,
    this.weakFoot,
    this.skillMoves,
    this.imageUrl,
    this.source = const DataSource(name: 'Không rõ'),
    this.isSample = false,
  });

  final String id;

  /// Tên in trên thẻ, vd. `J. KOUNDÉ`.
  final String name;
  final String? fullName;

  /// Vị trí chính in trên thẻ, vd. `RB`.
  final String position;

  /// Phiên bản thẻ/mùa, vd. `TOTS 26`.
  final String? cardVersion;

  /// OVR in trên thẻ (theo vị trí chính, đã gồm cộng thêm).
  final int? ovr;

  /// OVR gốc ở màn Nâng cấp (khác [ovr]).
  final int? baseOvr;

  /// Cấp thẻ lúc nhập dữ liệu (chỉ số thay đổi theo cấp).
  final int? level;

  /// Điểm theo từng vị trí, vd. `{RW: 123, LW: 122}`.
  final Map<String, int> positionRatings;

  final Map<StatKey, int?> stats;

  /// Chỉ số con theo nhóm, vd. `{DEF: {Cướp bóng: 102}}`.
  final Map<String, Map<String, int>> statDetails;

  /// `null` = chưa có dữ liệu, rỗng = không sở hữu kỹ thuật.
  final List<Skill>? skills;

  final String? nation;
  final String? club;
  final int? age;
  final int? heightCm;
  final int? weightKg;

  /// Chân không thuận (1–5).
  final int? weakFoot;

  /// Kỹ thuật (1–5).
  final int? skillMoves;
  final String? imageUrl;
  final DataSource source;
  final String dataVersion;

  /// Dữ liệu mẫu do nhóm tự đặt, không phải thẻ thật trong game.
  final bool isSample;

  int? stat(StatKey key) => stats[key];

  /// Tất cả vị trí cầu thủ chơi được (vị trí chính luôn có).
  Set<String> get playablePositions => {position, ...positionRatings.keys};

  bool canPlay(String pos) => playablePositions.contains(pos);

  String get displayTitle => cardVersion == null ? name : '$name · $cardVersion';

  factory Player.fromJson(Map<String, dynamic> json) {
    final rawStats = (json['stats'] as Map?)?.cast<String, dynamic>() ?? const {};
    final stats = <StatKey, int?>{};
    rawStats.forEach((code, value) {
      final key = StatKey.fromCode(code);
      if (key != null) stats[key] = _asInt(value);
    });

    final rawRatings = (json['positionRatings'] as Map?)?.cast<String, dynamic>() ?? const {};
    final ratings = <String, int>{};
    rawRatings.forEach((pos, value) {
      final v = _asInt(value);
      if (v != null) ratings[pos] = v;
    });

    final rawDetails = (json['statDetails'] as Map?)?.cast<String, dynamic>() ?? const {};
    final details = <String, Map<String, int>>{};
    rawDetails.forEach((group, value) {
      final inner = <String, int>{};
      (value as Map).cast<String, dynamic>().forEach((k, v) {
        final n = _asInt(v);
        if (n != null) inner[k] = n;
      });
      details[group] = inner;
    });

    final rawSkills = json['skills'];
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      fullName: json['fullName'] as String?,
      position: json['position'] as String,
      cardVersion: json['cardVersion'] as String?,
      ovr: _asInt(json['ovr']),
      baseOvr: _asInt(json['baseOvr']),
      level: _asInt(json['level']),
      positionRatings: ratings,
      stats: stats,
      statDetails: details,
      skills: rawSkills is List
          ? rawSkills.map((e) => Skill.fromJson((e as Map).cast<String, dynamic>())).toList()
          : null,
      nation: json['nation'] as String?,
      club: json['club'] as String?,
      age: _asInt(json['age']),
      heightCm: _asInt(json['heightCm']),
      weightKg: _asInt(json['weightKg']),
      weakFoot: _asInt(json['weakFoot']),
      skillMoves: _asInt(json['skillMoves']),
      imageUrl: json['imageUrl'] as String?,
      source: DataSource.fromJson((json['source'] as Map?)?.cast<String, dynamic>()),
      dataVersion: (json['dataVersion'] as String?) ?? 'unknown',
      isSample: json['isSample'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fullName': fullName,
        'position': position,
        'cardVersion': cardVersion,
        'ovr': ovr,
        'baseOvr': baseOvr,
        'level': level,
        'positionRatings': positionRatings,
        'stats': {for (final e in stats.entries) e.key.code: e.value},
        'statDetails': statDetails,
        'skills': skills?.map((s) => s.toJson()).toList(),
        'nation': nation,
        'club': club,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'weakFoot': weakFoot,
        'skillMoves': skillMoves,
        'imageUrl': imageUrl,
        'source': source.toJson(),
        'dataVersion': dataVersion,
        'isSample': isSample,
      };

  @override
  bool operator ==(Object other) => other is Player && other.id == id && other.dataVersion == dataVersion;

  @override
  int get hashCode => Object.hash(id, dataVersion);
}
