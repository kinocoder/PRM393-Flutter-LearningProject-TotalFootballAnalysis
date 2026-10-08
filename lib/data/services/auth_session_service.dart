import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/models/app_user.dart';

/// Nguồn phiên đăng nhập duy nhất mà các mảng đọc UID.
///
/// Mảng D sở hữu nghiệp vụ đăng nhập/đăng ký và sẽ mở rộng file này.
/// Phần C chỉ dùng [userChanges] để lấy UID.
abstract class AuthSessionService {
  Stream<AppUser?> userChanges();
}

class FirebaseAuthSessionService implements AuthSessionService {
  FirebaseAuthSessionService(this._auth);

  final fb.FirebaseAuth _auth;

  @override
  Stream<AppUser?> userChanges() => _auth.authStateChanges().map(
        (u) => u == null ? null : AppUser(uid: u.uid, email: u.email ?? '', displayName: u.displayName),
      );
}

/// Dùng khi chưa cấu hình Firebase hoặc chưa có màn đăng nhập của D:
/// luôn trả về một người dùng demo cố định để C chạy thử được.
class DemoAuthSessionService implements AuthSessionService {
  const DemoAuthSessionService();

  static const demoUser = AppUser(uid: 'demo-user', email: 'demo@totalfootball.local', displayName: 'Người chơi demo');

  @override
  Stream<AppUser?> userChanges() => Stream<AppUser?>.value(demoUser);
}
