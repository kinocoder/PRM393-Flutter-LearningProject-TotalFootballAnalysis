import 'formation.dart';

/// C01–C04 — một đội hình của người dùng (khoá theo UID).
class Lineup {
  const Lineup({
    required this.id,
    required this.uid,
    required this.name,
    required this.formationId,
    this.slots = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String uid;
  final String name;
  final String formationId;

  /// slotId → playerId.
  final Map<String, String> slots;
  final DateTime createdAt;
  final DateTime updatedAt;

  Formation get formation => Formations.byId(formationId);

  int get filledCount => slots.length;

  Lineup copyWith({
    String? name,
    String? formationId,
    Map<String, String>? slots,
    DateTime? updatedAt,
  }) =>
      Lineup(
        id: id,
        uid: uid,
        name: name ?? this.name,
        formationId: formationId ?? this.formationId,
        slots: slots ?? this.slots,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// Dạng lưu Firestore `users/{uid}/lineups/{id}`.
  /// So sánh nội dung người dùng chỉnh được (bỏ qua thời gian) — dùng để
  /// biết bản nháp C04 có thay đổi chưa lưu hay không.
  bool hasSameContent(Lineup other) =>
      name == other.name && formationId == other.formationId && _mapEquals(slots, other.slots);

  Map<String, Object?> toMap() => {
        'id': id,
        'uid': uid,
        'name': name,
        'formationId': formationId,
        'slots': slots,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory Lineup.fromMap(Map<String, Object?> map) => Lineup(
        id: map['id'] as String,
        uid: map['uid'] as String,
        name: map['name'] as String,
        formationId: map['formationId'] as String,
        slots: ((map['slots'] as Map?) ?? const {})
            .map((k, v) => MapEntry(k.toString(), v.toString())),
        createdAt: DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as num).toInt()),
        updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updatedAt'] as num).toInt()),
      );

  @override
  bool operator ==(Object other) =>
      other is Lineup &&
      other.id == id &&
      other.name == name &&
      other.formationId == formationId &&
      other.updatedAt == updatedAt &&
      _mapEquals(other.slots, slots);

  @override
  int get hashCode => Object.hash(id, name, formationId, updatedAt, slots.length);
}

bool _mapEquals(Map<String, String> a, Map<String, String> b) {
  if (a.length != b.length) return false;
  for (final e in a.entries) {
    if (b[e.key] != e.value) return false;
  }
  return true;
}

