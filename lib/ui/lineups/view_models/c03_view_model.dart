import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/player.dart';
import '../../../data/repositories/collection_repository.dart';
import '../../../data/repositories/current_user_provider.dart';
import '../../../data/repositories/player_repository.dart';
import '../../../utils/text_normalize.dart';
part 'c03_view_model.g.dart';

//Cầu thủ có chơi được vị trí này không (vị trí chính hoặc vị trí phụ)
bool canPlayRole(Player player, String role) {
  return player.position == role || player.positionRatings.containsKey(role);
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

  //Tìm theo tên; nếu bật onlyMatching thì chỉ giữ người đúng vị trí
  List<Player> filterPlayers(
    List<Player> players, {
    required String keyword,
    required String role,
    required bool onlyMatching,
  }) {
    final text = normalizeForSearch(keyword);
    return players.where((player) {
      final name = normalizeForSearch('${player.name} ${player.fullName}');
      if (!name.contains(text)) return false;
      if (onlyMatching && !canPlayRole(player, role)) return false;
      return true;
    }).toList();
  }
}
