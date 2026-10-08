import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/current_user_provider.dart';
import '../../../data/providers/owned_player_repository_provider.dart';
import '../../../data/providers/player_repository_provider.dart';
import '../../../domain/models/formation.dart';
import '../../../domain/models/lineup.dart';
import '../../../domain/models/player.dart';
import '../../../utils/text_normalize.dart';
import 'lineup_draft_view_model.dart';

/// ID thẻ người dùng sở hữu (nguồn E01). Dùng ở C03 (ứng viên) và C04
/// (cảnh báo thẻ không còn sở hữu).
final ownedPlayerIdsProvider = FutureProvider<Set<String>>((ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return <String>{};
  return (await ref.watch(ownedPlayerRepositoryProvider).ownedPlayerIds(uid)).toSet();
});

/// Thẻ sở hữu kèm thông tin cầu thủ (cache → API → dữ liệu mẫu).
final ownedPlayersProvider = FutureProvider<List<Player>>((ref) async {
  final ids = await ref.watch(ownedPlayerIdsProvider.future);
  final players = await ref.watch(playerRepositoryProvider).getPlayersByIds(ids);
  return [for (final id in ids) if (players[id] != null) players[id]!];
});

typedef SlotArgs = ({String lineupId, String slotId});

/// Một ứng viên trong danh sách C03.
class SlotCandidate {
  const SlotCandidate({required this.player, required this.fits, required this.rating, this.currentSlot});

  final Player player;

  /// Chơi được vị trí của slot (không lệch vị trí).
  final bool fits;

  /// Điểm theo vị trí của slot (lấy từ positionRatings), null nếu không có.
  final int? rating;

  /// Slot cầu thủ đang đứng trong đội hình này (null nếu chưa xếp).
  final String? currentSlot;
}

/// Điểm tốt nhất của cầu thủ cho các vị trí slot chấp nhận.
int? ratingForSlot(Player p, FormationSlot slot) {
  int? best;
  for (final pos in slot.acceptedPositions) {
    final r = p.positionRatings[pos] ?? (p.position == pos ? p.ovr : null);
    if (r != null && (best == null || r > best)) best = r;
  }
  return best;
}

/// Lọc + sắp xếp ứng viên (hàm thuần để unit test).
/// Đúng vị trí trước, rồi theo điểm vị trí giảm dần, rồi theo tên.
List<SlotCandidate> buildCandidates({
  required List<Player> owned,
  required Lineup lineup,
  required FormationSlot slot,
  String query = '',
  bool onlyFitting = true,
}) {
  final slotOf = {for (final e in lineup.slots.entries) e.value: e.key};
  final list = <SlotCandidate>[
    for (final p in owned)
      if (matchesSearch('${p.name} ${p.fullName ?? ''}', query))
        SlotCandidate(
          player: p,
          fits: slot.acceptedPositions.any(p.canPlay),
          rating: ratingForSlot(p, slot),
          currentSlot: slotOf[p.id],
        ),
  ].where((c) => !onlyFitting || c.fits).toList();
  list.sort((a, b) {
    if (a.fits != b.fits) return a.fits ? -1 : 1;
    final r = (b.rating ?? -1).compareTo(a.rating ?? -1);
    return r != 0 ? r : a.player.name.compareTo(b.player.name);
  });
  return list;
}

/// Bộ lọc của C03.
class C03Filter {
  const C03Filter({this.query = '', this.onlyFitting = true});
  final String query;
  final bool onlyFitting;
}

/// Kết quả xử lý khi người dùng chọn một cầu thủ ở C03.
enum PickCheck {
  ok,

  /// Cầu thủ đang ở slot khác — cần hỏi "chuyển sang?".
  movesFromOtherSlot,

  /// Cầu thủ không chơi vị trí này — cần cảnh báo lệch vị trí.
  wrongPosition,
}

/// C03 — chọn cầu thủ cho một vị trí.
class C03ViewModel extends AutoDisposeFamilyNotifier<C03Filter, SlotArgs> {
  @override
  C03Filter build(SlotArgs args) => const C03Filter();

  void setQuery(String q) => state = C03Filter(query: q, onlyFitting: state.onlyFitting);

  void setOnlyFitting(bool v) => state = C03Filter(query: state.query, onlyFitting: v);

  /// Các kiểm tra cần xác nhận trước khi gán, theo thứ tự hỏi.
  List<PickCheck> checksFor(SlotCandidate c) => [
        if (c.currentSlot != null && c.currentSlot != arg.slotId) PickCheck.movesFromOtherSlot,
        if (!c.fits) PickCheck.wrongPosition,
      ];

  void assign(String playerId) =>
      ref.read(lineupDraftViewModelProvider(arg.lineupId).notifier).assign(arg.slotId, playerId);

  void clearSlot() => ref.read(lineupDraftViewModelProvider(arg.lineupId).notifier).clearSlot(arg.slotId);

  /// Bản debug khi mảng E chưa có E02: thêm vài thẻ mẫu vào bộ sưu tập.
  Future<void> seedSampleOwned() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final sample = await ref.read(playerRepositoryProvider).samplePlayers();
    await ref.read(ownedPlayerRepositoryProvider).addSampleOwned(uid, [for (final p in sample) p.id]);
    ref.invalidate(ownedPlayerIdsProvider);
  }
}

final c03ViewModelProvider =
    NotifierProvider.autoDispose.family<C03ViewModel, C03Filter, SlotArgs>(C03ViewModel.new);

/// Dữ liệu cho màn C03.
class C03State {
  const C03State({required this.lineup, required this.slot, required this.candidates, required this.ownedCount});

  final Lineup lineup;

  /// null nếu slot không có trong sơ đồ hiện tại.
  final FormationSlot? slot;
  final List<SlotCandidate> candidates;
  final int ownedCount;

  String? get assignedPlayerId => slot == null ? null : lineup.slots[slot!.id];
}

final c03StateProvider = Provider.autoDispose.family<AsyncValue<C03State>, SlotArgs>((ref, args) {
  final draft = ref.watch(lineupDraftViewModelProvider(args.lineupId));
  final owned = ref.watch(ownedPlayersProvider);
  final filter = ref.watch(c03ViewModelProvider(args));
  if (draft.hasError) return AsyncError(draft.error!, draft.stackTrace!);
  if (owned.hasError) return AsyncError(owned.error!, owned.stackTrace!);
  final d = draft.valueOrNull;
  final o = owned.valueOrNull;
  if (d == null || o == null) return const AsyncLoading();
  final slot = d.current.formation.slot(args.slotId);
  return AsyncData(C03State(
    lineup: d.current,
    slot: slot,
    ownedCount: o.length,
    candidates: slot == null
        ? const []
        : buildCandidates(
            owned: o,
            lineup: d.current,
            slot: slot,
            query: filter.query,
            onlyFitting: filter.onlyFitting,
          ),
  ));
});
