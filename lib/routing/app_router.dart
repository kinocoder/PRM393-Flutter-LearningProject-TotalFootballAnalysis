import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/model/auth_session.dart';
import '../ui/authentication/widgets/login_screen.dart';
import '../ui/authentication/widgets/register_screen.dart';
import '../ui/authentication/widgets/forgot_password_screen.dart';
import '../ui/authentication/widgets/verify_email_screen.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/catalog/widgets/b01_screen.dart';
import '../ui/catalog/widgets/b02_screen.dart';
import '../ui/catalog/widgets/b03_screen.dart';
import 'app_routes.dart';
import '../ui/authentication/widgets/user_profile_screen.dart';

/// Named-route configuration and session access policy; no Firebase calls.
class AppRouter {
  AppRouter(this.session, {required this.onRetry});
  final AsyncValue<AuthSession?> session;
  final VoidCallback onRetry;

  // Changing access or identity discards every old route, including dialogs.
  // Profile-only updates intentionally retain the navigation history.
  Key get navigationKey {
    if (session.isLoading) return const ValueKey('restoring');
    if (session.hasError) return const ValueKey('session-error');
    final user = session.asData?.value;
    return ValueKey((user?.uid, user?.emailVerified));
  }

  Route<void> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => _screen(settings.name),
    );
  }

  Widget _screen(String? name) {
    if (session.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (session.hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Không thể khôi phục phiên đăng nhập.'),
              FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }
    final user = session.asData?.value;
    if (user == null) {
      return switch (name) {
        AppRoutes.register => const RegisterScreen(),
        AppRoutes.forgotPassword => const ForgotPasswordScreen(),
        _ => const LoginScreen(),
      };
    }
    if (!user.emailVerified) return const VerifyEmailScreen();
    return switch (name) {
      '/' ||
      AppRoutes.home ||
      AppRoutes.login ||
      AppRoutes.register ||
      AppRoutes.forgotPassword ||
      AppRoutes.verifyEmail => const HomeScreen(),
      AppRoutes.userProfile => const UserProfileScreen(),
      AppRoutes.b01 => const B01Screen(),
      AppRoutes.b02 => const B02Screen(),
      AppRoutes.b03 => const B03Screen(),
      _ => Scaffold(
        appBar: AppBar(title: const Text('Chức năng')),
        body: const Center(child: Text('Chức năng chưa được triển khai.')),
      ),
    };
  }
}
