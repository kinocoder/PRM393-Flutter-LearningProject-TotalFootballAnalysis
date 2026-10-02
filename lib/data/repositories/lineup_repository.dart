import '../../config/app_config.dart';
import '../../domain/models/lineup.dart';
import '../../utils/app_exception.dart';
import '../services/lineup_firestore_service.dart';
import '../services/lineup_local_service.dart';

/// Kết quả một lần đồng bộ Firestore. Lỗi không ném ra ngoài để không chặn
/// người dùng khi offline.
class SyncResult {
  const SyncResult({this.pushed = 0, this.pulled = 0, this.error, this.enabled = true});

  final int pushed;
  final int pulled;
  final Object? error;

  /// `false` khi chạy không có Firebase (chỉ lưu trên máy).
  final bool enabled;

  bool get ok => error == null;
}

/// C01–C04 — đội hình. SQLite là nguồn chính (offline-first); Firestore là
/// bản sao theo UID khi Firebase đã cấu hình.
abstract class LineupRepository {
  Future<List<Lineup>> list(String uid);
  Future<Lineup?> get(String uid, String id);
  Future<void> save(Lineup lineup);
  Future<void> delete(String uid, String id);
  Future<void> restore(Lineup lineup);
  Future<SyncResult> sync(String uid);
}

class DefaultLineupRepository implements LineupRepository {
  DefaultLineupRepository({required LineupLocalService local, LineupFirestoreService? remote})
      : _local = local,
        _remote = remote;

  final LineupLocalService _local;
  final LineupFirestoreService? _remote;

  @override
  Future<List<Lineup>> list(String uid) => _local.list(uid);

  @override
  Future<Lineup?> get(String uid, String id) => _local.get(uid, id);

  @override
  Future<void> save(Lineup lineup) async {
    if (lineup.slots.values.toSet().length != lineup.slots.length) {
      throw const AppException('Một cầu thủ không thể đứng ở hai vị trí.', code: 'duplicate_slot');
    }
    await _local.upsert(lineup);
    await _tryPush(lineup);
  }

  Future<bool> _tryPush(Lineup lineup) async {
    final remote = _remote;
    if (remote == null) return false;
    try {
      await remote.upsert(lineup).timeout(AppConfig.syncTimeout);
      await _local.markSynced(lineup);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> delete(String uid, String id) async {
    await _local.delete(uid, id);
    final remote = _remote;
    if (remote == null) return;
    try {
      await remote.delete(uid, id).timeout(AppConfig.syncTimeout);
      await _local.clearDeletion(id);
    } catch (_) {
      // Còn trong lineup_deletions — lần sync sau xoá tiếp.
    }
  }

  @override
  Future<void> restore(Lineup lineup) => save(lineup.copyWith(updatedAt: DateTime.now()));

  @override
  Future<SyncResult> sync(String uid) async {
    final remote = _remote;
    if (remote == null) return const SyncResult(enabled: false);
    var pushed = 0;
    var pulled = 0;
    try {
      final deleted = <String>{};
      for (final id in await _local.pendingDeletions(uid)) {
        await remote.delete(uid, id).timeout(AppConfig.syncTimeout);
        await _local.clearDeletion(id);
        deleted.add(id);
      }
      for (final l in await _local.unsynced(uid)) {
        if (await _tryPush(l)) pushed++;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final r in await remote.fetchAll(uid).timeout(AppConfig.syncTimeout)) {
        if (deleted.contains(r.id) || r.uid != uid) continue;
        final local = await _local.get(uid, r.id);
        if (local == null || r.updatedAt.isAfter(local.updatedAt)) {
          await _local.upsert(r, syncedAt: now);
          pulled++;
        }
      }
      return SyncResult(pushed: pushed, pulled: pulled);
    } catch (e) {
      return SyncResult(pushed: pushed, pulled: pulled, error: e);
    }
  }
}
