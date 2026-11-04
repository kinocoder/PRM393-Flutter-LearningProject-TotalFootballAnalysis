import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united2/data/repositories/collection_repository.dart';
import 'package:united2/data/repositories/current_user_provider.dart';
import 'package:united2/data/repositories/lineup_repository.dart';
import 'package:united2/data/repositories/player_repository.dart';
import 'package:united2/ui/lineups/view_models/c01_view_model.dart';
import 'package:united2/ui/lineups/view_models/c03_view_model.dart';
import 'package:united2/ui/lineups/view_models/c04_view_model.dart';

/// Unit test cho logic của mảng C (không cần giao diện, không cần điện thoại).
void main() {
  const uid = 'demo_user';
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer.test();
  });

  test('C01: tên rỗng hoặc dài quá 30 ký tự thì báo lỗi', () {
    final viewModel = container.read(c01ViewModelProvider.notifier);

    expect(viewModel.validateName(''), 'Vui lòng nhập tên đội hình');
    expect(viewModel.validateName('a' * 31), 'Tên đội hình tối đa 30 ký tự');
    expect(viewModel.validateName('Đội chính'), isNull);
  });

  test('C01: tạo đội hình mới có sơ đồ 4-3-3 và chưa có cầu thủ', () async {
    container.listen(c01ViewModelProvider, (_, _) {});
    final lineup = await container
        .read(c01ViewModelProvider.notifier)
        .createLineup('Đội chính');

    expect(lineup.formationId, '4-3-3');
    expect(lineup.playerCount, 0);
    expect(container.read(c01ViewModelProvider).value!.length, 1);
  });

  test('C01: tài khoản khác không thấy đội hình (BR-05)', () async {
    container.listen(c01ViewModelProvider, (_, _) {});
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

  test('C04: sửa xong chưa lưu thì repository chưa đổi; bấm Lưu mới ghi', () async {
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
    expect(
      (await repository.getLineupById(uid, lineup.id))!.slots,
      {'ST': '9284'},
    );
  });

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
    final players = PlayerRepository().players;

    final result = viewModel.filterPlayers(
      players,
      keyword: '',
      role: 'ST',
      onlyMatching: true,
    );

    expect(result.map((p) => p.name), [
      'O. Dembélé',
      'K. ADOMAH',
      'K. MBAPPÉ',
      'E. HAALAND',
    ]);
  });

  test('C03: tìm tên không phân biệt dấu', () {
    final viewModel = container.read(c03ViewModelProvider.notifier);

    final result = viewModel.filterPlayers(
      PlayerRepository().players,
      keyword: 'mbappe',
      role: 'ST',
      onlyMatching: true,
    );

    expect(result.single.id, '9284');
  });
}
