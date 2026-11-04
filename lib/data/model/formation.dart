// Sơ đồ đội hình (C02) và các vị trí trên sân.

/// Một vị trí trên sân.
/// [x], [y] tính theo phần trăm (0–100) của sân: y = 0 là phía khung thành đối phương.
class FormationSlot {
  final String id;
  final String role;
  final double x;
  final double y;

  const FormationSlot({
    required this.id,
    required this.role,
    required this.x,
    required this.y,
  });
}

class Formation {
  final String id;
  final List<FormationSlot> slots;

  const Formation({required this.id, required this.slots});
}

/// Hai sơ đồ của bản MVP. Vị trí có cùng [FormationSlot.id] ở cả hai sơ đồ
/// (GK, LB, LCB...) thì khi đổi sơ đồ cầu thủ được giữ lại.
class Formations {
  static const f433 = Formation(
    id: '4-3-3',
    slots: [
      FormationSlot(id: 'GK', role: 'GK', x: 50, y: 90),
      FormationSlot(id: 'LB', role: 'LB', x: 14, y: 70),
      FormationSlot(id: 'LCB', role: 'CB', x: 37, y: 75),
      FormationSlot(id: 'RCB', role: 'CB', x: 63, y: 75),
      FormationSlot(id: 'RB', role: 'RB', x: 86, y: 70),
      FormationSlot(id: 'LCM', role: 'CM', x: 27, y: 50),
      FormationSlot(id: 'CM', role: 'CM', x: 50, y: 55),
      FormationSlot(id: 'RCM', role: 'CM', x: 73, y: 50),
      FormationSlot(id: 'LW', role: 'LW', x: 16, y: 24),
      FormationSlot(id: 'ST', role: 'ST', x: 50, y: 14),
      FormationSlot(id: 'RW', role: 'RW', x: 84, y: 24),
    ],
  );

  static const f442 = Formation(
    id: '4-4-2',
    slots: [
      FormationSlot(id: 'GK', role: 'GK', x: 50, y: 90),
      FormationSlot(id: 'LB', role: 'LB', x: 14, y: 70),
      FormationSlot(id: 'LCB', role: 'CB', x: 37, y: 75),
      FormationSlot(id: 'RCB', role: 'CB', x: 63, y: 75),
      FormationSlot(id: 'RB', role: 'RB', x: 86, y: 70),
      FormationSlot(id: 'LM', role: 'LM', x: 13, y: 44),
      FormationSlot(id: 'LCM', role: 'CM', x: 37, y: 50),
      FormationSlot(id: 'RCM', role: 'CM', x: 63, y: 50),
      FormationSlot(id: 'RM', role: 'RM', x: 87, y: 44),
      FormationSlot(id: 'LST', role: 'ST', x: 37, y: 16),
      FormationSlot(id: 'RST', role: 'ST', x: 63, y: 16),
    ],
  );

  static const all = [f433, f442];

  static Formation byId(String id) {
    return all.firstWhere((f) => f.id == id, orElse: () => f433);
  }
}
