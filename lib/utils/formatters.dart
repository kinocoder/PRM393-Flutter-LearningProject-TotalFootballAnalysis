/// Định dạng ngày giờ đơn giản (không cần gói intl).
String formatDateTime(DateTime value) {
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} '
      '${two(local.hour)}:${two(local.minute)}';
}

/// Hiển thị số có thể thiếu: thiếu thì `N/A`, không bao giờ biến thành 0.
String formatStat(int? value) => value == null ? 'N/A' : '$value';

/// Hiển thị chênh lệch có dấu: +3, −2, 0. Thiếu dữ liệu thì `—`.
String formatDelta(int? delta) {
  if (delta == null) return '—';
  if (delta > 0) return '+$delta';
  if (delta < 0) return '−${delta.abs()}';
  return '0';
}
