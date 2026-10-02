import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/player_repository_provider.dart';
import '../../../domain/models/lineup.dart';
import '../../../domain/models/player.dart';
import 'c03_view_model.dart';
import 'lineup_draft_view_model.dart';

/// Cảnh báo trên sân C04 (hàm thuần để unit test).
class PitchWarnings {
  const PitchWarnings({required this.mismatchedSlots, required this.unownedPlayerIds});

  /// Slot có cầu thủ không chơi được vị trí đó (tô vàng).
  final List<String> mismatchedSlots;

  /// Cầu thủ trong đội hình nhưng không còn trong bộ sưu tập (tô đỏ).
  final Set<String> unownedPlayerIds;
}

PitchWarnings computeWarnings(Lineup lineup, Map<String, Player> players, Set<String>? ownedIds) {
  final formation = lineup.formation;
  final mismatched = <String>[
    for (final e in lineup.slots.entries)
      if (players[e.value] != null &&
          formation.slot(e.key) != null &&
          !formation.slot(e.key)!.acceptedPositions.any(players[e.value]!.canPlay))
        e.key,
  ];
  final unowned = ownedIds == null
      ? <String>{}
      : lineup.slots.values.where((id) => !ownedIds.contains(id)).toSet();
  return PitchWarnings(mismatchedSlots: mismatched, unownedPlayerIds: unowned);
}

/// Thông tin cầu thủ của các slot. Khoá family: các ID đã sắp xếp, nối "," .
final slotPlayersProvider = FutureProvider.autoDispose.family<Map<String, Player>, String>((ref, joinedIds) {
  final ids = joinedIds.isEmpty ? const <String>[] : joinedIds.split(',');
  return ref.watch(playerRepositoryProvider).getPlayersByIds(ids);
});

String joinPlayerIds(Iterable<String> ids) => (ids.toSet().toList()..sort()).join(',');

/// Dữ liệu màn C04.
class C04State {
  const C04State({required this.draft, required this.players, required this.warnings});

  final LineupDraft draft;
  final Map<String, Player> players;
  final PitchWarnings warnings;
}

final c04StateProvider = Provider.autoDispose.family<AsyncValue<C04State>, String>((ref, lineupId) {
  return ref.watch(lineupDraftViewModelProvider(lineupId)).whenData((draft) {
    final lineup = draft.current;
    final players = ref.watch(slotPlayersProvider(joinPlayerIds(lineup.slots.values))).valueOrNull ?? const {};
    final owned = ref.watch(ownedPlayerIdsProvider).valueOrNull;
    return C04State(draft: draft, players: players, warnings: computeWarnings(lineup, players, owned));
  });
});
