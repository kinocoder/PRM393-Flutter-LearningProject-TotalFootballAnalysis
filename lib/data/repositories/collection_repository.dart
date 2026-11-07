import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../model/collection_entry.dart';
import '../services/local_database_service.dart';

part 'collection_repository.g.dart';

@Riverpod(keepAlive: true)
CollectionRepository collectionRepository(Ref ref) {
  return CollectionRepository(ref.watch(localDatabaseServiceProvider));
}

class CollectionRepository {
  CollectionRepository(this._databaseService);

  final LocalDatabaseService _databaseService;

  Future<List<CollectionEntry>> getCollection(String uid) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'collection_entries',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'added_at DESC',
    );
    return rows
        .map(
          (row) => CollectionEntry(
            playerId: row['player_id'] as String,
            note: row['note'] as String,
            addedAt: DateTime.fromMillisecondsSinceEpoch(
              row['added_at'] as int,
            ),
          ),
        )
        .toList(growable: false);
  }

  Future<bool> addToCollection({
    required String uid,
    required String playerId,
    String note = '',
  }) async {
    final db = await _databaseService.database;
    final result = await db.insert('collection_entries', {
      'uid': uid,
      'player_id': playerId,
      'note': note.trim(),
      'added_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    return result != 0;
  }

  Future<void> removeFromCollection({
    required String uid,
    required String playerId,
  }) async {
    final db = await _databaseService.database;
    await db.delete(
      'collection_entries',
      where: 'uid = ? AND player_id = ?',
      whereArgs: [uid, playerId],
    );
  }

  Future<Set<String>> getFavoriteIds(String uid) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'favorite_players',
      columns: ['player_id'],
      where: 'uid = ?',
      whereArgs: [uid],
    );
    return rows.map((row) => row['player_id'] as String).toSet();
  }

  Future<void> setFavorite({
    required String uid,
    required String playerId,
    required bool isFavorite,
  }) async {
    final db = await _databaseService.database;
    if (isFavorite) {
      await db.insert('favorite_players', {
        'uid': uid,
        'player_id': playerId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      return;
    }
    await db.delete(
      'favorite_players',
      where: 'uid = ? AND player_id = ?',
      whereArgs: [uid, playerId],
    );
  }
}
