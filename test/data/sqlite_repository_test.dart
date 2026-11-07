import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:united2/data/model/comparison_record.dart';
import 'package:united2/data/repositories/collection_repository.dart';
import 'package:united2/data/repositories/comparison_history_repository.dart';
import 'package:united2/data/repositories/player_repository.dart';
import 'package:united2/data/services/local_database_service.dart';

void main() {
  late LocalDatabaseService database;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = LocalDatabaseService(path: inMemoryDatabasePath);
    await PlayerRepository(database).getPlayers();
  });

  tearDown(() => database.close());

  test('SQLite seeds the player catalog once and reads it back', () async {
    final repository = PlayerRepository(database);

    final players = await repository.getPlayers();

    expect(players, hasLength(6));
    expect(await repository.getPlayerByID('9284'), isNotNull);
  });

  test('collection and favorites are isolated by Firebase UID', () async {
    final repository = CollectionRepository(database);

    expect(
      await repository.addToCollection(uid: 'user-a', playerId: '9284'),
      isTrue,
    );
    expect(
      await repository.addToCollection(uid: 'user-a', playerId: '9284'),
      isFalse,
    );
    await repository.setFavorite(
      uid: 'user-a',
      playerId: '9284',
      isFavorite: true,
    );

    expect(await repository.getCollection('user-b'), isEmpty);
    expect(await repository.getFavoriteIds('user-b'), isEmpty);
    expect(await repository.getFavoriteIds('user-a'), {'9284'});
  });

  test('comparison history persists its JSON record', () async {
    final repository = ComparisonHistoryRepository(database);
    final record = ComparisonRecord(
      id: 'comparison-1',
      uid: 'user-a',
      createdAt: DateTime.utc(2026, 11, 7),
      dataVersion: 'test',
      roleCode: 'ST',
      playerIds: const ['9284', '9285'],
      weights: const {'PAC': 50, 'SHO': 50},
      scores: const {'9284': 100.0, '9285': 99.0},
      ranks: const {'9284': 1, '9285': 2},
      entries: const [],
    );

    await repository.saveRecord(record);

    expect(
      (await repository.getHistoryByUid('user-a')).single.playerIds,
      record.playerIds,
    );
    expect(await repository.getHistoryByUid('user-b'), isEmpty);
  });
}
