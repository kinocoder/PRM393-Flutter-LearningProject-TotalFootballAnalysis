import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/player.dart';
import '../../../data/model/skill.dart';
import '../../../data/repositories/player_repository.dart';
import '../../../data/model/skill_comparison.dart';
import 'a01_view_model.dart';

part 'a03_view_model.g.dart';

/// Trạng thái dữ liệu so sánh kỹ thuật cho màn hình A03
class A03ComparisonState {
  /// Danh sách cầu thủ được chọn đúng thứ tự
  final List<Player> players;

  /// Kết quả so sánh kỹ thuật đã gom nhóm theo Kỹ thuật chung và Kỹ thuật riêng
  final SkillComparison skillComparison;

  const A03ComparisonState({
    required this.players,
    required this.skillComparison,
  });
}

/// ViewModel quản lý dữ liệu so sánh kỹ thuật đặc biệt cho màn hình A03
@riverpod
class A03ViewModel extends _$A03ViewModel {
  @override
  Future<A03ComparisonState> build() async {
    final selectedIds = ref.watch(compareSelectionProvider);
    final playerRepo = ref.watch(playerRepositoryProvider);

    if (selectedIds.isEmpty) {
      return const A03ComparisonState(
        players: [],
        skillComparison: SkillComparison(
          commonSkills: [],
          uniqueSkills: [],
          overallPlayerStatus: {},
        ),
      );
    }

    // Tải dữ liệu các cầu thủ được chọn
    final List<Player> loadedPlayers = [];
    for (final id in selectedIds) {
      final p = await playerRepo.getPlayerByID(id);
      if (p != null) {
        loadedPlayers.add(p);
      }
    }

    // Thực hiện so sánh kỹ thuật theo thuật toán SDS Mục 8
    final skillComparison = _compareSkills(loadedPlayers);

    return A03ComparisonState(
      players: loadedPlayers,
      skillComparison: skillComparison,
    );
  }

  /// Thuật toán cốt lõi gom nhóm và phân tích kỹ thuật đặc biệt (SDS Mục 8 & BR-03)
  SkillComparison _compareSkills(List<Player> players) {
    final Map<String, SkillDataStatus> overallStatus = {};
    final Map<String, Skill> allSkillsById = {};
    final Map<String, Set<String>> skillOwnedByMap = {}; // skillId -> Tập hợp playerId
    final Map<String, List<String>> nameToSkillIds = {}; // skillName -> Danh sách skillId

    // 1. Kiểm tra trạng thái dữ liệu kỹ thuật từng cầu thủ và lập chỉ mục theo skillId (BR-03)
    for (final player in players) {
      if (player.skills == null) {
        overallStatus[player.id] = SkillDataStatus.unknown; // Chưa có dữ liệu kỹ thuật (?)
      } else if (player.skills!.isEmpty) {
        overallStatus[player.id] = SkillDataStatus.notOwned; // Xác nhận không sở hữu kỹ thuật (—)
      } else {
        overallStatus[player.id] = SkillDataStatus.owned;
        for (final skill in player.skills!) {
          allSkillsById[skill.id] = skill;

          skillOwnedByMap.putIfAbsent(skill.id, () => <String>{}).add(player.id);

          nameToSkillIds.putIfAbsent(skill.name, () => <String>[]).add(skill.id);
        }
      }
    }

    // Danh sách cầu thủ đã có dữ liệu kỹ thuật (không phải dạng unknown)
    final playersWithSkillData = players
        .where((p) => overallStatus[p.id] != SkillDataStatus.unknown)
        .toList();

    final List<SkillComparisonItem> allComparisonItems = [];

    // 2. Tạo đối tượng thông tin so sánh cho từng kỹ thuật
    for (final entry in allSkillsById.entries) {
      final skillId = entry.key;
      final skill = entry.value;
      final ownedSet = skillOwnedByMap[skillId] ?? {};

      // Kiểm tra xem tên kỹ thuật có bị trùng lặp giữa các skillId khác nhau không (BR-03)
      final sameNameIds = nameToSkillIds[skill.name] ?? [];
      final hasDupName = sameNameIds.length > 1;

      final Map<String, SkillDataStatus> playerStatuses = {};
      for (final player in players) {
        final pOverall = overallStatus[player.id]!;
        if (pOverall == SkillDataStatus.unknown) {
          playerStatuses[player.id] = SkillDataStatus.unknown;
        } else if (ownedSet.contains(player.id)) {
          playerStatuses[player.id] = SkillDataStatus.owned;
        } else {
          playerStatuses[player.id] = SkillDataStatus.notOwned;
        }
      }

      allComparisonItems.add(
        SkillComparisonItem(
          skillId: skillId,
          skillName: skill.name,
          description: skill.description,
          type: skill.type,
          hasDuplicateName: hasDupName,
          ownedByPlayerIds: ownedSet,
          playerStatuses: playerStatuses,
        ),
      );
    }

    // 3. Gom nhóm thành Kỹ thuật chung vs Kỹ thuật riêng
    final List<SkillComparisonItem> common = [];
    final List<SkillComparisonItem> unique = [];

    for (final item in allComparisonItems) {
      // Kỹ thuật chung nếu TẤT CẢ cầu thủ có dữ liệu đều sở hữu
      bool isCommon = playersWithSkillData.isNotEmpty;
      for (final p in playersWithSkillData) {
        if (!item.ownedByPlayerIds.contains(p.id)) {
          isCommon = false;
          break;
        }
      }

      if (isCommon && playersWithSkillData.isNotEmpty) {
        common.add(item);
      } else {
        unique.add(item);
      }
    }

    return SkillComparison(
      commonSkills: common,
      uniqueSkills: unique,
      overallPlayerStatus: overallStatus,
    );
  }
}
