import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/formation.dart';
import 'lineup_draft_view_model.dart';

/// Trạng thái màn C02: sơ đồ đang chọn và kết quả xem trước khi đổi.
class C02State {
  const C02State({required this.draft, required this.selected});

  final LineupDraft draft;
  final Formation selected;

  bool get isChange => selected.id != draft.current.formationId;

  FormationChange get plan => planFormationChange(draft.current.slots, selected);

  /// Cần hộp xác nhận vì có cầu thủ sẽ bị gỡ.
  bool get needsConfirm => isChange && plan.removesPlayers;
}

/// C02 — chọn sơ đồ. Chỉ giữ lựa chọn tạm; "Áp dụng" mới sửa bản nháp.
class C02ViewModel extends AutoDisposeFamilyNotifier<String?, String> {
  @override
  String? build(String lineupId) => null; // null = đang dùng sơ đồ hiện tại

  void select(String formationId) => state = formationId;

  /// Ghi sơ đồ đã chọn vào bản nháp (gọi sau khi người dùng xác nhận).
  void apply() {
    final draft = ref.read(lineupDraftViewModelProvider(arg)).valueOrNull;
    if (draft == null) return;
    final target = Formations.byId(state ?? draft.current.formationId);
    if (target.id != draft.current.formationId) {
      ref.read(lineupDraftViewModelProvider(arg).notifier).applyFormation(target);
    }
  }
}

final c02ViewModelProvider =
    NotifierProvider.autoDispose.family<C02ViewModel, String?, String>(C02ViewModel.new);

/// Kết hợp bản nháp + lựa chọn thành state cho màn hình.
final c02StateProvider = Provider.autoDispose.family<AsyncValue<C02State>, String>((ref, lineupId) {
  final selectedId = ref.watch(c02ViewModelProvider(lineupId));
  return ref.watch(lineupDraftViewModelProvider(lineupId)).whenData(
        (draft) => C02State(
          draft: draft,
          selected: Formations.byId(selectedId ?? draft.current.formationId),
        ),
      );
});
