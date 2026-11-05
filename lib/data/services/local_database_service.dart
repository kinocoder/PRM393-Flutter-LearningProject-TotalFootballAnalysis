import 'dart:math';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
part 'local_database_service.g.dart';

@Riverpod(keepAlive: true)
LocalDatabaseService localDatabaseService(Ref ref) {
  return LocalDatabaseService();
}

/// Các bước tạo/nâng cấp bảng, theo số phiên bản (schema version).
/// Muốn đổi cấu trúc: KHÔNG sửa bước cũ, chỉ thêm bước mới (2, 3...).
/// Máy cũ tự chạy các bước còn thiếu nên dữ liệu đã lưu không mất.
const Map<int, List<String>> databaseMigrations = {
  1: [
    // Thời gian lưu dạng số: mili giây từ 1970 theo UTC.
    // synced_at = NULL nghĩa là đã lưu trên máy nhưng chưa đồng bộ lên Firestore.
    '''
    CREATE TABLE lineups(
      id TEXT PRIMARY KEY,
      uid TEXT NOT NULL,
      name TEXT NOT NULL CHECK(length(name) BETWEEN 1 AND 30),
      formation_id TEXT NOT NULL CHECK(formation_id IN ('4-3-3', '4-4-2')),
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      synced_at INTEGER
    )
    ''',
    'CREATE INDEX idx_lineups_uid ON lineups(uid, updated_at)',
    // Vị trí trống thì không có dòng nên player_id luôn có giá trị.
    // UNIQUE(lineup_id, player_id): một cầu thủ không đứng hai vị trí (BR-07).
    // ON DELETE CASCADE: xoá đội hình thì các vị trí bị xoá theo.
    '''
    CREATE TABLE lineup_slots(
      lineup_id TEXT NOT NULL REFERENCES lineups(id) ON DELETE CASCADE,
      slot_id TEXT NOT NULL,
      position TEXT NOT NULL,
      player_id TEXT NOT NULL,
      PRIMARY KEY(lineup_id, slot_id),
      UNIQUE(lineup_id, player_id)
    )
    ''',
    // Đội hình đã xoá trên máy, chờ xoá trên Firestore khi đồng bộ.
    '''
    CREATE TABLE lineup_deletions(
      id TEXT PRIMARY KEY,
      uid TEXT NOT NULL,
      deleted_at INTEGER NOT NULL
    )
    ''',
  ],
};

/// Mở file SQLite của ứng dụng. Các repository dùng chung một service này.
class LocalDatabaseService {
  /// [path] và [migrations] chỉ truyền khi viết test.
  final String? path;
  final Map<int, List<String>> migrations;
  Future<Database>? _opening;

  LocalDatabaseService({this.path, this.migrations = databaseMigrations});

  //Chỉ mở một lần; lần sau dùng lại kết nối đã mở
  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    try {
      return await openDatabase(
        path ?? join(await getDatabasesPath(), 'total_football.db'),
        version: migrations.keys.reduce(max),
        // SQLite mặc định tắt khoá ngoại, phải bật mỗi lần mở
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) => _migrate(db, 0, version),
        onUpgrade: _migrate,
      );
    } catch (_) {
      _opening = null; // Lần sau được thử mở lại
      rethrow;
    }
  }

  //Chạy các bước còn thiếu từ phiên bản cũ lên phiên bản mới
  Future<void> _migrate(Database db, int oldVersion, int newVersion) async {
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      for (final sql in migrations[version] ?? const <String>[]) {
        await db.execute(sql);
      }
    }
  }

  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening != null) await (await opening).close();
  }
}
