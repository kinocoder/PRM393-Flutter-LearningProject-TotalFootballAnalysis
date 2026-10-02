/// C02/C03 — sơ đồ, vị trí và quy tắc gán cầu thủ (logic thuần Dart).
library;

/// Một vị trí trên sân. [x], [y] là phần trăm (0–100) theo chiều ngang/dọc
/// của sân, y = 0 là khung thành đối phương.
class FormationSlot {
  const FormationSlot({
    required this.id,
    required this.role,
    required this.x,
    required this.y,
    this.alsoFits = const {},
  });

  /// ID ổn định giữa các sơ đồ (vd. `LCB` có ở cả 4-3-3 và 4-4-2).
  final String id;

  /// Vị trí chuẩn trong game để kiểm tra lệch vị trí (GK, CB, RB…).
  final String role;
  final double x;
  final double y;

  /// Vị trí gần giống được coi là không lệch (vd. slot LW nhận LM).
  final Set<String> alsoFits;

  Set<String> get acceptedPositions => {role, ...alsoFits};
}

class Formation {
  const Formation({required this.id, required this.name, required this.slots});

  final String id;
  final String name;
  final List<FormationSlot> slots;

  FormationSlot? slot(String slotId) {
    for (final s in slots) {
      if (s.id == slotId) return s;
    }
    return null;
  }

  Set<String> get slotIds => {for (final s in slots) s.id};
}

/// Hai sơ đồ MVP (KAN-49).
class Formations {
  const Formations._();

  static const f433 = Formation(
    id: '4-3-3',
    name: '4-3-3',
    slots: [
      FormationSlot(id: 'GK', role: 'GK', x: 50, y: 92),
      FormationSlot(id: 'LB', role: 'LB', x: 14, y: 72, alsoFits: {'LWB'}),
      FormationSlot(id: 'LCB', role: 'CB', x: 37, y: 77),
      FormationSlot(id: 'RCB', role: 'CB', x: 63, y: 77),
      FormationSlot(id: 'RB', role: 'RB', x: 86, y: 72, alsoFits: {'RWB'}),
      FormationSlot(id: 'LCM', role: 'CM', x: 27, y: 52, alsoFits: {'CDM', 'CAM'}),
      FormationSlot(id: 'CM', role: 'CM', x: 50, y: 57, alsoFits: {'CDM', 'CAM'}),
      FormationSlot(id: 'RCM', role: 'CM', x: 73, y: 52, alsoFits: {'CDM', 'CAM'}),
      FormationSlot(id: 'LW', role: 'LW', x: 16, y: 24, alsoFits: {'LM', 'LF'}),
      FormationSlot(id: 'ST', role: 'ST', x: 50, y: 15, alsoFits: {'CF'}),
      FormationSlot(id: 'RW', role: 'RW', x: 84, y: 24, alsoFits: {'RM', 'RF'}),
    ],
  );

  static const f442 = Formation(
    id: '4-4-2',
    name: '4-4-2',
    slots: [
      FormationSlot(id: 'GK', role: 'GK', x: 50, y: 92),
      FormationSlot(id: 'LB', role: 'LB', x: 14, y: 72, alsoFits: {'LWB'}),
      FormationSlot(id: 'LCB', role: 'CB', x: 37, y: 77),
      FormationSlot(id: 'RCB', role: 'CB', x: 63, y: 77),
      FormationSlot(id: 'RB', role: 'RB', x: 86, y: 72, alsoFits: {'RWB'}),
      FormationSlot(id: 'LM', role: 'LM', x: 13, y: 45, alsoFits: {'LW'}),
      FormationSlot(id: 'LCM', role: 'CM', x: 37, y: 52, alsoFits: {'CDM', 'CAM'}),
      FormationSlot(id: 'RCM', role: 'CM', x: 63, y: 52, alsoFits: {'CDM', 'CAM'}),
      FormationSlot(id: 'RM', role: 'RM', x: 87, y: 45, alsoFits: {'RW'}),
      FormationSlot(id: 'LST', role: 'ST', x: 37, y: 17, alsoFits: {'CF'}),
      FormationSlot(id: 'RST', role: 'ST', x: 63, y: 17, alsoFits: {'CF'}),
    ],
  );

  static const all = [f433, f442];

  static Formation byId(String id) =>
      all.firstWhere((f) => f.id == id, orElse: () => f433);
}

/// Kết quả khi đổi sơ đồ: slot nào giữ, cầu thủ nào bị gỡ (C02).
class FormationChange {
  const FormationChange({required this.keptSlots, required this.removedSlots});

  final Map<String, String> keptSlots;

  /// slotId cũ → playerId bị gỡ.
  final Map<String, String> removedSlots;

  bool get removesPlayers => removedSlots.isNotEmpty;
}

/// Quy tắc đổi sơ đồ (KAN-51): giữ cầu thủ ở các slot có cùng ID trong sơ đồ
/// mới, gỡ cầu thủ ở slot không còn tồn tại. Người dùng phải xác nhận nếu có gỡ.
FormationChange planFormationChange(Map<String, String> current, Formation target) {
  final kept = <String, String>{};
  final removed = <String, String>{};
  current.forEach((slotId, playerId) {
    if (target.slotIds.contains(slotId)) {
      kept[slotId] = playerId;
    } else {
      removed[slotId] = playerId;
    }
  });
  return FormationChange(keptSlots: kept, removedSlots: removed);
}

/// Gán [playerId] vào [slotId]; nếu cầu thủ đang ở slot khác thì chuyển sang
/// (một cầu thủ không bao giờ ở hai slot — KAN-58).
Map<String, String> assignPlayer(Map<String, String> slots, String slotId, String playerId) {
  final next = Map<String, String>.of(slots)
    ..removeWhere((_, pid) => pid == playerId)
    ..[slotId] = playerId;
  return next;
}
