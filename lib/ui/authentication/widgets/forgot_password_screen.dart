import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united2/ui/authentication/view_models/forgot_password_model_view.dart';
import 'package:united2/utils/validators/email_validator.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    await ref
        .read(forgotPasswordModelViewProvider.notifier)
        .sendResetPasswordEmail(_emailController.text);

    if (!mounted) return;

    final result = ref.read(forgotPasswordModelViewProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (result.hasError) {
      final message = ref
          .read(forgotPasswordModelViewProvider.notifier)
          .getResetPasswordErrorMessage(result.error!);
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Email khôi phục mật khẩu đã được gửi. Vui lòng kiểm tra hộp thư.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final forgotPasswordState = ref.watch(forgotPasswordModelViewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.lock_reset_outlined, size: 72),
                      const SizedBox(height: 16),
                      const Text(
                        'Khôi phục mật khẩu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nhập email đã đăng ký. Chúng tôi sẽ gửi cho bạn liên kết để đặt lại mật khẩu.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        validator: validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.email],
                        onFieldSubmitted: forgotPasswordState.isLoading
                            ? null
                            : (_) => _sendResetEmail(),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: forgotPasswordState.isLoading
                            ? null
                            : _sendResetEmail,
                        child: forgotPasswordState.isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Text('Gửi email khôi phục'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: forgotPasswordState.isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Quay lại đăng nhập'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
