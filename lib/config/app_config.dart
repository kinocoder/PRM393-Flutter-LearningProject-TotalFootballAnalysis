/// Cấu hình môi trường. Đổi bằng `--dart-define`, ví dụ:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
/// ```
///
/// `10.0.2.2` là máy tính khi chạy trên Android emulator.
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const Duration requestTimeout = Duration(seconds: 10);

  /// Thời gian chờ tối đa khi đồng bộ đội hình lên Firestore (C01/C04).
  static const Duration syncTimeout = Duration(seconds: 5);
}
