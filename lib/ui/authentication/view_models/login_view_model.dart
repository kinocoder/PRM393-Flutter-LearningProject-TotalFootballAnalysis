import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:united2/data/repositories/auth_repository.dart';

part 'login_view_model.g.dart';

enum LoginResult { requiresEmailVerification, authenticated }

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  Future<void> build() async {
    return;
  }

  Future<LoginResult?> login({
    required String email,
    required String password,
  }) async {
    // 1. Chặn gửi lặp.
    if (state.isLoading) return null;
    // 2. Chuyển sang loading.
    state = const AsyncLoading();

    // 3. Gọi repository.login().
    final repository = ref.read(authRepositoryProvider);

    LoginResult? loginResult;
    final result = await AsyncValue.guard<void>(() async {
      final credential = await repository.login(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw StateError('Không nhận được thông tin người dùng');
      }
      loginResult = user.emailVerified
          ? LoginResult.authenticated
          : LoginResult.requiresEmailVerification;
    });

    if (!ref.mounted) return null;

    state = result;
    return result.hasError ? null : loginResult;
  }

  String getLoginErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Email không hợp lệ';
        case 'invalid-credential':
        case 'user-not-found':
        case 'wrong-password':
          return 'Email hoặc mật khẩu không đúng';
        case 'user-disabled':
          return 'Tài khoản này đã bị vô hiệu hóa';
        case 'too-many-requests':
          return 'Bạn đã thử quá nhiều lần. Vui lòng thử lại sau';
        case 'network-request-failed':
          return 'Không có kết nối mạng';
      }
    }

    return 'Đăng nhập thất bại. Vui lòng thử lại';
  }
}
