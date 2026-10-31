import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/model/comparison_record.dart';

part 'comparison_history_repository.g.dart';

/// Provider cấp phát đối tượng ComparisonHistoryRepository cho toàn ứng dụng
/// keepAlive để lịch sử vẫn còn khi người dùng rời A04 và mở E04.
@Riverpod(keepAlive: true)
ComparisonHistoryRepository comparisonHistoryRepository(Ref ref) {
  return ComparisonHistoryRepository();
}

/// Repository quản lý dữ liệu lịch sử so sánh theo UID người dùng (BR-05, BR-10)
class ComparisonHistoryRepository {
  /// Bộ lưu trữ tạm trong bộ nhớ
  final List<ComparisonRecord> _inMemoryRecords = [];

  /// Lưu một bản ghi kết quả so sánh vào lịch sử
  Future<void> saveRecord(ComparisonRecord record) async {
    // Xóa bản ghi cũ nếu trùng ID
    _inMemoryRecords.removeWhere((r) => r.id == record.id);
    _inMemoryRecords.add(record);
  }

  /// Truy vấn danh sách lịch sử so sánh thuộc sở hữu của người dùng `uid`, sắp xếp mới nhất lên đầu
  Future<List<ComparisonRecord>> getHistoryByUid(String uid) async {
    final userRecords = _inMemoryRecords.where((r) => r.uid == uid).toList();
    userRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<ComparisonRecord>.unmodifiable(userRecords);
  }

  /// Lấy thông tin bản ghi lịch sử so sánh theo id
  Future<ComparisonRecord?> getRecordById(String id) async {
    try {
      return _inMemoryRecords.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Xóa bản ghi lịch sử so sánh theo id (BR-12)
  Future<void> deleteRecord(String id) async {
    _inMemoryRecords.removeWhere((r) => r.id == id);
  }
}
