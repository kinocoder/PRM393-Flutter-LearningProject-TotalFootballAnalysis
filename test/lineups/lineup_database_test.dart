import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:united2/data/model/lineup.dart';
import 'package:united2/data/repositories/lineup_repository.dart';
import 'package:united2/data/services/local_database_service.dart';

/// Kiểm tra lưu đội hình bằng SQLite thật, ghi ra file như trên điện thoại.
void main() {
  late Directory folder;
  late String dbPath;
  late LocalDatabaseService service;
  late LineupRepository repository;

  Lineup sampleLineup({
    String id = 'L1',
    String uid = 'user-a',
    String name = 'Đội chính',
    Map<String, String> slots = const {'GK': '1', 'ST': '9284'},
  }) {
    return Lineup(
      id: id,
      uid: uid,
      name: name,
      formationId: '4-3-3',
      slots: slots,
      updatedAt: DateTime(2026, 11, 5, 8),
    );
  }

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    folder = Directory.systemTemp.createTempSync('lineup_db_');
    dbPath = p.join(folder.path, 'test.db');
    service = LocalDatabaseService(path: dbPath);
    repository = LineupRepository(service);
  });

  tearDown(() async {
    await service.close();
    folder.deleteSync(recursive: true);
  });

  test('Đóng database mở lại vẫn còn đội hình đã lưu', () async {
    await repository.saveLineup(sampleLineup());
    await service.close();

    final reopened = LocalDatabaseService(path: dbPath);
    addTearDown(reopened.close);
    final lineup = await LineupRepository(
      reopened,
    ).getLineupById('user-a', 'L1');

    expect(lineup!.name, 'Đội chính');
    expect(lineup.formationId, '4-3-3');
    expect(lineup.slots, {'GK': '1', 'ST': '9284'});
    expect(lineup.updatedAt, DateTime(2026, 11, 5, 8));
  });

  test('Tài khoản khác không đọc, không xoá được đội hình (BR-05)', () async {
    await repository.saveLineup(sampleLineup());

    expect(await repository.getLineups('user-b'), isEmpty);
    expect(await repository.getLineupById('user-b', 'L1'), isNull);

    await repository.deleteLineup(sampleLineup(uid: 'user-b'));
    expect(await repository.getLineupById('user-a', 'L1'), isNotNull);
  });

  test('Danh sách: đội hình mới sửa nằm trên', () async {
    await repository.saveLineup(sampleLineup(id: 'cu'));
    await repository.saveLineup(
      sampleLineup(id: 'moi').copyWith(updatedAt: DateTime(2026, 11, 6)),
    );

    final lineups = await repository.getLineups('user-a');

    expect(lineups.map((l) => l.id), ['moi', 'cu']);
  });

  test('Transaction: lưu lỗi thì bản cũ còn nguyên', () async {
    await repository.saveLineup(sampleLineup());

    // Cùng một cầu thủ ở hai vị trí → vi phạm UNIQUE giữa chừng
    final broken = sampleLineup(
      name: 'Tên mới',
      slots: const {'ST': '7', 'RW': '7'},
    );
    await expectLater(repository.saveLineup(broken), throwsA(anything));

    final lineup = await repository.getLineupById('user-a', 'L1');
    expect(lineup!.name, 'Đội chính');
    expect(lineup.slots, {'GK': '1', 'ST': '9284'});
  });

  test('Tên quá 30 ký tự bị database từ chối', () async {
    await expectLater(
      repository.saveLineup(sampleLineup(name: 'a' * 31)),
      throwsA(anything),
    );
  });

  test('Xoá: vị trí bị xoá theo và ghi lại chờ xoá trên Firestore', () async {
    await repository.saveLineup(sampleLineup());

    await repository.deleteLineup(sampleLineup());

    final db = await service.database;
    expect(await repository.getLineups('user-a'), isEmpty);
    expect(await db.query('lineup_slots'), isEmpty);
    final deletions = await db.query('lineup_deletions');
    expect(deletions.single['id'], 'L1');
    expect(deletions.single['uid'], 'user-a');
  });

  test('Lưu lại: chưa đồng bộ (synced_at null), giữ created_at', () async {
    await repository.saveLineup(sampleLineup());
    final db = await service.database;
    await db.update('lineups', {'synced_at': 123});

    await repository.saveLineup(
      sampleLineup().copyWith(updatedAt: DateTime(2026, 12, 1)),
    );

    final row = (await db.query('lineups')).single;
    expect(row['synced_at'], isNull);
    expect(row['created_at'], DateTime(2026, 11, 5, 8).millisecondsSinceEpoch);
    expect(row['updated_at'], DateTime(2026, 12, 1).millisecondsSinceEpoch);
  });

  test('Migration: nâng phiên bản không mất dữ liệu cũ', () async {
    await repository.saveLineup(sampleLineup());
    await service.close();

    final upgraded = LocalDatabaseService(
      path: dbPath,
      migrations: {
        ...databaseMigrations,
        2: ['ALTER TABLE lineups ADD COLUMN note TEXT'],
      },
    );
    addTearDown(upgraded.close);
    final db = await upgraded.database;

    expect(await db.getVersion(), 2);
    expect((await db.query('lineups')).single.containsKey('note'), isTrue);
    expect(
      (await LineupRepository(upgraded).getLineupById('user-a', 'L1'))!.slots,
      {'GK': '1', 'ST': '9284'},
    );
  });
}
