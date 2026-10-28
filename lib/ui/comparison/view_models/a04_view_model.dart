import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/player.dart';
import '../../../data/repositories/current_user_provider.dart';
import '../../../data/repositories/comparison_history_repository.dart';
import '../../../data/repositories/player_repository.dart';
import '../../../data/model/comparison_record.dart';
import '../../../data/model/scoring_config.dart';
import '../../../utils/validators/id_generator.dart';
import 'a01_view_model.dart';

part 'a04_view_model.g.dart';

/// Provider quản lý cấu hình tiêu chí đánh giá cho màn hình A04
@riverpod
class A04Config extends _$A04Config {
  @override
  ScoringConfig build() {
    // Mặc định nạp vị trí ST khi khởi tạo
    return ScoringConfig.fromPosition('ST');
  }

  /// Thay đổi vị trí tiêu chí đánh giá và nạp bộ trọng số mặc định tương ứng
  void setPosition(String positionCode) {
    state = ScoringConfig.fromPosition(positionCode);
  }

  /// Cập nhật trọng số của một chỉ số (tăng/giảm theo bước 5%)
  void updateWeight(String statKey, int delta) {
    final current = state.weights[statKey] ?? 0;
    final newValue = (current + delta).clamp(0, 100);

    final newWeights = Map<String, int>.from(state.weights);
    newWeights[statKey] = newValue;

    state = ScoringConfig(
      positionCode: state.positionCode,
      weights: newWeights,
    );
  }

  /// Đặt giá trị trọng số chính xác cho một chỉ số (0 - 100%)
  void setExactWeight(String statKey, int value) {
    final newValue = value.clamp(0, 100);
    final newWeights = Map<String, int>.from(state.weights);
    newWeights[statKey] = newValue;

    state = ScoringConfig(
      positionCode: state.positionCode,
      weights: newWeights,
    );
  }

  /// Đặt lại toàn bộ trọng số về giá trị mặc định của vị trí hiện tại
  void resetToDefaults() {
    state = ScoringConfig.fromPosition(state.positionCode);
  }

  /// Chuẩn hóa tổng trọng số về đúng 100% bằng phương pháp phần dư lớn nhất
  void normalizeWeights() {
    state = state.normalizeTo100();
  }
}

