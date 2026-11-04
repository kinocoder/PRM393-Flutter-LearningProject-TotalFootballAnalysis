/// Quản lý cấu hình tiêu chí đánh giá vị trí và trọng số theo SDS 3.1 & SRS 2.2.2 & BR-04
class ScoringConfig {
  /// Mã vị trí thi đấu tiêu chí (ST, WING, CAM, CM, CDM, FULLBACK, CB)
  final String positionCode;

  /// Bản đồ trọng số tương ứng của 6 chỉ số: PAC, SHO, PAS, DRI, DEF, PHY (đơn vị %)
  final Map<String, int> weights;

  const ScoringConfig({
    required this.positionCode,
    required this.weights,
  });

  /// Bảng tên hiển thị tiếng Việt của các vị trí tiêu chí
  static const Map<String, String> positionDisplayNames = {
    'ST': 'Tiền đạo cắm (ST)',
    'WING': 'Tiền đạo cánh (LW/RW)',
    'CAM': 'Tiền vệ tấn công (CAM)',
    'CM': 'Tiền vệ trung tâm (CM)',
    'CDM': 'Tiền vệ phòng ngự (CDM)',
    'FULLBACK': 'Hậu vệ biên (LB/RB)',
    'CB': 'Trung vệ (CB)',
  };

  /// Trọng số mặc định theo vị trí quy định trong SRS 2.2.2:
  /// ST: 20/35/10/20/0/15
  /// Cánh (LW/RW): 30/20/20/25/0/5
  /// CAM: 10/25/30/30/0/5
  /// CM: 5/10/35/20/15/15
  /// CDM: 5/0/25/10/35/25
  /// Hậu vệ biên (LB/RB): 30/0/15/5/35/15
  /// CB: 15/0/10/0/45/30
  static const Map<String, Map<String, int>> positionDefaultWeights = {
    'ST': {'PAC': 20, 'SHO': 35, 'PAS': 10, 'DRI': 20, 'DEF': 0, 'PHY': 15},
    'WING': {'PAC': 30, 'SHO': 20, 'PAS': 20, 'DRI': 25, 'DEF': 0, 'PHY': 5},
    'CAM': {'PAC': 10, 'SHO': 25, 'PAS': 30, 'DRI': 30, 'DEF': 0, 'PHY': 5},
    'CM': {'PAC': 5, 'SHO': 10, 'PAS': 35, 'DRI': 20, 'DEF': 15, 'PHY': 15},
    'CDM': {'PAC': 5, 'SHO': 0, 'PAS': 25, 'DRI': 10, 'DEF': 35, 'PHY': 25},
    'FULLBACK': {'PAC': 30, 'SHO': 0, 'PAS': 15, 'DRI': 5, 'DEF': 35, 'PHY': 15},
    'CB': {'PAC': 15, 'SHO': 0, 'PAS': 10, 'DRI': 0, 'DEF': 45, 'PHY': 30},
  };

  /// Tạo cấu hình mặc định từ mã vị trí
  static ScoringConfig fromPosition(String positionCode) {
    final defaults = positionDefaultWeights[positionCode] ?? positionDefaultWeights['ST']!;
    return ScoringConfig(
      positionCode: positionCode,
      weights: Map<String, int>.from(defaults),
    );
  }

  /// Tính tổng trọng số hiện tại của 6 chỉ số
  int get totalWeight {
    int sum = 0;
    for (final w in weights.values) {
      sum += w;
    }
    return sum;
  }

  /// Kiểm tra tính hợp lệ: Tổng trọng số phải bằng 100% mới đủ điều kiện tính điểm (MSG-07)
  bool get isValid => totalWeight == 100;

  /// Chuẩn hóa trọng số về tổng đúng 100% theo phương pháp phần dư lớn nhất (SRS 2.2.2 & SDS Section 8)
  ScoringConfig normalizeTo100() {
    final currentTotal = totalWeight;
    if (currentTotal == 0 || currentTotal == 100) return this;

    final statKeys = ['PAC', 'SHO', 'PAS', 'DRI', 'DEF', 'PHY'];
    final Map<String, double> exactWeights = {};
    final Map<String, int> floorWeights = {};
    final Map<String, double> remainders = {};

    int floorSum = 0;
    for (final key in statKeys) {
      final currentW = weights[key] ?? 0;
      final exact = (currentW / currentTotal) * 100.0;
      final floorVal = exact.floor();
      exactWeights[key] = exact;
      floorWeights[key] = floorVal;
      remainders[key] = exact - floorVal;
      floorSum += floorVal;
    }

    int remainingToDistribute = 100 - floorSum;

    // Sắp xếp các chỉ số theo phần dư giảm dần
    final sortedKeys = List<String>.from(statKeys)
      ..sort((a, b) => remainders[b]!.compareTo(remainders[a]!));

    final Map<String, int> newWeights = Map<String, int>.from(floorWeights);
    for (int i = 0; i < remainingToDistribute; i++) {
      final key = sortedKeys[i % sortedKeys.length];
      newWeights[key] = (newWeights[key] ?? 0) + 1;
    }

    return ScoringConfig(
      positionCode: positionCode,
      weights: newWeights,
    );
  }
}

/// Kết quả điểm đánh giá của một cầu thủ tại màn hình A04
class PlayerScoreResult {
  /// Mã cầu thủ
  final String playerId;

  /// Tên cầu thủ
  final String playerName;

  /// Điểm số dạng số nguyên nhân 100 (ví dụ: 9275 cho 92.75) theo chuẩn thiết kế
  final int? integerScore;

  /// Điểm số đã quy đổi hiển thị (ví dụ: 92.75)
  final double? score;

  /// Thứ hạng của cầu thủ (1, 1, 3...). Null nếu không được xếp hạng
  final int? rank;

  /// Cờ đánh dấu cầu thủ không được xếp hạng do thiếu chỉ số bắt buộc (BR-04)
  final bool isUnranked;

  /// Lý do không xếp hạng (ví dụ: "Thiếu chỉ số DEF")
  final String? unrankedReason;

  const PlayerScoreResult({
    required this.playerId,
    required this.playerName,
    this.integerScore,
    this.score,
    this.rank,
    required this.isUnranked,
    this.unrankedReason,
  });
}
