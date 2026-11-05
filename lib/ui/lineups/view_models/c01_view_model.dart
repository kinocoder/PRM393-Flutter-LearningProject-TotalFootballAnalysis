import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/formation.dart';
import '../../../data/model/lineup.dart';
import '../../../data/repositories/current_user_provider.dart';
import '../../../data/repositories/lineup_repository.dart';
part 'c01_view_model.g.dart';

/// C01 — Danh sách đội hình.
@riverpod
class C01ViewModel extends _$C01ViewModel {
  @override
  FutureOr<List<Lineup>> build() async {
    // watch: đổi tài khoản thì danh sách tự tải lại
    final uid = ref.watch(currentUidProvider);
    return ref.read(lineupRepositoryProvider).getLineups(uid);
  }

  Future<List<Lineup>> _fetchLineups() async {
    final repository = ref.read(lineupRepositoryProvider);
    return await repository.getLineups(ref.read(currentUidProvider));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => _fetchLineups());
    // Người dùng có thể đã rời màn hình trong lúc đọc SQLite
    if (ref.mounted) state = result;
  }

  //Tên đội hình: không rỗng, tối đa 30 ký tự
  String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Vui lòng nhập tên đội hình';
    }
    if (name.length > 30) {
      return 'Tên đội hình tối đa 30 ký tự';
    }
    return null;
  }

  //Tạo đội hình mới: sơ đồ mặc định 4-3-3, chưa có cầu thủ
  Future<Lineup> createLineup(String name) async {
    final now = DateTime.now();
    final lineup = Lineup(
      id: now.millisecondsSinceEpoch.toString(),
      uid: ref.read(currentUidProvider),
      name: name.trim(),
      formationId: Formations.f433.id,
      updatedAt: now,
    );
    await ref.read(lineupRepositoryProvider).saveLineup(lineup);
    if (ref.mounted) await refresh();
    return lineup;
  }

  Future<void> renameLineup(Lineup lineup, String name) async {
    final renamed = lineup.copyWith(name: name.trim(), updatedAt: DateTime.now());
    await ref.read(lineupRepositoryProvider).saveLineup(renamed);
    if (ref.mounted) await refresh();
  }

  Future<void> deleteLineup(Lineup lineup) async {
    await ref.read(lineupRepositoryProvider).deleteLineup(lineup);
    if (ref.mounted) await refresh();
  }
}
