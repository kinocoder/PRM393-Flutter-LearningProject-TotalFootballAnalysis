import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:united2/data/repositories/auth_repository.dart';

part 'forgot_password_model_view.g.dart';

@riverpod
class ForgotPasswordModelView extends _$ForgotPasswordModelView {
  @override
  Future<void> build() async {}

  Future<void> sendResetPasswordEmail(String email) async {
    // 1. Kiểm tra có đang loading không
    if (state.isLoading) return;

    // 2. Chuyển state sang AsyncLoading
    state = const AsyncLoading();

    // 3. Gọi AuthRepository thông qua ref.read()
    final repository = ref.read(authRepositoryProvider);

    // 4. Dùng AsyncValue.guard() để cập nhật kết quả
    final result = await AsyncValue.guard<void>(() {
      return repository.sendPasswordResetEmail(email: email);
    });

    //5.Kiểm tra xem Provider còn hoạt động sau await không
    if (!ref.mounted) return;

    state = result;
  }

  String getResetPasswordErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Địa chỉ email không hợp lệ';

        case 'too-many-requests':
          return 'Bạn đã gửi quá nhiều yêu cầu. Vui lòng thử lại sau';

        case 'network-request-failed':
          return 'Không có kết nối mạng. Vui lòng kiểm tra và thử lại';

        case 'user-not-found':
          return 'Nếu email đã được đăng ký, bạn sẽ nhận được liên kết đặt lại mật khẩu';
      }
    }

    return 'Không thể xử lý yêu cầu lúc này. Vui lòng thử lại sau';
  }
}
