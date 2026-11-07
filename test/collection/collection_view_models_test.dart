import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:united2/data/model/comparison_record.dart';
import 'package:united2/data/repositories/collection_repository.dart';
import 'package:united2/data/repositories/comparison_history_repository.dart';
import 'package:united2/data/repositories/current_user_provider.dart';
import 'package:united2/data/repositories/player_repository.dart';
import 'package:united2/data/services/local_database_service.dart';
import 'package:united2/ui/collection/view_models/collection_view_models.dart';

void main() {
  const uid = 'e-test-user';
  late LocalDatabaseService database;
  late ProviderContainer container;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = LocalDatabaseService(path: inMemoryDatabasePath);
    await PlayerRepository(database).getPlayers();
    container = ProviderContainer.test(
      overrides: [
        localDatabaseServiceProvider.overrideWithValue(database),
        currentUidProvider.overrideWithValue(uid),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('E01: thêm, chặn trùng và xóa cầu thủ trong bộ sưu tập', () async {
    final subscription = container.listen(
      myCollectionProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await container.read(myCollectionProvider.future);
    final viewModel = container.read(myCollectionProvider.notifier);

    expect(await viewModel.addPlayer('9284', note: 'Tiền đạo chính'), isTrue);
    expect(await viewModel.addPlayer('9284'), isFalse);

    var items = await container.read(myCollectionProvider.future);
    expect(items, hasLength(1));
    expect(items.single.note, 'Tiền đạo chính');

    await viewModel.removePlayer('9284');
    items = await container.read(myCollectionProvider.future);
    expect(items, isEmpty);
  });

  test('E02: danh sách chọn cầu thủ lấy từ SQLite catalog', () async {
    final players = await container.read(collectionCandidatesProvider.future);

    expect(players, hasLength(6));
    expect(players.map((player) => player.id), contains('9284'));
  });

  test('E03: bỏ yêu thích chỉ tác động UID hiện tại', () async {
    final repository = container.read(collectionRepositoryProvider);
    await repository.setFavorite(uid: uid, playerId: '9284', isFavorite: true);
    await repository.setFavorite(
      uid: 'another-user',
      playerId: '9285',
      isFavorite: true,
    );
    final subscription = container.listen(
      favoritePlayerIdsProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(await container.read(favoritePlayerIdsProvider.future), {'9284'});
    await container
        .read(favoritePlayerIdsProvider.notifier)
        .removeFavorite('9284');

    expect(await container.read(favoritePlayerIdsProvider.future), isEmpty);
    expect(await repository.getFavoriteIds('another-user'), {'9285'});
  });

  test('E04: lịch sử so sánh đọc và xóa bản ghi SQLite', () async {
    final repository = container.read(comparisonHistoryRepositoryProvider);
    await repository.saveRecord(
      ComparisonRecord(
        id: 'record-e04',
        uid: uid,
        createdAt: DateTime.utc(2026, 11, 7),
        dataVersion: 'test',
        roleCode: 'ST',
        playerIds: const ['9284', '9285'],
        weights: const {'PAC': 50, 'SHO': 50},
        scores: const {'9284': 100.0, '9285': 99.0},
        ranks: const {'9284': 1, '9285': 2},
        entries: const [],
      ),
    );
    final subscription = container.listen(
      collectionComparisonHistoryProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(
      (await container.read(collectionComparisonHistoryProvider.future))
          .single
          .id,
      'record-e04',
    );
    await container
        .read(collectionComparisonHistoryProvider.notifier)
        .removeRecord('record-e04');

    expect(
      await container.read(collectionComparisonHistoryProvider.future),
      isEmpty,
    );
  });
}
