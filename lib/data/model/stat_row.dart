/// Model dữ liệu đại diện cho một dòng chỉ số trong bảng so sánh chỉ số tại màn hình A02.
class StatRow {
  /// Mã chỉ số (ví dụ: "PAC", "SHO", "PAS", "DRI", "DEF", "PHY", "ATK")
  final String statKey;

  /// Tên hiển thị chỉ số tiếng Việt (ví dụ: "Tốc độ (PAC)")
  final String statName;

  /// Dữ liệu chỉ số của từng cầu thủ (playerId -> giá trị chỉ số, null nếu không có dữ liệu N/A)
  final Map<String, int?> playerValues;

  /// Giá trị chênh lệch Δᵢ = vᵢ - max(vⱼ, j ≠ i) của từng cầu thủ (null nếu không so sánh được)
  final Map<String, int?> deltas;

  /// Danh sách các playerId sở hữu giá trị chỉ số cao nhất trong dòng này (để tô màu làm nổi bật)
  final List<String> bestPlayerIds;

  const StatRow({
    required this.statKey,
    required this.statName,
    required this.playerValues,
    required this.deltas,
    required this.bestPlayerIds,
  });

  /// Bảng ánh xạ từ mã chỉ số sang tên tiếng Việt hiển thị trên giao diện
  static const Map<String, String> statNameMap = {
    'PAC': 'Tốc độ (PAC)',
    'SHO': 'Sút (SHO)',
    'PAS': 'Chuyền (PAS)',
    'DRI': 'Rê bóng (DRI)',
    'DEF': 'Phòng thủ (DEF)',
    'PHY': 'Thể lực (PHY)',
    'ATK': 'Tấn công (ATK)',
  };

  /// Tính toán danh sách các dòng chỉ số và độ chênh lệch Δ theo SDS Mục 8 (computeDeltas) & BR-02
  static List<StatRow> computeStatRows({
    required List<String> statKeys,
    required List<Map<String, int?>> playerStatsList,
    required List<String> playerIds,
  }) {
    final List<StatRow> result = [];

    for (final key in statKeys) {
      final Map<String, int?> playerValues = {};
      final Map<String, int?> deltas = {};

      // 1. Trích xuất giá trị chỉ số của từng cầu thủ
      for (int i = 0; i < playerIds.length; i++) {
        final id = playerIds[i];
        final stats = i < playerStatsList.length ? playerStatsList[i] : <String, int?>{};
        playerValues[id] = stats[key];
      }

      // 2. Tìm giá trị cao nhất và danh sách các cầu thủ dẫn đầu
      int? maxVal;
      for (final val in playerValues.values) {
        if (val != null) {
          if (maxVal == null || val > maxVal) {
            maxVal = val;
          }
        }
      }

      final List<String> bestIds = [];
      if (maxVal != null) {
        for (final entry in playerValues.entries) {
          if (entry.value == maxVal) {
            bestIds.add(entry.key);
          }
        }
      }

      // 3. Tính độ chênh lệch Δᵢ = vᵢ - max(vⱼ, j ≠ i) cho từng cầu thủ
      for (final id in playerIds) {
        final val = playerValues[id];
        if (val == null) {
          // Thiếu chỉ số -> delta hiển thị dạng "—" (BR-02)
          deltas[id] = null;
        } else {
          // Tìm giá trị cao nhất trong số các cầu thủ còn lại
          int? otherMax;
          for (final otherEntry in playerValues.entries) {
            if (otherEntry.key != id && otherEntry.value != null) {
              if (otherMax == null || otherEntry.value! > otherMax) {
                otherMax = otherEntry.value;
              }
            }
          }

          if (otherMax == null) {
            deltas[id] = null; // Không có cầu thủ nào khác có chỉ số để so sánh
          } else {
            deltas[id] = val - otherMax;
          }
        }
      }

      result.add(
        StatRow(
          statKey: key,
          statName: statNameMap[key] ?? key,
          playerValues: playerValues,
          deltas: deltas,
          bestPlayerIds: bestIds,
        ),
      );
    }

    return result;
  }
}
