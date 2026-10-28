import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united2/ui/authentication/widgets/forgot_password_screen.dart';
import 'package:united2/ui/authentication/widgets/login_screen.dart';
import 'package:united2/ui/authentication/widgets/verify_email_screen.dart';
import 'package:united2/ui/catalog/widgets/b03_screen.dart';
import 'package:united2/ui/home/widgets/home_screen.dart';
import 'package:united2/ui/catalog/widgets/b01_screen.dart';
import 'package:united2/ui/catalog/widgets/b02_screen.dart';

import 'ui/authentication/widgets/register_screen.dart';
import 'routing/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ProviderScope(
      child: MaterialApp(
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
          AppRoutes.verifyEmail: (context) => const VerifyEmailScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.b01: (context) => const B01Screen(),
          AppRoutes.b02: (context) => const B02Screen(),
          AppRoutes.b03: (context) => const B03Screen(),

        },
      ),
    ),
  );
}
