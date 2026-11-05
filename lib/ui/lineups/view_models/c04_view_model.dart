import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/formation.dart';
import '../../../data/model/lineup.dart';
import '../../../data/model/player.dart';
import '../../../data/repositories/collection_repository.dart';
import '../../../data/repositories/current_user_provider.dart';
import '../../../data/repositories/lineup_repository.dart';
import '../../../data/repositories/player_repository.dart';
import 'c01_view_model.dart';
import 'c03_view_model.dart';
part 'c04_view_model.g.dart';

/// Thông tin cầu thủ để hiện trên sân. Lấy cả danh mục, vì cầu thủ đã xếp
/// có thể đã bị gỡ khỏi bộ sưu tập nhưng vẫn cần hiện đúng tên.
@riverpod
Future<List<Player>> c04Players(Ref ref) {
  return ref.watch(playerRepositoryProvider).getPlayers();
}

/// ID các cầu thủ người dùng còn sở hữu (bộ sưu tập của mảng E).
@riverpod
Future<Set<String>> c04OwnedIds(Ref ref) async {
  final uid = ref.watch(currentUidProvider);
  final repository = ref.read(collectionRepositoryProvider);
  final entries = await repository.getCollection(uid);
  return {for (final entry in entries) entry.playerId};
}

/// Trạng thái một vị trí đã có cầu thủ, để C04 tô màu cảnh báo.
enum SlotStatus { ok, wrongPosition, notOwned }

//[ownedIds] = null nghĩa là chưa tải xong bộ sưu tập, chưa cảnh báo vội
SlotStatus slotStatusOf({
  required String playerId,
  required Player? player,
  required FormationSlot slot,
  required Set<String>? ownedIds,
}) {
  if (ownedIds != null && !ownedIds.contains(playerId)) {
    return SlotStatus.notOwned;
  }
  if (player == null || !canPlaySlot(player, slot)) {
    return SlotStatus.wrongPosition;
  }
  return SlotStatus.ok;
}

/// C04 — Đội hình đang sửa trên sân.
///
/// C02 (đổi sơ đồ) và C03 (chọn cầu thủ) cũng sửa vào đây.
/// Mọi thay đổi chỉ nằm trong bộ nhớ; bấm "Lưu" mới ghi vào repository.
@riverpod
class C04ViewModel extends _$C04ViewModel {
  // Bản đã lưu, để biết người dùng đã sửa gì chưa
  Lineup? _savedLineup;

  @override
  FutureOr<Lineup> build(String lineupId) async {
    final uid = ref.watch(currentUidProvider);
    final repository = ref.read(lineupRepositoryProvider);
    final lineup = await repository.getLineupById(uid, lineupId);
    if (lineup == null) {
      throw StateError('Không tìm thấy đội hình');
    }
    _savedLineup = lineup;
    return lineup;
  }

  //Có thay đổi chưa lưu không
  bool get hasUnsavedChanges {
    final current = state.value;
    return current != null && current != _savedLineup;
  }

  void _update(Lineup lineup) {
    state = AsyncData(lineup);
  }

  //C02: các vị trí sẽ mất cầu thủ nếu đổi sang sơ đồ [formationId]
  List<String> slotsRemovedBy(String formationId) {
    final lineup = state.value;
    if (lineup == null) return [];
    final newSlotIds = Formations.byId(formationId).slots.map((s) => s.id);
    return lineup.slots.keys.where((id) => !newSlotIds.contains(id)).toList();
  }

  //C02: đổi sơ đồ, giữ cầu thủ ở vị trí có cùng ID, bỏ cầu thủ ở vị trí không còn
  void changeFormation(String formationId) {
    final lineup = state.value;
    if (lineup == null) return;
    final removed = slotsRemovedBy(formationId);
    final slots = Map<String, String>.of(lineup.slots)
      ..removeWhere((slotId, _) => removed.contains(slotId));
    _update(lineup.copyWith(formationId: formationId, slots: slots));
  }

  //C03: xếp cầu thủ vào vị trí.
  //Một cầu thủ không được đứng hai vị trí: nếu đang ở vị trí khác thì chuyển sang.
  void setPlayer(String slotId, String playerId) {
    final lineup = state.value;
    if (lineup == null) return;
    final slots = Map<String, String>.of(lineup.slots)
      ..removeWhere((_, id) => id == playerId);
    slots[slotId] = playerId;
    _update(lineup.copyWith(slots: slots));
  }

  //C04: bỏ trống một vị trí
  void clearSlot(String slotId) {
    final lineup = state.value;
    if (lineup == null) return;
    final slots = Map<String, String>.of(lineup.slots)..remove(slotId);
    _update(lineup.copyWith(slots: slots));
  }

  //C04: bỏ thay đổi, quay về bản đã lưu
  void discardChanges() {
    final saved = _savedLineup;
    if (saved != null) _update(saved);
  }

  //C04: lưu vào repository
  Future<void> save() async {
    final lineup = state.value;
    if (lineup == null) return;
    final saved = lineup.copyWith(updatedAt: DateTime.now());
    await ref.read(lineupRepositoryProvider).saveLineup(saved);
    if (!ref.mounted) return;

    _savedLineup = saved;
    _update(saved);
    // Báo C01 tải lại danh sách
    ref.invalidate(c01ViewModelProvider);
  }
}
