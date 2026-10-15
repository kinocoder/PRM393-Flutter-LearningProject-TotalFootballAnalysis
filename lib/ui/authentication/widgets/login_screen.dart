import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:united2/utils/validators/email_validator.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  var _formKey = GlobalKey<FormState>();
  final _userName = TextEditingController();
  final _password = TextEditingController();

  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Card(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Align(alignment: Alignment.topCenter, child: Text("Đăng nhập")),
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
                  obscureText: _passwordVisible,
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
                ElevatedButton(
                  onPressed: () {
                    final valid = _formKey.currentState?.validate() ?? false;
                    if(!valid) return;

                  },
                  child: const Text("Đăng nhập")
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
