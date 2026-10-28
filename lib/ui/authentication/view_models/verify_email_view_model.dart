import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/auth_repository.dart';

part 'verify_email_view_model.g.dart';

enum VerificationAction { idle, sending, checking }

@riverpod
class VerifyEmailViewModel extends _$VerifyEmailViewModel {
  @override
  VerificationAction build() => VerificationAction.idle;

  Future<String?> sendEmail() => _run(VerificationAction.sending, () async {
    await ref.read(authRepositoryProvider).sendEmailVerification();
    return 'Email xác minh đã được gửi';
  });

  Future<String?> checkEmail() => _run(VerificationAction.checking, () async {
    final verified = await ref
        .read(authRepositoryProvider)
        .reloadAndCheckEmailVerified();
    return verified ? null : 'Email chưa được xác minh';
  });

  Future<String?> _run(
    VerificationAction action,
    Future<String?> Function() command,
  ) async {
    if (state != VerificationAction.idle) return null;
    state = action;
    try {
      return await command();
    } catch (error) {
      if (error is FirebaseAuthException) {
        if (error.code == 'network-request-failed') {
          return 'Không có kết nối mạng';
        }
        if (error.code == 'too-many-requests') {
          return 'Bạn đã gửi quá nhiều lần. Vui lòng thử lại sau';
        }
      }
      return 'Đã xảy ra lỗi. Vui lòng thử lại';
    } finally {
      if (ref.mounted) state = VerificationAction.idle;
    }
  }
}
