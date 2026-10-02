import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../domain/models/player.dart';

/// Cache catalog trong SQLite (bảng `player_cache`).
class PlayerCacheService {
  PlayerCacheService(this._db);

  final Database _db;

  Future<void> putAll(List<Player> players) async {
    if (players.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = _db.batch();
    for (final p in players) {
      batch.insert(
        'player_cache',
        {'id': p.id, 'json': jsonEncode(p.toJson()), 'data_version': p.dataVersion, 'cached_at': now},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, Player>> getMany(Iterable<String> ids) async {
    final list = ids.toSet().toList();
    if (list.isEmpty) return {};
    final placeholders = List.filled(list.length, '?').join(',');
    final rows = await _db.query('player_cache', where: 'id IN ($placeholders)', whereArgs: list);
    return {
      for (final r in rows)
        r['id'] as String: Player.fromJson((jsonDecode(r['json'] as String) as Map).cast<String, dynamic>()),
    };
  }
}
