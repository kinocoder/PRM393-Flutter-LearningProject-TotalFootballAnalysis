/// Model dữ liệu đại diện cho một bản ghi kết quả so sánh được lưu vào lịch sử (BR-10).
class ComparisonRecord {
  /// Mã định danh duy nhất của bản ghi lịch sử
  final String id;

  /// Mã người dùng sở hữu bản ghi (BR-05)
  final String uid;

  /// Thời điểm lưu kết quả so sánh
  final DateTime createdAt;

  /// Phiên bản dữ liệu catalog tại thời điểm lưu (ví dụ: "2026.09-sample.1")
  final String dataVersion;

  /// Mã vị trí tiêu chí đánh giá (ST, WING, CAM, CM, CDM, FULLBACK, CB)
  final String roleCode;

  /// Danh sách các playerId được so sánh
  final List<String> playerIds;

  /// Trọng số sử dụng khi đánh giá (PAC, SHO, PAS, DRI, DEF, PHY)
  final Map<String, int> weights;

  /// Điểm đánh giá tính toán được của từng cầu thủ (playerId -> điểm)
  final Map<String, double> scores;

  /// Thứ hạng của từng cầu thủ (playerId -> hạng, null nếu không xếp hạng do thiếu dữ liệu)
  final Map<String, int?> ranks;

  /// Snapshot thông tin các thẻ cầu thủ dạng JSON để phục vụ xem offline tại E04
  final List<Map<String, dynamic>> entries;

  const ComparisonRecord({
    required this.id,
    required this.uid,
    required this.createdAt,
    required this.dataVersion,
    required this.roleCode,
    required this.playerIds,
    required this.weights,
    required this.scores,
    required this.ranks,
    required this.entries,
  });

  /// Khởi tạo đối tượng từ dữ liệu JSON
  factory ComparisonRecord.fromJson(Map<String, dynamic> json) {
    return ComparisonRecord(
      id: json['id'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      dataVersion: json['dataVersion'] as String? ?? '2026.09-sample.1',
      roleCode: json['roleCode'] as String? ?? 'ST',
      playerIds: (json['playerIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      weights: (json['weights'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ) ??
          {},
      scores: (json['scores'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      ranks: (json['ranks'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v != null ? (v as num).toInt() : null),
          ) ??
          {},
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }

  /// Chuyển đối tượng thành định dạng JSON để lưu trữ SQLite hoặc Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'createdAt': createdAt.toIso8601String(),
      'dataVersion': dataVersion,
      'roleCode': roleCode,
      'playerIds': playerIds,
      'weights': weights,
      'scores': scores,
      'ranks': ranks,
      'entries': entries,
    };
  }
}
