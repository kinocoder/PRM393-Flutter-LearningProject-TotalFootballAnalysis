import 'package:flutter_test/flutter_test.dart';
import 'package:united2/domain/models/formation.dart';
import 'package:united2/domain/models/lineup.dart';
import 'package:united2/ui/lineups/view_models/c03_view_model.dart';
import 'package:united2/ui/lineups/view_models/c04_view_model.dart';

import 'fakes.dart';

void main() {
  final lb = Formations.f433.slot('LB')!;
  final st = Formations.f433.slot('ST')!;
  final lineup = Lineup(
    id: 'l1',
    uid: 'u1',
    name: 'Đội A',
    formationId: '4-3-3',
    slots: const {'ST': 'striker', 'LB': 'cb'},
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
  final owned = [
    makePlayer('fullback', 'LB', ovr: 88, ratings: {'LB': 88, 'LWB': 89}),
    makePlayer('striker', 'ST', ovr: 95, ratings: {'ST': 95, 'CF': 94}),
    makePlayer('cb', 'CB', ovr: 91, ratings: {'CB': 91}),
    makePlayer('wingback', 'LWB', ovr: 84, ratings: {'LWB': 84}),
  ];

  group('C03 buildCandidates', () {
    test('mặc định chỉ hiện cầu thủ đúng vị trí, sắp theo điểm vị trí', () {
      final c = buildCandidates(owned: owned, lineup: lineup, slot: lb);
      expect(c.map((x) => x.player.id), ['fullback', 'wingback']);
      expect(c.first.rating, 89); // lấy điểm cao nhất trong LB/LWB
    });

    test('tắt lọc: người lệch vị trí xếp sau, có cờ fits = false', () {
      final c = buildCandidates(owned: owned, lineup: lineup, slot: lb, onlyFitting: false);
      expect(c.take(2).every((x) => x.fits), isTrue);
      expect(c.skip(2).every((x) => !x.fits), isTrue);
    });

    test('đánh dấu cầu thủ đang ở slot khác', () {
      final c = buildCandidates(owned: owned, lineup: lineup, slot: lb, onlyFitting: false);
      expect(c.firstWhere((x) => x.player.id == 'striker').currentSlot, 'ST');
    });

    test('tìm theo tên không dấu', () {
      final c = buildCandidates(owned: owned, lineup: lineup, slot: st, query: 'STRIK');
      expect(c.single.player.id, 'striker');
    });
  });

  group('C04 computeWarnings', () {
    test('CB đứng ở LB bị đánh dấu lệch vị trí', () {
      final players = {for (final p in owned) p.id: p};
      final w = computeWarnings(lineup, players, {'striker', 'cb'});
      expect(w.mismatchedSlots, ['LB']);
      expect(w.unownedPlayerIds, isEmpty);
    });

    test('thẻ không còn trong bộ sưu tập bị đánh dấu', () {
      final players = {for (final p in owned) p.id: p};
      final w = computeWarnings(lineup, players, {'striker'});
      expect(w.unownedPlayerIds, {'cb'});
    });

    test('chưa tải xong bộ sưu tập thì không cảnh báo nhầm', () {
      expect(computeWarnings(lineup, const {}, null).unownedPlayerIds, isEmpty);
    });
  });

  test('joinPlayerIds ổn định, không trùng', () {
    expect(joinPlayerIds(['b', 'a', 'b']), 'a,b');
  });
}
