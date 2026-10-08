import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:united2/data/repositories/auth_repository.dart';

part 'register_view_model.g.dart';

@riverpod
class RegisterViewModel extends _$RegisterViewModel {
  @override
  FutureOr<void> build() {
    // Chưa cần tải dữ liệu ban đầu.
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Vui lòng nhập email';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Email không đúng định dạng';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    if (RegExp(r'\s').hasMatch(value)) {
      return 'Mật khẩu không được chứa khoảng trắng';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất một chữ thường';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất một chữ hoa';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất một chữ số';
    }

    if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất một ký tự đặc biệt';
    }

    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập lại mật khẩu';
    }

    if (value != password) {
      return 'Hai mật khẩu không trùng nhau';
    }

    return null;
  }

  //Lỗi
  String getRegisterErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Email này đã được sử dụng';
        case 'invalid-email':
          return 'Email không hợp lệ';
        case 'weak-password':
          return 'Mật khẩu chưa đủ mạnh';
        case 'operation-not-allowed':
          return 'Đăng ký bằng email chưa được bật';
        case 'network-request-failed':
          return 'Không có kết nối mạng';
        case 'too-many-requests':
          return 'Bạn thao tác quá nhiều lần. Vui lòng thử lại sau';
        default:
          return 'Không thể đăng ký. Vui lòng thử lại';
      }
    }

    return 'Đã xảy ra lỗi không xác định';
  }

  //Đăng ký
  Future<void> register({required String email, required String password}) async {
    //tránh gửi thêm dữ liệu khi đăng ký
    if (state.isLoading) return;

    final repository = ref.read(authRepositoryProvider);

    state = const AsyncLoading();

    final result = await AsyncValue.guard<void>(() async {
      await repository.register(email: email, password: password);
    });

    if(!ref.mounted) return;

    state = result;
  }
}
