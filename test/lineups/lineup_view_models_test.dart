import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united2/data/providers/current_user_provider.dart';
import 'package:united2/data/providers/lineup_repository_provider.dart';
import 'package:united2/data/providers/owned_player_repository_provider.dart';
import 'package:united2/data/providers/player_repository_provider.dart';
import 'package:united2/domain/models/formation.dart';
import 'package:united2/ui/lineups/view_models/c01_view_model.dart';
import 'package:united2/ui/lineups/view_models/c02_view_model.dart';
import 'package:united2/ui/lineups/view_models/c03_view_model.dart';
import 'package:united2/ui/lineups/view_models/lineup_draft_view_model.dart';

import 'fakes.dart';

void main() {
  late FakeLineupRepository repo;
  late ProviderContainer container;

  ProviderContainer makeContainer(String uid) => ProviderContainer(overrides: [
        currentUidProvider.overrideWithValue(uid),
        lineupRepositoryProvider.overrideWithValue(repo),
        ownedPlayerRepositoryProvider.overrideWithValue(FakeOwnedPlayerRepository({'u1': ['p1', 'p2']})),
        playerRepositoryProvider.overrideWithValue(
          FakePlayerRepository([makePlayer('p1', 'ST'), makePlayer('p2', 'CM')]),
        ),
      ]);

  setUp(() {
    repo = FakeLineupRepository();
    container = makeContainer('u1');
  });

  tearDown(() => container.dispose());

  test('C01: tạo đội hình 4-3-3 trống theo UID', () async {
    await container.read(c01ViewModelProvider.future);
    final l = await container.read(c01ViewModelProvider.notifier).create('  Đội chính ');
    expect(l.name, 'Đội chính');
    expect(l.formationId, Formations.f433.id);
    expect(l.uid, 'u1');
    expect((await container.read(c01ViewModelProvider.future)).single.id, l.id);
  });

  test('C01: tên rỗng hoặc quá 30 ký tự bị từ chối', () async {
    final vm = container.read(c01ViewModelProvider.notifier);
    expect(() => vm.create('   '), throwsA(anything));
    expect(validateLineupName('a' * 31), isNotNull);
    expect(validateLineupName('Đội A'), isNull);
  });

  test('C01: UID khác không thấy đội hình', () async {
    await container.read(c01ViewModelProvider.notifier).create('Đội u1');
    final other = makeContainer('u2');
    addTearDown(other.dispose);
    expect(await other.read(c01ViewModelProvider.future), isEmpty);
  });

  test('C01: xoá rồi hoàn tác', () async {
    final vm = container.read(c01ViewModelProvider.notifier);
    final l = await vm.create('Đội A');
    await vm.delete(l);
    expect(await container.read(c01ViewModelProvider.future), isEmpty);
    await vm.restore(l);
    expect((await container.read(c01ViewModelProvider.future)).single.id, l.id);
  });

  group('bản nháp C02–C04', () {
    late String id;
    late LineupDraftViewModel draftVm;

    setUp(() async {
      id = (await container.read(c01ViewModelProvider.notifier).create('Đội A')).id;
      await container.read(lineupDraftViewModelProvider(id).future);
      draftVm = container.read(lineupDraftViewModelProvider(id).notifier);
    });

    LineupDraft draft() => container.read(lineupDraftViewModelProvider(id)).value!;

    test('gán cầu thủ làm bản nháp "chưa lưu"; lưu thì hết', () async {
      draftVm.assign('ST', 'p1');
      expect(draft().isDirty, isTrue);
      await draftVm.save();
      expect(draft().isDirty, isFalse);
      expect(repo.items[id]!.slots, {'ST': 'p1'});
    });

    test('hoàn tác bỏ thay đổi chưa lưu', () {
      draftVm.assign('ST', 'p1');
      draftVm.discard();
      expect(draft().current.slots, isEmpty);
      expect(repo.saveCalls, 1); // chỉ lần tạo
    });

    test('C02: chọn rồi không áp dụng thì bản nháp giữ nguyên', () {
      container.read(c02ViewModelProvider(id).notifier).select('4-4-2');
      expect(draft().current.formationId, '4-3-3');
      final s = container.read(c02StateProvider(id)).value!;
      expect(s.isChange, isTrue);
    });

    test('C02: đổi 4-3-3 → 4-4-2 gỡ cầu thủ ở ST, giữ LCM', () {
      draftVm
        ..assign('ST', 'p1')
        ..assign('LCM', 'p2');
      final c02 = container.read(c02ViewModelProvider(id).notifier)..select('4-4-2');
      final s = container.read(c02StateProvider(id)).value!;
      expect(s.needsConfirm, isTrue);
      expect(s.plan.removedSlots.keys, ['ST']);
      c02.apply();
      expect(draft().current.formationId, '4-4-2');
      expect(draft().current.slots, {'LCM': 'p2'});
    });

    test('C03: chọn người đang ở slot khác → hỏi chuyển; gán thì chuyển', () async {
      draftVm.assign('ST', 'p1');
      final args = (lineupId: id, slotId: 'CM');
      await container.read(ownedPlayersProvider.future);
      final s = container.read(c03StateProvider(args)).value!;
      final vm = container.read(c03ViewModelProvider(args).notifier)..setOnlyFitting(false);
      final cand = container.read(c03StateProvider(args)).value!.candidates.firstWhere((c) => c.player.id == 'p1');
      expect(s.ownedCount, 2);
      expect(vm.checksFor(cand), [PickCheck.movesFromOtherSlot, PickCheck.wrongPosition]);
      vm.assign('p1');
      expect(draft().current.slots, {'CM': 'p1'});
    });
  });
}
