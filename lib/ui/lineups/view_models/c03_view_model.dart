import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/formation.dart';
import '../../../data/model/player.dart';
import '../../../data/repositories/collection_repository.dart';
import '../../../data/repositories/current_user_provider.dart';
import '../../../data/repositories/player_repository.dart';
import '../../../utils/text_normalize.dart';
part 'c03_view_model.g.dart';

//Cầu thủ có chơi được vị trí này không (tính cả vị trí tương đương)
bool canPlaySlot(Player player, FormationSlot slot) {
  return slot.acceptedRoles.any(
    (role) => player.position == role || player.positionRatings.containsKey(role),
  );
}

//Điểm cao nhất của cầu thủ trong các vị trí mà slot chấp nhận; không đá được thì 0
int ratingForSlot(Player player, FormationSlot slot) {
  var best = 0;
  for (final role in slot.acceptedRoles) {
    final rating =
        player.positionRatings[role] ?? (player.position == role ? player.ovr : 0);
    if (rating > best) best = rating;
  }
  return best;
}

//Thứ tự ứng viên: đúng vị trí trước → điểm vị trí cao hơn → tên A-Z
int compareCandidates(Player a, Player b, FormationSlot slot) {
  final aFits = canPlaySlot(a, slot);
  final bFits = canPlaySlot(b, slot);
  if (aFits != bFits) return aFits ? -1 : 1;

  final byRating = ratingForSlot(b, slot).compareTo(ratingForSlot(a, slot));
  if (byRating != 0) return byRating;

  return normalizeForSearch(a.name).compareTo(normalizeForSearch(b.name));
}

/// C03 — Chọn cầu thủ cho một vị trí.
///
/// Ứng viên là cầu thủ người dùng sở hữu: lấy ID từ bộ sưu tập của mảng E,
/// rồi lấy thông tin từ PlayerRepository của mảng B.
@riverpod
class C03ViewModel extends _$C03ViewModel {
  @override
  FutureOr<List<Player>> build() async {
    final uid = ref.watch(currentUidProvider);
    final collectionRepository = ref.read(collectionRepositoryProvider);
    final playerRepository = ref.read(playerRepositoryProvider);

    final entries = await collectionRepository.getCollection(uid);
    final ownedIds = {for (final entry in entries) entry.playerId};
    final players = await playerRepository.getPlayers();
    return players.where((player) => ownedIds.contains(player.id)).toList();
  }

  //Tìm theo tên; nếu bật onlyMatching thì chỉ giữ người đúng vị trí; rồi sắp xếp
  List<Player> filterPlayers(
    List<Player> players, {
    required String keyword,
    required FormationSlot slot,
    required bool onlyMatching,
  }) {
    final text = normalizeForSearch(keyword);
    final result = players.where((player) {
      final name = normalizeForSearch('${player.name} ${player.fullName}');
      if (!name.contains(text)) return false;
      if (onlyMatching && !canPlaySlot(player, slot)) return false;
      return true;
    }).toList();
    result.sort((a, b) => compareCandidates(a, b, slot));
    return result;
  }
}
