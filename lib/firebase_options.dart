// File giữ chỗ. Chạy lệnh sau ở thư mục gốc để tạo file thật (ghi đè file này):
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Khi chưa cấu hình, app tự chuyển sang CHẾ ĐỘ LOCAL (người dùng demo cố định,
// đội hình không đồng bộ Firestore).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
        'Chưa cấu hình Firebase. Chạy `flutterfire configure` để tạo lib/firebase_options.dart.',
      );
}
