import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/player.dart';
import '../../../data/repositories/player_repository.dart';
import '../../../data/model/stat_row.dart';
import 'a01_view_model.dart';

part 'a02_view_model.g.dart';

/// Trạng thái dữ liệu cho màn hình A02 bao gồm danh sách cầu thủ đúng thứ tự chọn và các dòng chỉ số
class StatComparisonState {
  /// Danh sách thông tin cầu thủ được tải đúng thứ tự chọn từ A01
  final List<Player> players;

  /// Danh sách các dòng chỉ số (PAC, SHO, PAS, DRI, DEF, PHY...) đã tính toán chênh lệch Δ
  final List<StatRow> statRows;

  const StatComparisonState({
    required this.players,
    required this.statRows,
  });
}

/// ViewModel quản lý dữ liệu so sánh chỉ số cho màn hình A02
@riverpod
class A02ViewModel extends _$A02ViewModel {
  @override
  Future<StatComparisonState> build() async {
    // Đọc danh sách các playerId được chọn từ compareSelectionProvider
    final selectedIds = ref.watch(compareSelectionProvider);
    final playerRepo = ref.watch(playerRepositoryProvider);

    if (selectedIds.isEmpty) {
      return const StatComparisonState(players: [], statRows: []);
    }

    // Tải thông tin các cầu thủ và giữ nguyên thứ tự lựa chọn từ A01
    final List<Player> loadedPlayers = [];
    for (final id in selectedIds) {
      final p = await playerRepo.getPlayerByID(id);
      if (p != null) {
        loadedPlayers.add(p);
      }
    }

    if (loadedPlayers.isEmpty) {
      return const StatComparisonState(players: [], statRows: []);
    }

    // Kiểm tra xem có cầu thủ nào có chỉ số mở rộng "ATK" hay không
    bool hasAtk = false;
    for (final p in loadedPlayers) {
      if (p.stats.containsKey('ATK') && p.stats['ATK'] != null) {
        hasAtk = true;
        break;
      }
    }

    // Danh sách 6 chỉ số chính (+ ATK nếu có)
    final statKeys = ['PAC', 'SHO', 'PAS', 'DRI', 'DEF', 'PHY'];
    if (hasAtk) {
      statKeys.add('ATK');
    }

    final playerStatsList = loadedPlayers.map((p) => p.stats).toList();
    final playerIds = loadedPlayers.map((p) => p.id).toList();

    // Tính toán các dòng chỉ số và chênh lệch Δᵢ = vᵢ - max(vⱼ, j ≠ i) theo SDS Mục 8
    final statRows = StatRow.computeStatRows(
      statKeys: statKeys,
      playerStatsList: playerStatsList,
      playerIds: playerIds,
    );

    return StatComparisonState(
      players: loadedPlayers,
      statRows: statRows,
    );
  }

  /// Làm mới dữ liệu bảng so sánh chỉ số
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
