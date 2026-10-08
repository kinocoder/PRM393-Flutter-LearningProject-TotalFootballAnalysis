import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_user.dart';
import '../services/auth_session_service.dart';
import 'core_providers.dart';

/// Nguồn phiên dùng chung. D sở hữu nghiệp vụ đăng nhập; C và E chỉ đọc UID.
final authSessionServiceProvider = Provider<AuthSessionService>((ref) {
  if (ref.watch(firebaseReadyProvider)) return FirebaseAuthSessionService(FirebaseAuth.instance);
  return const DemoAuthSessionService();
});

final currentUserProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authSessionServiceProvider).userChanges(),
);

/// UID hiện tại; `null` khi chưa đăng nhập. Provider dữ liệu cá nhân watch
/// provider này nên đổi tài khoản sẽ tự làm mới state.
final currentUidProvider = Provider<String?>(
  (ref) => ref.watch(currentUserProvider).valueOrNull?.uid,
);
