import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/current_user_provider.dart';
import '../../../data/providers/lineup_repository_provider.dart';
import '../../../domain/models/formation.dart';
import '../../../domain/models/lineup.dart';
import '../../../utils/app_exception.dart';
import 'c01_view_model.dart';

/// Bản nháp đội hình đang sửa ở C02/C03/C04.
class LineupDraft {
  const LineupDraft({required this.saved, required this.current});

  /// Bản đã lưu trong SQLite.
  final Lineup saved;

  /// Bản đang sửa (chưa lưu).
  final Lineup current;

  bool get isDirty => !saved.hasSameContent(current);

  LineupDraft edit(Lineup next) => LineupDraft(saved: saved, current: next);
}

class LineupNotFoundException extends AppException {
  const LineupNotFoundException()
      : super('Không tìm thấy đội hình (có thể đã bị xoá).', code: 'lineup_not_found');
}

/// ViewModel bản nháp dùng chung cho C02, C03, C04 (khoá theo lineupId).
/// Mọi thao tác chỉ sửa bản nháp; chỉ [save] mới ghi xuống repository.
class LineupDraftViewModel extends FamilyAsyncNotifier<LineupDraft, String> {
  @override
  Future<LineupDraft> build(String lineupId) async {
    final uid = ref.watch(currentUidProvider);
    if (uid == null) throw const LineupNotFoundException();
    final lineup = await ref.read(lineupRepositoryProvider).get(uid, lineupId);
    if (lineup == null) throw const LineupNotFoundException();
    return LineupDraft(saved: lineup, current: lineup);
  }

  LineupDraft? get _draft => state.valueOrNull;

  void _edit(Lineup Function(Lineup current) change) {
    final d = _draft;
    if (d == null) return;
    state = AsyncData(d.edit(change(d.current)));
  }

  void rename(String name) => _edit((l) => l.copyWith(name: name.trim()));

  /// C02: xem trước kết quả đổi sơ đồ để cảnh báo.
  FormationChange? previewFormation(Formation target) {
    final d = _draft;
    return d == null ? null : planFormationChange(d.current.slots, target);
  }

  /// C02: áp dụng sơ đồ — giữ slot trùng ID, gỡ slot không còn.
  void applyFormation(Formation target) => _edit((l) {
        final plan = planFormationChange(l.slots, target);
        return l.copyWith(formationId: target.id, slots: plan.keptSlots);
      });

  /// C03: gán cầu thủ; nếu đang ở slot khác thì chuyển sang.
  void assign(String slotId, String playerId) =>
      _edit((l) => l.copyWith(slots: assignPlayer(l.slots, slotId, playerId)));

  void clearSlot(String slotId) => _edit((l) => l.copyWith(slots: Map.of(l.slots)..remove(slotId)));

  /// C04: gỡ các cầu thủ không còn trong bộ sưu tập.
  void removePlayers(Set<String> playerIds) => _edit(
        (l) => l.copyWith(slots: Map.of(l.slots)..removeWhere((_, pid) => playerIds.contains(pid))),
      );

  Future<void> save() async {
    final d = _draft;
    if (d == null) return;
    final toSave = d.current.copyWith(updatedAt: DateTime.now());
    await ref.read(lineupRepositoryProvider).save(toSave);
    state = AsyncData(LineupDraft(saved: toSave, current: toSave));
    ref.invalidate(c01ViewModelProvider);
  }

  void discard() {
    final d = _draft;
    if (d == null) return;
    state = AsyncData(LineupDraft(saved: d.saved, current: d.saved));
  }
}

final lineupDraftViewModelProvider =
    AsyncNotifierProvider.family<LineupDraftViewModel, LineupDraft, String>(LineupDraftViewModel.new);
