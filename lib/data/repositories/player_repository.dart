import '../../domain/models/player.dart';
import '../services/player_api_service.dart';
import '../services/player_cache_service.dart';
import '../services/sample_player_service.dart';

/// Nguồn dữ liệu cầu thủ dùng chung (A, B, C, E). Mảng B sở hữu file này và
/// sẽ bổ sung phân trang/tìm kiếm; phần C chỉ cần tra cứu theo ID.
abstract class PlayerRepository {
  /// Lấy thông tin các thẻ theo ID. ID không tìm được (thẻ bị xoá khỏi
  /// catalog, offline mà chưa cache) thì vắng trong kết quả — màn hình tự
  /// hiển thị "Thẻ <id>".
  Future<Map<String, Player>> getPlayersByIds(Iterable<String> ids);

  /// Toàn bộ thẻ mẫu đóng gói trong app (dùng cho nút seed ở bản debug).
  Future<List<Player>> samplePlayers();
}

class DefaultPlayerRepository implements PlayerRepository {
  DefaultPlayerRepository({
    required PlayerApiService api,
    required PlayerCacheService cache,
    required SamplePlayerService sample,
  })  : _api = api,
        _cache = cache,
        _sample = sample;

  final PlayerApiService _api;
  final PlayerCacheService _cache;
  final SamplePlayerService _sample;

  @override
  Future<Map<String, Player>> getPlayersByIds(Iterable<String> ids) async {
    final wanted = ids.toSet();
    if (wanted.isEmpty) return {};

    // 1. Cache trước: chạy được khi offline.
    final found = await _cache.getMany(wanted);

    // 2. API cho các ID chưa có.
    final missing = wanted.difference(found.keys.toSet());
    if (missing.isNotEmpty) {
      final fetched = await Future.wait(missing.map((id) async {
        try {
          return await _api.fetchPlayer(id);
        } catch (_) {
          return null;
        }
      }));
      final ok = fetched.whereType<Player>().toList();
      await _cache.putAll(ok);
      for (final p in ok) {
        found[p.id] = p;
      }
    }

    // 3. Dữ liệu mẫu đóng gói cho các ID còn thiếu.
    final stillMissing = wanted.difference(found.keys.toSet());
    if (stillMissing.isNotEmpty) {
      final sample = await _sample.all();
      for (final id in stillMissing) {
        final p = sample[id];
        if (p != null) found[id] = p;
      }
    }
    return found;
  }

  @override
  Future<List<Player>> samplePlayers() async => (await _sample.all()).values.toList();
}
