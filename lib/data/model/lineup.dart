import 'formation.dart';

/// Một đội hình người dùng tạo ra (C01–C04).
class Lineup {
  final String id;

  /// Chủ đội hình: mỗi tài khoản chỉ thấy đội hình của mình (BR-05).
  final String uid;
  final String name;
  final String formationId;

  /// Vị trí → ID cầu thủ, ví dụ {'ST': '9284'}. Vị trí trống thì không có trong map.
  final Map<String, String> slots;
  final DateTime updatedAt;

  const Lineup({
    required this.id,
    required this.uid,
    required this.name,
    required this.formationId,
    this.slots = const {},
    required this.updatedAt,
  });

  Formation get formation => Formations.byId(formationId);

  int get playerCount => slots.length;

  Lineup copyWith({
    String? name,
    String? formationId,
    Map<String, String>? slots,
    DateTime? updatedAt,
  }) {
    return Lineup(
      id: id,
      uid: uid,
      name: name ?? this.name,
      formationId: formationId ?? this.formationId,
      slots: slots ?? this.slots,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
