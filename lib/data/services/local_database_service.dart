import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Cơ sở dữ liệu SQLite dùng chung (file chung — đổi bảng cần C và E review).
///
/// Mọi bảng dữ liệu cá nhân có cột `uid` để tài khoản khác trên cùng máy
/// không thấy dữ liệu của nhau.
class LocalDatabaseService {
  const LocalDatabaseService._();

  static const _name = 'total_football.db';
  static const _version = 1;

  static Future<Database> open({String? path}) async {
    final dbPath = path ?? p.join(await getDatabasesPath(), _name);
    return openDatabase(
      dbPath,
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        final batch = db.batch();
        for (final sql in schemaV1) {
          batch.execute(sql);
        }
        await batch.commit(noResult: true);
      },
    );
  }

  static const schemaV1 = <String>[
    // Cache catalog (B) — C03/C04 đọc tên, vị trí khi offline.
    '''
    CREATE TABLE player_cache (
      id TEXT PRIMARY KEY,
      json TEXT NOT NULL,
      data_version TEXT NOT NULL,
      cached_at INTEGER NOT NULL
    )
    ''',
    // Thẻ sở hữu (E01/E02 ghi; C03 đọc làm danh sách ứng viên).
    '''
    CREATE TABLE owned_players (
      uid TEXT NOT NULL,
      player_id TEXT NOT NULL,
      note TEXT NOT NULL DEFAULT '',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      PRIMARY KEY (uid, player_id)
    )
    ''',
    // C01–C04: đội hình. synced_at null = chưa đồng bộ Firestore.
    '''
    CREATE TABLE lineups (
      id TEXT PRIMARY KEY,
      uid TEXT NOT NULL,
      name TEXT NOT NULL,
      formation_id TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      synced_at INTEGER
    )
    ''',
    // Một cầu thủ chỉ ở một slot của một đội hình (UNIQUE).
    '''
    CREATE TABLE lineup_slots (
      lineup_id TEXT NOT NULL REFERENCES lineups(id) ON DELETE CASCADE,
      slot_id TEXT NOT NULL,
      player_id TEXT NOT NULL,
      PRIMARY KEY (lineup_id, slot_id),
      UNIQUE (lineup_id, player_id)
    )
    ''',
    // Đội hình xoá khi offline, chờ xoá trên Firestore.
    '''
    CREATE TABLE lineup_deletions (
      id TEXT PRIMARY KEY,
      uid TEXT NOT NULL,
      deleted_at INTEGER NOT NULL
    )
    ''',
    'CREATE INDEX idx_lineups_uid ON lineups(uid, updated_at)',
  ];
}
