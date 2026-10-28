import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/auth_service.dart';
import '../model/auth_session.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(authService: AuthService(auth: FirebaseAuth.instance));
}

class AuthRepository {
  final AuthService _authService;

  AuthRepository({required AuthService authService})
    : _authService = authService;

  //Quên mật khẩu
  Future<void> sendPasswordResetEmail({required String email}) {
    return _authService.sendPasswordResetEmail(email: email.trim());
  }

  //Đăng ký
  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _authService.register(email: email.trim(), password: password);
  }

  //Đăng nhập
  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _authService.login(email: email.trim(), password: password);
  }

  Future<void> sendEmailVerification() {
    return _authService.sendEmailVerification();
  }

  Stream<AuthSession?> sessionChanges() =>
      _authService.userChanges().map((user) {
        if (user == null) return null;
        return AuthSession(
          uid: user.uid,
          emailVerified: user.emailVerified,
          email: user.email,
          name: user.displayName,
          avatarUrl: user.photoURL,
        );
      });

  Future<void> signOut() => _authService.signOut();

  String? get currentUserEmail => _authService.currentUserEmail;

  Future<bool> reloadAndCheckEmailVerified() {
    return _authService.reloadAndCheckEmailVerified();
  }
}
