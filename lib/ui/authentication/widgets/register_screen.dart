import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/register_view_model.dart';

import 'package:united2/routing/app_routes.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: SafeArea(
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
                    const Text(
                      'Tạo tài khoản',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      validator: (value) {
                        return ref
                            .read(registerViewModelProvider.notifier)
                            .validateEmail(value);
                      },
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      validator: (value) {
                        return ref
                            .read(registerViewModelProvider.notifier)
                            .validatePassword(value);
                      },
                      controller: _passwordController,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      validator: (value) {
                        return ref
                            .read(registerViewModelProvider.notifier)
                            .validateConfirmPassword(
                              value,
                              _passwordController.text,
                            );
                      },
                      controller: _confirmPasswordController,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: 'Nhập lại mật khẩu',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: registerState.isLoading
                          ? null
                          : () async {
                              //Kiểm tra các ô nhập
                              final isValid =
                                  _formKey.currentState?.validate() ?? false;

                              if (!isValid) return;

                              await ref
                                  .read(registerViewModelProvider.notifier)
                                  .register(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  );

                              //kiểm tra màn hình còn tồn tại sau khi chờ ko
                              if (!mounted) return;

                              // Đọc trạng thái mới nhất sau đăng ký.
                              final result = ref.read(
                                registerViewModelProvider,
                              );

                              //Nhận thông báo từ Firebase
                              if (result.hasError) {
                                final message = ref
                                    .read(registerViewModelProvider.notifier)
                                    .getRegisterErrorMessage(result.error!);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );

                                return;
                              }

                              Navigator.of(context)
                                  .pushReplacementNamed(AppRoutes.verifyEmail);
                            },
                      child: registerState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Đăng ký'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
