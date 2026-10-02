import 'package:flutter_test/flutter_test.dart';
import 'package:united2/domain/models/formation.dart';
import 'package:united2/domain/models/lineup.dart';

void main() {
  test('hai sơ đồ MVP đều có 11 slot, ID không trùng, có 1 GK', () {
    for (final f in Formations.all) {
      expect(f.slots.length, 11, reason: f.id);
      expect(f.slotIds.length, 11, reason: f.id);
      expect(f.slots.where((s) => s.role == 'GK').length, 1);
      for (final s in f.slots) {
        expect(s.x, inInclusiveRange(0, 100));
        expect(s.y, inInclusiveRange(0, 100));
      }
    }
  });

  group('planFormationChange (C02)', () {
    final full433 = {for (final s in Formations.f433.slots) s.id: 'p-${s.id}'};

    test('4-3-3 → 4-4-2: giữ slot trùng ID, gỡ slot không còn', () {
      final plan = planFormationChange(full433, Formations.f442);
      expect(plan.keptSlots.keys.toSet(), {'GK', 'LB', 'LCB', 'RCB', 'RB', 'LCM', 'RCM'});
      expect(plan.removedSlots.keys.toSet(), {'CM', 'LW', 'ST', 'RW'});
      expect(plan.removesPlayers, isTrue);
    });

    test('đội hình trống: không cần xác nhận', () {
      expect(planFormationChange({}, Formations.f442).removesPlayers, isFalse);
    });

    test('cùng sơ đồ: giữ nguyên', () {
      final plan = planFormationChange(full433, Formations.f433);
      expect(plan.keptSlots, full433);
      expect(plan.removedSlots, isEmpty);
    });
  });

  group('assignPlayer (C03)', () {
    test('gán vào slot trống', () {
      expect(assignPlayer({}, 'ST', 'p1'), {'ST': 'p1'});
    });

    test('cầu thủ đang ở slot khác thì được chuyển, không xuất hiện hai lần', () {
      final next = assignPlayer({'ST': 'p1', 'LW': 'p2'}, 'RW', 'p1');
      expect(next, {'LW': 'p2', 'RW': 'p1'});
      expect(next.values.where((v) => v == 'p1').length, 1);
    });

    test('thay cầu thủ trong slot đã có người', () {
      expect(assignPlayer({'ST': 'p1'}, 'ST', 'p2'), {'ST': 'p2'});
    });
  });

  test('Lineup toMap/fromMap (đồng bộ Firestore)', () {
    final l = Lineup(
      id: 'x',
      uid: 'u1',
      name: 'Đội A',
      formationId: '4-4-2',
      slots: const {'GK': 'p1'},
      createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(2000),
    );
    expect(Lineup.fromMap(l.toMap()), l);
  });
}