/// Provider tính toán điểm đánh giá và xếp hạng cầu thủ theo cấu hình trọng số A04
@riverpod
Future<List<PlayerScoreResult>> a04ScoreResults(Ref ref) async {
  final config = ref.watch(a04ConfigProvider);
  final selectedIds = ref.watch(compareSelectionProvider);
  final playerRepo = ref.watch(playerRepositoryProvider);

  // Nếu tổng trọng số khác 100% hoặc chưa chọn cầu thủ -> Không tính điểm
  if (!config.isValid || selectedIds.isEmpty) {
    return const [];
  }

  // Tải thông tin các cầu thủ đúng thứ tự lựa chọn
  final List<Player> loadedPlayers = [];
  for (final id in selectedIds) {
    final p = await playerRepo.getPlayerByID(id);
    if (p != null) {
      loadedPlayers.add(p);
    }
  }

  final List<PlayerScoreResult> results = [];
  final statKeys = ['PAC', 'SHO', 'PAS', 'DRI', 'DEF', 'PHY'];

  // 1. Tính tổng điểm cho từng cầu thủ theo công thức: Điểm = Σ(wₖ × vₖ) / 100
  for (final player in loadedPlayers) {
    bool hasMissingRequiredStat = false;
    String? missingStatName;

    int sumWeighted = 0;
    for (final key in statKeys) {
      final w = config.weights[key] ?? 0;
      if (w > 0) {
        final val = player.stats[key];
        if (val == null) {
          hasMissingRequiredStat = true;
          missingStatName = key;
          break;
        } else {
          sumWeighted += w * val;
        }
      }
    }

    if (hasMissingRequiredStat) {
      // BR-04: Thẻ thiếu chỉ số có trọng số > 0 thì không được xếp hạng
      results.add(
        PlayerScoreResult(
          playerId: player.id,
          playerName: player.name,
          isUnranked: true,
          unrankedReason: 'Thiếu chỉ số $missingStatName',
        ),
      );
    } else {
      // Tính điểm quy đổi dạng số thực (vd: 92.75)
      final scoreVal = sumWeighted / 100.0;
      results.add(
        PlayerScoreResult(
          playerId: player.id,
          playerName: player.name,
          integerScore: sumWeighted,
          score: scoreVal,
          isUnranked: false,
        ),
      );
    }
  }

  // 2. Tính toán thứ hạng cho các cầu thủ có đủ chỉ số
  final rankedList = results.where((r) => !r.isUnranked).toList()
    ..sort((a, b) => b.integerScore!.compareTo(a.integerScore!));

  final Map<String, int> rankMap = {};
  int currentRank = 1;
  for (int i = 0; i < rankedList.length; i++) {
    if (i > 0 && rankedList[i].integerScore == rankedList[i - 1].integerScore) {
      // Các thẻ bằng điểm nhau nhận cùng thứ hạng (1, 1, 3)
      rankMap[rankedList[i].playerId] = rankMap[rankedList[i - 1].playerId]!;
    } else {
      currentRank = i + 1;
      rankMap[rankedList[i].playerId] = currentRank;
    }
  }

  // 3. Tổng hợp danh sách kết quả cuối cùng: Xếp hạng lên đầu, Không xếp hạng nằm cuối
  final List<PlayerScoreResult> finalResults = [];
  for (final r in results) {
    if (!r.isUnranked) {
      finalResults.add(
        PlayerScoreResult(
          playerId: r.playerId,
          playerName: r.playerName,
          integerScore: r.integerScore,
          score: r.score,
          rank: rankMap[r.playerId],
          isUnranked: false,
        ),
      );
    }
  }

  // Sắp xếp nhóm được xếp hạng theo hạng tăng dần (1, 2, 3...)
  finalResults.sort((a, b) => a.rank!.compareTo(b.rank!));

  // Đưa danh sách không xếp hạng xuống cuối
  final unrankedList = results.where((r) => r.isUnranked).toList();
  finalResults.addAll(unrankedList);

  return finalResults;
}

/// Provider thực hiện thao tác lưu kết quả so sánh vào lịch sử (BR-05, BR-10)
@riverpod
Future<void> Function() saveComparisonResult(Ref ref) {
  return () async {
    final config = ref.read(a04ConfigProvider);
    final selectedIds = ref.read(compareSelectionProvider);
    final currentUid = ref.read(currentUidProvider);
    final historyRepo = ref.read(comparisonHistoryRepositoryProvider);
    final playerRepo = ref.read(playerRepositoryProvider);

    if (!config.isValid || selectedIds.isEmpty) {
      throw Exception('Tổng trọng số phải bằng 100% mới có thể lưu');
    }

    final scoreResults = await ref.read(a04ScoreResultsProvider.future);

    // Lưu snapshot thông tin cầu thủ tại thời điểm so sánh
    final List<Map<String, dynamic>> entries = [];
    for (final id in selectedIds) {
      final p = await playerRepo.getPlayerByID(id);
      if (p != null) {
        entries.add(p.toJson());
      }
    }

    final Map<String, double> scoresMap = {};
    final Map<String, int?> ranksMap = {};

    for (final res in scoreResults) {
      if (!res.isUnranked && res.score != null) {
        scoresMap[res.playerId] = res.score!;
        ranksMap[res.playerId] = res.rank;
      } else {
        scoresMap[res.playerId] = 0.0;
        ranksMap[res.playerId] = null;
      }
    }

    final record = ComparisonRecord(
      id: IdGenerator.generate('comp'),
      uid: currentUid,
      createdAt: DateTime.now(),
      dataVersion: '2026.09-sample.1',
      roleCode: config.positionCode,
      playerIds: selectedIds,
      weights: config.weights,
      scores: scoresMap,
      ranks: ranksMap,
      entries: entries,
    );

    await historyRepo.saveRecord(record);
  };
}
