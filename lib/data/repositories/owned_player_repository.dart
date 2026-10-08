import '../services/owned_player_service.dart';

/// Hợp đồng đọc thẻ sở hữu giữa E (ghi) và C (đọc ở C03/C04).
abstract class OwnedPlayerRepository {
  Future<List<String>> ownedPlayerIds(String uid);

  /// Chỉ cho bản debug khi chưa có E02.
  Future<void> addSampleOwned(String uid, List<String> playerIds);
}

class SqliteOwnedPlayerRepository implements OwnedPlayerRepository {
  SqliteOwnedPlayerRepository(this._service);

  final OwnedPlayerService _service;

  @override
  Future<List<String>> ownedPlayerIds(String uid) => _service.ownedPlayerIds(uid);

  @override
  Future<void> addSampleOwned(String uid, List<String> playerIds) =>
      _service.addSampleOwned(uid, playerIds);
}
