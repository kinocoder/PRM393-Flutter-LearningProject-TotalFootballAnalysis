import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/auth_session_view_model.dart';
import '../view_models/logout_view_model.dart';
import '../view_models/verify_email_view_model.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});
  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sendVerificationEmail();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendVerificationEmail() async {
    final message = await ref
        .read(verifyEmailViewModelProvider.notifier)
        .sendEmail();
    if (mounted && message != null) _showMessage(message);
  }

  Future<void> _checkEmailVerified() async {
    final message = await ref
        .read(verifyEmailViewModelProvider.notifier)
        .checkEmail();
    if (mounted && message != null) _showMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(authSessionProvider).asData?.value?.email;
    final action = ref.watch(verifyEmailViewModelProvider);
    final logout = ref.watch(logoutViewModelProvider);
    final isLoading = action != VerificationAction.idle || logout.isLoading;
    ref.listen(logoutViewModelProvider, (previous, next) {
      if (next.hasError) {
        _showMessage(ref.read(logoutViewModelProvider.notifier).errorMessage);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác minh email'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: isLoading
                ? null
                : () => ref.read(logoutViewModelProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mark_email_unread_outlined, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'Kiểm tra hộp thư của bạn',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  email == null
                      ? 'Chúng tôi đã gửi một liên kết xác minh.'
                      : 'Chúng tôi đã gửi một liên kết xác minh đến\n$email',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _checkEmailVerified,
                    child: action == VerificationAction.checking
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Tôi đã xác minh'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isLoading ? null : _sendVerificationEmail,
                  child: action == VerificationAction.sending
                      ? const Text('Đang gửi...')
                      : const Text('Gửi lại email xác minh'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
