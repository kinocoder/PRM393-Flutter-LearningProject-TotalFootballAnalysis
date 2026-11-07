import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../model/comparison_record.dart';
import '../services/local_database_service.dart';

part 'comparison_history_repository.g.dart';

@Riverpod(keepAlive: true)
ComparisonHistoryRepository comparisonHistoryRepository(Ref ref) {
  return ComparisonHistoryRepository(ref.watch(localDatabaseServiceProvider));
}

class ComparisonHistoryRepository {
  ComparisonHistoryRepository(this._databaseService);

  final LocalDatabaseService _databaseService;

  Future<void> saveRecord(ComparisonRecord record) async {
    final db = await _databaseService.database;
    await db.insert('comparison_history', {
      'id': record.id,
      'uid': record.uid,
      'created_at': record.createdAt.millisecondsSinceEpoch,
      'record_json': jsonEncode(record.toJson()),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ComparisonRecord>> getHistoryByUid(String uid) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'comparison_history',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'created_at DESC',
    );
    return rows.map(_toRecord).toList(growable: false);
  }

  Future<ComparisonRecord?> getRecordById(String id) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'comparison_history',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _toRecord(rows.first);
  }

  Future<void> deleteRecord(String id) async {
    final db = await _databaseService.database;
    await db.delete('comparison_history', where: 'id = ?', whereArgs: [id]);
  }

  ComparisonRecord _toRecord(Map<String, Object?> row) {
    return ComparisonRecord.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(row['record_json'] as String) as Map,
      ),
    );
  }
}
