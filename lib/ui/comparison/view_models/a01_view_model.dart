import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/player.dart';
import '../../../data/repositories/player_repository.dart';
import '../../../utils/text_normalize.dart';

part 'a01_view_model.g.dart';

/// Kết quả trả về khi thực hiện thêm thẻ cầu thủ vào danh sách so sánh
enum CompareAddResult {
  /// Thêm thành công
  added,

  /// Cầu thủ đã có trong danh sách (BR-01: Không trùng playerId)
  duplicate,

  /// Danh sách đã đầy (BR-01: Tối đa 3 cầu thủ)
  full,
}

/// Provider dùng chung lưu trữ danh sách các playerId được chọn so sánh (SDS 2.4 & 3.1)
/// Được dùng chung giữa các màn hình A01, B04, E03, E04.
@Riverpod(keepAlive: true)
class CompareSelection extends _$CompareSelection {
  @override
  List<String> build() => const [];

  /// Thêm một cầu thủ vào danh sách lựa chọn (BR-01: Tối đa 3 thẻ, không trùng)
  CompareAddResult add(String playerId) {
    if (state.contains(playerId)) {
      return CompareAddResult.duplicate;
    }
    if (state.length >= 3) {
      return CompareAddResult.full;
    }
    state = [...state, playerId];
    return CompareAddResult.added;
  }

  /// Bỏ chọn một cầu thủ theo playerId
  void remove(String playerId) {
    state = state.where((id) => id != playerId).toList();
  }

  /// Xóa sạch tất cả các cầu thủ đã chọn
  void clear() {
    state = const [];
  }

  /// Thay thế toàn bộ danh sách cầu thủ được chọn bằng danh sách mới
  void setSelection(List<String> ids) {
    if (ids.length <= 3) {
      state = List.from(ids);
    } else {
      state = ids.sublist(0, 3);
    }
  }

  /// Kiểm tra đủ điều kiện tiếp tục hay chưa (BR-01: Phải có ít nhất 2 cầu thủ)
  bool get canContinue => state.length >= 2;
}

/// Provider lưu trữ từ khóa tìm kiếm tại màn hình A01
@riverpod
class A01SearchQuery extends _$A01SearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

/// Provider truy vấn danh sách cầu thủ ứng viên theo từ khóa tìm kiếm (bỏ dấu)
@riverpod
Future<List<Player>> a01CandidatePlayers(Ref ref) async {
  final query = ref.watch(a01SearchQueryProvider);
  final playerRepo = ref.watch(playerRepositoryProvider);

  final allPlayers = await playerRepo.getPlayers();

  // Chuẩn hóa từ khóa tìm kiếm về dạng không dấu
  final normalizedQuery = normalizeForSearch(query);
  if (normalizedQuery.isEmpty) {
    return allPlayers;
  }

  // So sánh khớp từ khóa với tên, câu lạc bộ, quốc gia và vị trí
  return allPlayers.where((player) {
    final normName = normalizeForSearch(player.name);
    final normFullName = normalizeForSearch(player.fullName);
    final normClub = normalizeForSearch(player.club);
    final normNation = normalizeForSearch(player.nation);
    final normPos = normalizeForSearch(player.position);

    return normName.contains(normalizedQuery) ||
        normFullName.contains(normalizedQuery) ||
        normClub.contains(normalizedQuery) ||
        normNation.contains(normalizedQuery) ||
        normPos.contains(normalizedQuery);
  }).toList();
}
