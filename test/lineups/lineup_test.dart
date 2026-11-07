import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:united2/data/model/formation.dart';
import 'package:united2/data/model/lineup.dart';
import 'package:united2/data/model/player.dart';
import 'package:united2/data/repositories/collection_repository.dart';
import 'package:united2/data/repositories/current_user_provider.dart';
import 'package:united2/data/repositories/lineup_repository.dart';
import 'package:united2/data/repositories/player_repository.dart';
import 'package:united2/data/services/local_database_service.dart';
import 'package:united2/ui/lineups/view_models/c01_view_model.dart';
import 'package:united2/ui/lineups/view_models/c03_view_model.dart';
import 'package:united2/ui/lineups/view_models/c04_view_model.dart';

/// Repository giả: lần lưu nào cũng lỗi, để kiểm tra khi không ghi được database.
class _FailingLineupRepository extends LineupRepository {
  final Lineup lineup;

  _FailingLineupRepository(this.lineup) : super(LocalDatabaseService());

  @override
  Future<Lineup?> getLineupById(String uid, String id) async => lineup;

  @override
  Future<void> saveLineup(Lineup lineup) async {
    throw StateError('Không ghi được database');
  }
}

/// Unit test cho logic của mảng C (không cần giao diện, không cần điện thoại).
void main() {
  const uid = 'demo_user';
  late LocalDatabaseService database;
  late ProviderContainer container;

  FormationSlot slotOf(String id) {
    return Formations.f433.slots.firstWhere((slot) => slot.id == id);
  }

  Player playerById(String id) {
    return PlayerRepository.seedPlayers.firstWhere((p) => p.id == id);
  }

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Database nằm trong RAM, mỗi test một database mới
    database = LocalDatabaseService(path: inMemoryDatabasePath);
    container = ProviderContainer.test(
      overrides: [localDatabaseServiceProvider.overrideWithValue(database)],
    );
    await PlayerRepository(database).getPlayers();
    // Giữ C01 sống trong suốt test, vì đọc/ghi SQLite mất thời gian thật
    container.listen(c01ViewModelProvider, (_, _) {});
  });

  tearDown(() => database.close());

  test('C01: tên rỗng hoặc dài quá 30 ký tự thì báo lỗi', () {
    final viewModel = container.read(c01ViewModelProvider.notifier);

    expect(viewModel.validateName(''), 'Vui lòng nhập tên đội hình');
    expect(viewModel.validateName('a' * 31), 'Tên đội hình tối đa 30 ký tự');
    expect(viewModel.validateName('Đội chính'), isNull);
  });

  test('C01: tạo đội hình mới có sơ đồ 4-3-3 và chưa có cầu thủ', () async {
    final lineup = await container
        .read(c01ViewModelProvider.notifier)
        .createLineup('Đội chính');

    expect(lineup.formationId, '4-3-3');
    expect(lineup.playerCount, 0);
    expect(container.read(c01ViewModelProvider).value!.length, 1);
  });

  test('C01: tài khoản khác không thấy đội hình (BR-05)', () async {
    container.listen(currentUidProvider, (_, _) {});
    await container
        .read(c01ViewModelProvider.notifier)
        .createLineup('Đội của A');

    container.read(currentUidProvider.notifier).setUid('user-b');

    expect(await container.read(c01ViewModelProvider.future), isEmpty);
  });

  test('C04: một cầu thủ không đứng hai vị trí', () async {
    final lineup = await container
        .read(c01ViewModelProvider.notifier)
        .createLineup('Đội A');
    final provider = c04ViewModelProvider(lineup.id);
    container.listen(provider, (_, _) {});
    await container.read(provider.future);
    final viewModel = container.read(provider.notifier);

    viewModel.setPlayer('ST', '9284');
    viewModel.setPlayer('RW', '9284');

    expect(container.read(provider).value!.slots, {'RW': '9284'});
  });

  test('C02: đổi 4-3-3 sang 4-4-2 thì bỏ cầu thủ ở vị trí không còn', () async {
    final lineup = await container
        .read(c01ViewModelProvider.notifier)
        .createLineup('Đội A');
    final provider = c04ViewModelProvider(lineup.id);
    container.listen(provider, (_, _) {});
    await container.read(provider.future);
    final viewModel = container.read(provider.notifier);

    viewModel.setPlayer('GK', '1');
    viewModel.setPlayer('ST', '9284');
    expect(viewModel.slotsRemovedBy('4-4-2'), ['ST']);

    viewModel.changeFormation('4-4-2');
    expect(container.read(provider).value!.slots, {'GK': '1'});
  });

  test(
    'C04: sửa xong chưa lưu thì repository chưa đổi; bấm Lưu mới ghi',
    () async {
      final lineup = await container
          .read(c01ViewModelProvider.notifier)
          .createLineup('Đội A');
      final provider = c04ViewModelProvider(lineup.id);
      container.listen(provider, (_, _) {});
      await container.read(provider.future);
      final viewModel = container.read(provider.notifier);
      final repository = container.read(lineupRepositoryProvider);

      viewModel.setPlayer('ST', '9284');
      expect(viewModel.hasUnsavedChanges, isTrue);
      expect((await repository.getLineupById(uid, lineup.id))!.slots, isEmpty);

      await viewModel.save();
      expect(viewModel.hasUnsavedChanges, isFalse);
      expect((await repository.getLineupById(uid, lineup.id))!.slots, {
        'ST': '9284',
      });
    },
  );

  test('C03: bộ sưu tập rỗng thì không có ứng viên (AC-C03)', () async {
    expect(await container.read(c03ViewModelProvider.future), isEmpty);
  });

  test('C03: ứng viên chỉ gồm cầu thủ trong bộ sưu tập', () async {
    await container
        .read(collectionRepositoryProvider)
        .addToCollection(uid: uid, playerId: '9284');

    final players = await container.read(c03ViewModelProvider.future);

    expect(players.map((p) => p.id), ['9284']);
  });

  test('C03: lọc cầu thủ chơi được vị trí ST', () {
    final viewModel = container.read(c03ViewModelProvider.notifier);
    final players = PlayerRepository.seedPlayers;

    final result = viewModel.filterPlayers(
      players,
      keyword: '',
      slot: slotOf('ST'),
      onlyMatching: true,
    );

    // Điểm vị trí từ cao xuống thấp: 125, 124, 118, 97
    expect(result.map((p) => p.name), [
      'K. MBAPPÉ',
      'E. HAALAND',
      'O. Dembélé',
      'K. ADOMAH',
    ]);
  });

  test('C03: tắt lọc thì người lệch vị trí nằm cuối, xếp theo tên', () {
    final result = container
        .read(c03ViewModelProvider.notifier)
        .filterPlayers(
          PlayerRepository.seedPlayers,
          keyword: '',
          slot: slotOf('ST'),
          onlyMatching: false,
        );

    expect(result.map((p) => p.name).toList().sublist(4), [
      'I. BENKHEDDA',
      'M. SALCEDO',
    ]);
  });

  test('C03: bằng điểm vị trí thì xếp theo tên', () {
    final json = playerById('9279').toJson();
    final an = Player.fromJson({...json, 'id': 'a', 'name': 'Ân'});
    final binh = Player.fromJson({...json, 'id': 'b', 'name': 'Bình'});

    expect(compareCandidates(an, binh, slotOf('ST')), lessThan(0));
    expect(compareCandidates(binh, an, slotOf('ST')), greaterThan(0));
  });

  test('Vị trí tương đương theo SRS UC-09', () {
    expect(slotOf('LB').acceptedRoles, containsAll(['LB', 'LWB']));
    expect(slotOf('LW').acceptedRoles, containsAll(['LW', 'LM', 'LF']));
    expect(slotOf('CM').acceptedRoles, containsAll(['CM', 'CDM', 'CAM']));
    // M. SALCEDO đá CB, có điểm CDM: chơi được slot CM
    expect(canPlaySlot(playerById('9283'), slotOf('CM')), isTrue);
    expect(canPlaySlot(playerById('9283'), slotOf('ST')), isFalse);
  });

  test('ratingForSlot: lấy điểm cao nhất trong các vị trí slot chấp nhận', () {
    // I. BENKHEDDA: CM 97, CAM 95, CDM 92
    expect(ratingForSlot(playerById('9278'), slotOf('CM')), 97);
    // M. SALCEDO: chỉ có CDM 90 trong các vị trí slot CM nhận
    expect(ratingForSlot(playerById('9283'), slotOf('CM')), 90);
    // K. MBAPPÉ: LW 122
    expect(ratingForSlot(playerById('9284'), slotOf('LW')), 122);
    expect(ratingForSlot(playerById('9283'), slotOf('ST')), 0);
  });

  test('C04: slot đỏ khi không còn sở hữu, cam khi lệch vị trí', () async {
    final collection = container.read(collectionRepositoryProvider);
    final mbappe = playerById('9284');
    await collection.addToCollection(uid: uid, playerId: '9284');
    container.listen(c04OwnedIdsProvider, (_, _) {});

    var ownedIds = await container.read(c04OwnedIdsProvider.future);
    SlotStatus statusAt(String slotId) => slotStatusOf(
      playerId: mbappe.id,
      player: mbappe,
      slot: slotOf(slotId),
      ownedIds: ownedIds,
    );
    expect(statusAt('ST'), SlotStatus.ok);
    expect(statusAt('GK'), SlotStatus.wrongPosition);

    await collection.removeFromCollection(uid: uid, playerId: '9284');
    container.invalidate(c04OwnedIdsProvider);
    ownedIds = await container.read(c04OwnedIdsProvider.future);
    expect(statusAt('ST'), SlotStatus.notOwned);
  });

  test('C04: lưu lỗi thì báo lỗi và vẫn giữ bản đang sửa', () async {
    final lineup = Lineup(
      id: 'L1',
      uid: uid,
      name: 'Đội A',
      formationId: '4-3-3',
      updatedAt: DateTime(2026, 11, 5),
    );
    final failing = ProviderContainer.test(
      overrides: [
        lineupRepositoryProvider.overrideWithValue(
          _FailingLineupRepository(lineup),
        ),
      ],
    );
    final provider = c04ViewModelProvider('L1');
    failing.listen(provider, (_, _) {});
    await failing.read(provider.future);
    final viewModel = failing.read(provider.notifier);

    viewModel.setPlayer('ST', '9284');
    await expectLater(viewModel.save(), throwsStateError);

    expect(viewModel.hasUnsavedChanges, isTrue);
    expect(failing.read(provider).value!.slots, {'ST': '9284'});
  });

  test('C02: chỉ gỡ slot không còn, slot chung được giữ (SRS-16)', () async {
    final lineup = await container
        .read(c01ViewModelProvider.notifier)
        .createLineup('Đội A');
    final provider = c04ViewModelProvider(lineup.id);
    container.listen(provider, (_, _) {});
    await container.read(provider.future);
    final viewModel = container.read(provider.notifier);

    // Chỉ có người ở slot chung → đổi sơ đồ không gỡ ai, không cần xác nhận
    viewModel.setPlayer('LCM', '9278');
    expect(viewModel.slotsRemovedBy('4-4-2'), isEmpty);

    viewModel.setPlayer('LW', '9284');
    expect(viewModel.slotsRemovedBy('4-4-2'), ['LW']);

    viewModel.changeFormation('4-4-2');
    expect(container.read(provider).value!.slots, {'LCM': '9278'});

    // Đổi ngược lại: LM, RM, LST, RST không có ở 4-3-3
    viewModel.setPlayer('LST', '9284');
    expect(viewModel.slotsRemovedBy('4-3-3'), ['LST']);

    // Chỉ sửa bản nháp: chưa bấm Lưu thì database vẫn là 4-3-3
    final saved = await container
        .read(lineupRepositoryProvider)
        .getLineupById(uid, lineup.id);
    expect(saved!.formationId, '4-3-3');
  });

  test('C03: tìm tên không phân biệt dấu', () {
    final viewModel = container.read(c03ViewModelProvider.notifier);

    final result = viewModel.filterPlayers(
      PlayerRepository.seedPlayers,
      keyword: 'mbappe',
      slot: slotOf('ST'),
      onlyMatching: true,
    );

    expect(result.single.id, '9284');
  });
}
