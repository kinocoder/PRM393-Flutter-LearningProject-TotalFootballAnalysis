/// Route tập trung (file chung — đổi route cần nhóm review).
/// Mã màn hình trong route trùng SRS để dễ tìm khi review.
class AppRoutes {
  const AppRoutes._();

  static const home = '/';

  // C — Đội hình
  static const c01 = '/C01';
  static String c02(String lineupId, {bool openPitchAfter = false}) =>
      '/C02/${Uri.encodeComponent(lineupId)}${openPitchAfter ? '?next=C04' : ''}';
  static String c03(String lineupId, String slotId) =>
      '/C03/${Uri.encodeComponent(lineupId)}/${Uri.encodeComponent(slotId)}';
  static String c04(String lineupId) => '/C04/${Uri.encodeComponent(lineupId)}';
}
