/// Lớp tiện ích sinh định danh duy nhất (Unique ID) cho các đối tượng trong ứng dụng.
class IdGenerator {
  /// Sinh chuỗi định danh duy nhất dựa trên mốc thời gian (timestamp) và tiền tố tùy chọn.
  static String generate([String prefix = 'id']) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp';
  }
}
