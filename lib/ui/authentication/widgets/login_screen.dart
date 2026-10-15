import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:united2/routing/app_routes.dart';
import 'package:united2/utils/validators/email_validator.dart';
import 'package:united2/ui/authentication/view_models/login_view_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userName = TextEditingController();
  final _password = TextEditingController();

  bool _passwordVisible = false;

  @override
  void dispose() {
    _userName.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text("Đăng nhập", style: TextStyle(fontSize: 30)),
                  ),
                  TextFormField(
                    validator: validateEmail,
                    controller: _userName,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: true,
                    decoration: InputDecoration(
                      label: Text("Email"),
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _password,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      label: Text("Password"),
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        tooltip: _passwordVisible
                            ? 'Ẩn mật khẩu'
                            : 'Hiện mật khẩu',
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loginState.isLoading
                              ? null
                              : () async {
                                  final isValid =
                                      _formKey.currentState?.validate() ??
                                      false;
                                  if (!isValid) return;

                                  final result = await ref
                                      .read(loginViewModelProvider.notifier)
                                      .login(
                                        email: _userName.text.trim(),
                                        password: _password.text,
                                      );

                                  if (!context.mounted) return;

                                  if (result == null) {
                                    final state = ref.read(
                                      loginViewModelProvider,
                                    );
                                    if (state.hasError) {
                                      final message = ref
                                          .read(loginViewModelProvider.notifier)
                                          .getLoginErrorMessage(state.error!);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(content: Text(message)),
                                          );
                                    }
                                    return;
                                  }

                                  final route =
                                      result == LoginResult.authenticated
                                      ? AppRoutes.home
                                      : AppRoutes.verifyEmail;
                                  Navigator.of(context)
                                      .pushReplacementNamed(route);
                                },
                          child: loginState.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Đăng nhập'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: const Text('Đăng ký'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
