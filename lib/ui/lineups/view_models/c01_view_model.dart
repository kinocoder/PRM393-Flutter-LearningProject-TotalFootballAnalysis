import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/current_user_provider.dart';
import '../../../data/providers/lineup_repository_provider.dart';
import '../../../data/repositories/lineup_repository.dart';
import '../../../domain/models/formation.dart';
import '../../../domain/models/lineup.dart';
import '../../../utils/app_exception.dart';
import '../../../utils/id_generator.dart';
import 'lineup_draft_view_model.dart';

const lineupNameMaxLength = 30;

/// Quy tắc tên đội hình (C01, C04). Trả `null` nếu hợp lệ.
String? validateLineupName(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Tên đội hình không được để trống.';
  if (v.length > lineupNameMaxLength) return 'Tên tối đa $lineupNameMaxLength ký tự.';
  return null;
}

/// C01 — danh sách đội hình theo UID (đọc SQLite, xem được offline).
class C01ViewModel extends AsyncNotifier<List<Lineup>> {
  LineupRepository get _repo => ref.read(lineupRepositoryProvider);

  String _requireUid() {
    final uid = ref.read(currentUidProvider);
    if (uid == null) throw const AppException('Bạn cần đăng nhập để dùng đội hình.', code: 'no_uid');
    return uid;
  }

  @override
  Future<List<Lineup>> build() async {
    final uid = ref.watch(currentUidProvider);
    if (uid == null) return const [];
    return ref.watch(lineupRepositoryProvider).list(uid);
  }

  Future<void> reload() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    state = await AsyncValue.guard(() => _repo.list(uid));
  }

  /// Tạo đội hình 4-3-3 trống và trả về để mở C02.
  Future<Lineup> create(String name) async {
    final error = validateLineupName(name);
    if (error != null) throw AppException(error, code: 'invalid_name');
    final now = DateTime.now();
    final lineup = Lineup(
      id: newId(),
      uid: _requireUid(),
      name: name.trim(),
      formationId: Formations.f433.id,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.save(lineup);
    await reload();
    return lineup;
  }

  Future<void> rename(Lineup lineup, String name) async {
    final error = validateLineupName(name);
    if (error != null) throw AppException(error, code: 'invalid_name');
    await _repo.save(lineup.copyWith(name: name.trim(), updatedAt: DateTime.now()));
    ref.invalidate(lineupDraftViewModelProvider(lineup.id));
    await reload();
  }

  Future<void> delete(Lineup lineup) async {
    await _repo.delete(lineup.uid, lineup.id);
    ref.invalidate(lineupDraftViewModelProvider(lineup.id));
    await reload();
  }

  /// Nút "Hoàn tác" sau khi xoá.
  Future<void> restore(Lineup lineup) async {
    await _repo.restore(lineup);
    await reload();
  }
}

final c01ViewModelProvider = AsyncNotifierProvider<C01ViewModel, List<Lineup>>(C01ViewModel.new);

/// Đồng bộ Firestore khi mở C01 / kéo làm mới. Lỗi chỉ hiện cảnh báo.
final lineupSyncProvider = FutureProvider<SyncResult>((ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const SyncResult(enabled: false);
  final result = await ref.watch(lineupRepositoryProvider).sync(uid);
  if (result.pulled > 0) ref.invalidate(c01ViewModelProvider);
  return result;
});
