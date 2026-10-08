import 'package:sqflite/sqflite.dart';

import '../../domain/models/lineup.dart';

/// Đọc/ghi đội hình trong SQLite (bảng `lineups`, `lineup_slots`,
/// `lineup_deletions`). Không chứa quy tắc nghiệp vụ — xem LineupRepository.
class LineupLocalService {
  LineupLocalService(this._db);

  final Database _db;

  Future<Map<String, String>> _slots(DatabaseExecutor db, String lineupId) async {
    final rows = await db.query('lineup_slots', where: 'lineup_id = ?', whereArgs: [lineupId]);
    return {for (final r in rows) r['slot_id'] as String: r['player_id'] as String};
  }

  Future<Lineup> _fromRow(DatabaseExecutor db, Map<String, Object?> row) async => Lineup(
        id: row['id'] as String,
        uid: row['uid'] as String,
        name: row['name'] as String,
        formationId: row['formation_id'] as String,
        slots: await _slots(db, row['id'] as String),
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
      );

  Future<List<Lineup>> list(String uid) async {
    final rows = await _db.query('lineups', where: 'uid = ?', whereArgs: [uid], orderBy: 'updated_at DESC');
    return [for (final r in rows) await _fromRow(_db, r)];
  }

  Future<Lineup?> get(String uid, String id) async {
    final rows = await _db.query('lineups', where: 'uid = ? AND id = ?', whereArgs: [uid, id], limit: 1);
    return rows.isEmpty ? null : await _fromRow(_db, rows.first);
  }

  /// Ghi đè đội hình và toàn bộ slot trong một transaction.
  Future<void> upsert(Lineup lineup, {int? syncedAt}) {
    return _db.transaction((txn) async {
      await txn.insert(
        'lineups',
        {
          'id': lineup.id,
          'uid': lineup.uid,
          'name': lineup.name,
          'formation_id': lineup.formationId,
          'created_at': lineup.createdAt.millisecondsSinceEpoch,
          'updated_at': lineup.updatedAt.millisecondsSinceEpoch,
          'synced_at': syncedAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete('lineup_slots', where: 'lineup_id = ?', whereArgs: [lineup.id]);
      for (final e in lineup.slots.entries) {
        await txn.insert('lineup_slots', {'lineup_id': lineup.id, 'slot_id': e.key, 'player_id': e.value});
      }
      await txn.delete('lineup_deletions', where: 'id = ?', whereArgs: [lineup.id]);
    });
  }

  /// Đánh dấu đã đồng bộ nếu bản local chưa bị sửa tiếp.
  Future<void> markSynced(Lineup lineup) => _db.update(
        'lineups',
        {'synced_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ? AND updated_at = ?',
        whereArgs: [lineup.id, lineup.updatedAt.millisecondsSinceEpoch],
      );

  Future<List<Lineup>> unsynced(String uid) async {
    final rows = await _db.query(
      'lineups',
      where: 'uid = ? AND (synced_at IS NULL OR synced_at < updated_at)',
      whereArgs: [uid],
    );
    return [for (final r in rows) await _fromRow(_db, r)];
  }

  /// Xoá local và ghi nhớ để xoá trên Firestore khi có mạng.
  Future<void> delete(String uid, String id) {
    return _db.transaction((txn) async {
      await txn.delete('lineups', where: 'uid = ? AND id = ?', whereArgs: [uid, id]);
      await txn.insert(
        'lineup_deletions',
        {'id': id, 'uid': uid, 'deleted_at': DateTime.now().millisecondsSinceEpoch},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<List<String>> pendingDeletions(String uid) async {
    final rows = await _db.query('lineup_deletions', where: 'uid = ?', whereArgs: [uid]);
    return [for (final r in rows) r['id'] as String];
  }

  Future<void> clearDeletion(String id) =>
      _db.delete('lineup_deletions', where: 'id = ?', whereArgs: [id]);
}
