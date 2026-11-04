/// Một cầu thủ được người dùng thêm vào bộ sưu tập cá nhân.
///
/// Model này chỉ lưu dữ liệu riêng của phần E. Thông tin đầy đủ của cầu thủ
/// (tên, CLB, chỉ số...) luôn được lấy từ PlayerRepository.
class CollectionEntry {
  const CollectionEntry({
    required this.playerId,
    required this.addedAt,
    this.note = '',
  });

  final String playerId;
  final DateTime addedAt;
  final String note;
}
