import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import '../model/lineup.dart';
import '../services/local_database_service.dart';
part 'lineup_repository.g.dart';

@Riverpod(keepAlive: true)
LineupRepository lineupRepository(Ref ref) {
  return LineupRepository(ref.watch(localDatabaseServiceProvider));
}

/// Nguồn dữ liệu đội hình: lưu trong SQLite trên máy, tách theo UID.
/// Tắt ứng dụng mở lại, hoặc không có mạng, vẫn còn đội hình đã lưu.
class LineupRepository {
  final LocalDatabaseService _databaseService;

  LineupRepository(this._databaseService);

  //Danh sách đội hình của UID, mới sửa nằm trên
  Future<List<Lineup>> getLineups(String uid) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'lineups',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'updated_at DESC',
    );
    return [for (final row in rows) await _toLineup(db, row)];
  }

  Future<Lineup?> getLineupById(String uid, String id) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'lineups',
      where: 'id = ? AND uid = ?',
      whereArgs: [id, uid],
    );
    if (rows.isEmpty) return null;
    return _toLineup(db, rows.first);
  }

  //Ghép 1 dòng bảng lineups với các dòng vị trí của nó thành Lineup
  Future<Lineup> _toLineup(Database db, Map<String, Object?> row) async {
    final slotRows = await db.query(
      'lineup_slots',
      where: 'lineup_id = ?',
      whereArgs: [row['id']],
    );
    return Lineup(
      id: row['id'] as String,
      uid: row['uid'] as String,
      name: row['name'] as String,
      formationId: row['formation_id'] as String,
      slots: {
        for (final slot in slotRows)
          slot['slot_id'] as String: slot['player_id'] as String,
      },
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
    );
  }

  //Lưu: có rồi thì thay bản cũ, chưa có thì thêm mới.
  //Transaction: bảng lineups và lineup_slots cùng thành công hoặc cùng không đổi.
  Future<void> saveLineup(Lineup lineup) async {
    final db = await _databaseService.database;
    final updatedAt = lineup.updatedAt.millisecondsSinceEpoch;

    await db.transaction((txn) async {
      final values = <String, Object?>{
        'name': lineup.name,
        'formation_id': lineup.formationId,
        'updated_at': updatedAt,
        'synced_at': null, // Bản mới này chưa được đồng bộ
      };
      final updatedRows = await txn.update(
        'lineups',
        values,
        where: 'id = ? AND uid = ?',
        whereArgs: [lineup.id, lineup.uid],
      );
      if (updatedRows == 0) {
        await txn.insert('lineups', {
          ...values,
          'id': lineup.id,
          'uid': lineup.uid,
          'created_at': updatedAt,
        });
      }

      await txn.delete(
        'lineup_slots',
        where: 'lineup_id = ?',
        whereArgs: [lineup.id],
      );
      for (final slot in lineup.formation.slots) {
        final playerId = lineup.slots[slot.id];
        if (playerId == null) continue;
        await txn.insert('lineup_slots', {
          'lineup_id': lineup.id,
          'slot_id': slot.id,
          'position': slot.role,
          'player_id': playerId,
        });
      }
    });
  }

  //Xoá đội hình (lineup_slots tự xoá theo) và ghi lại để sau này xoá trên Firestore
  Future<void> deleteLineup(Lineup lineup) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      final deletedRows = await txn.delete(
        'lineups',
        where: 'id = ? AND uid = ?',
        whereArgs: [lineup.id, lineup.uid],
      );
      if (deletedRows == 0) return;
      await txn.insert('lineup_deletions', {
        'id': lineup.id,
        'uid': lineup.uid,
        'deleted_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}
