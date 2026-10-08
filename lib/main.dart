import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united2/ui/authentication/widgets/verify_email_screen.dart';
import 'package:united2/ui/home/widgets/home_screen.dart';
import 'ui/authentication/widgets/register_screen.dart';
import 'routing/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ProviderScope(
      child: MaterialApp(
        initialRoute: AppRoutes.register,
        routes: {
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.verifyEmail: (context) => const VerifyEmailScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
        },
      ),
    ),
  );
}
