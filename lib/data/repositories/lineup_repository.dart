import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/lineup.dart';
part 'lineup_repository.g.dart';

// keepAlive: giữ repository suốt lúc app chạy, để danh sách đội hình không bị mất
// khi rời màn hình C01.
@Riverpod(keepAlive: true)
LineupRepository lineupRepository(Ref ref) {
  return LineupRepository();
}

/// Nguồn dữ liệu đội hình.
/// Giống CollectionRepository của mảng E: tạm lưu trên bộ nhớ, tách theo UID.
/// Khi nhóm thống nhất cách lưu SQLite thì chỉ cần sửa file này.
class LineupRepository {
  final Map<String, List<Lineup>> _lineupsByUid = {};

  //Danh sách đội hình của UID, mới sửa nằm trên
  Future<List<Lineup>> getLineups(String uid) async {
    final result = List<Lineup>.of(_lineupsByUid[uid] ?? const <Lineup>[]);
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  Future<Lineup?> getLineupById(String uid, String id) async {
    for (final lineup in _lineupsByUid[uid] ?? const <Lineup>[]) {
      if (lineup.id == id) {
        return lineup;
      }
    }
    return null;
  }

  //Lưu: có rồi thì thay bản cũ, chưa có thì thêm mới
  Future<void> saveLineup(Lineup lineup) async {
    final lineups = _lineupsByUid.putIfAbsent(lineup.uid, () => []);
    final index = lineups.indexWhere((l) => l.id == lineup.id);
    if (index == -1) {
      lineups.add(lineup);
    } else {
      lineups[index] = lineup;
    }
  }

  Future<void> deleteLineup(Lineup lineup) async {
    _lineupsByUid[lineup.uid]?.removeWhere((l) => l.id == lineup.id);
  }
}
