/// Trạng thái dữ liệu kỹ thuật của một cầu thủ (BR-03)
enum SkillDataStatus {
  /// Sở hữu kỹ thuật này
  owned,

  /// Xác nhận không sở hữu kỹ thuật này (danh sách kỹ thuật là rỗng [])
  notOwned,

  /// Chưa có dữ liệu kỹ thuật (danh sách kỹ thuật là null / chưa biết)
  unknown,
}

/// Mô hình thông tin một kỹ thuật trong bảng so sánh A03
class SkillComparisonItem {
  /// Mã định danh kỹ thuật (skillId)
  final String skillId;

  /// Tên kỹ thuật
  final String skillName;

  /// Mô tả tác dụng kỹ thuật
  final String description;

  /// Phân loại kỹ thuật (Tấn công, Phòng ngự, Đặc biệt...)
  final String? type;

  /// Cờ đánh dấu nếu có 2 kỹ thuật trùng tên nhưng khác skillId (BR-03)
  final bool hasDuplicateName;

  /// Tập hợp các playerId sở hữu kỹ thuật này
  final Set<String> ownedByPlayerIds;

  /// Trạng thái của từng cầu thủ đối với kỹ thuật này (playerId -> SkillDataStatus)
  final Map<String, SkillDataStatus> playerStatuses;

  const SkillComparisonItem({
    required this.skillId,
    required this.skillName,
    required this.description,
    this.type,
    required this.hasDuplicateName,
    required this.ownedByPlayerIds,
    required this.playerStatuses,
  });
}

/// Đối tượng chứa toàn bộ kết quả so sánh kỹ thuật cho màn hình A03 (SDS Mục 8 & BR-03)
class SkillComparison {
  /// Danh sách kỹ thuật chung (tất cả cầu thủ đã có dữ liệu đều sở hữu)
  final List<SkillComparisonItem> commonSkills;

  /// Danh sách kỹ thuật riêng (chỉ một số cầu thủ sở hữu)
  final List<SkillComparisonItem> uniqueSkills;

  /// Trạng thái tổng quan dữ liệu kỹ thuật của từng cầu thủ (playerId -> SkillDataStatus)
  final Map<String, SkillDataStatus> overallPlayerStatus;

  const SkillComparison({
    required this.commonSkills,
    required this.uniqueSkills,
    required this.overallPlayerStatus,
  });
}
