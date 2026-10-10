import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united2/data/repositories/auth_repository.dart';
import 'package:united2/routing/app_routes.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() =>
      _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isSending = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendVerificationEmail();
    });
  }

  String _errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'network-request-failed':
          return 'Không có kết nối mạng';
        case 'too-many-requests':
          return 'Bạn đã gửi quá nhiều lần. Vui lòng thử lại sau';
      }
    }

    return 'Đã xảy ra lỗi. Vui lòng thử lại';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _sendVerificationEmail() async {
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();

      if (!mounted) return;
      _showMessage('Email xác minh đã được gửi');
    } catch (error) {
      if (!mounted) return;
      _showMessage(_errorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _checkEmailVerified() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      final isVerified = await ref
          .read(authRepositoryProvider)
          .reloadAndCheckEmailVerified();

      if (!mounted) return;

      if (isVerified) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        return;
      }

      _showMessage('Email chưa được xác minh');
    } catch (error) {
      if (!mounted) return;
      _showMessage(_errorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.read(authRepositoryProvider).currentUserEmail;
    final isLoading = _isSending || _isChecking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác minh email'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 80,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Kiểm tra hộp thư của bạn',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
                    child: _isChecking
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
                  child: _isSending
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
