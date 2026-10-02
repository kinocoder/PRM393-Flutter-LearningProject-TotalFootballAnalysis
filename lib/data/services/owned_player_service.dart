import 'package:sqflite/sqflite.dart';

/// Đọc thẻ sở hữu (bảng `owned_players`). Mảng E sở hữu việc ghi dữ liệu;
/// phần C chỉ đọc danh sách ID làm ứng viên ở C03.
class OwnedPlayerService {
  OwnedPlayerService(this._db);

  final Database _db;

  Future<List<String>> ownedPlayerIds(String uid) async {
    final rows = await _db.query(
      'owned_players',
      columns: ['player_id'],
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'updated_at DESC',
    );
    return [for (final r in rows) r['player_id'] as String];
  }

  /// Chỉ dùng cho nút "Thêm thẻ mẫu" ở bản debug khi E chưa xong.
  Future<void> addSampleOwned(String uid, List<String> playerIds) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = _db.batch();
    for (final id in playerIds) {
      batch.insert(
        'owned_players',
        {'uid': uid, 'player_id': id, 'note': '', 'created_at': now, 'updated_at': now},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }
}
