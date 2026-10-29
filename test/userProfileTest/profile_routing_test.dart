import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united2/data/repositories/auth_repository.dart';
import 'package:united2/data/model/auth_session.dart';
import 'package:united2/routing/app_router.dart';
import 'package:united2/routing/app_routes.dart';
import 'package:united2/ui/authentication/view_models/user_profile_view_model.dart';
import 'package:united2/ui/authentication/view_models/auth_session_view_model.dart';
import 'package:united2/ui/authentication/widgets/login_screen.dart';
import 'package:united2/ui/authentication/widgets/user_profile_screen.dart';
import 'package:united2/ui/authentication/widgets/verify_email_screen.dart';

import 'support/profile_fakes.dart';

class RoutingAuthRepository extends Mock implements AuthRepository {}

void main() {
  for (final entry in <String, AuthSession?>{
    'signed out': null,
    'unverified': const AuthSession(uid: 'one', emailVerified: false),
    'verified': const AuthSession(uid: 'one', emailVerified: true),
  }.entries) {
    testWidgets('G01 profile route guard: ${entry.key}', (tester) async {
      final router = AppRouter(AsyncData(entry.value), onRetry: () {});
      final auth = RoutingAuthRepository();
      when(() => auth.sendEmailVerification()).thenAnswer((_) async {});
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            authSessionProvider.overrideWith(
              (ref) => Stream.value(entry.value),
            ),
            userProfileViewModelProvider.overrideWithBuild(
              (ref, notifier) async => sampleProfile,
            ),
          ],
          child: MaterialApp(
            home: const SizedBox(),
            onGenerateRoute: router.onGenerateRoute,
          ),
        ),
      );
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed(AppRoutes.userProfile);
      await tester.pumpAndSettle();
      if (entry.key == 'signed out') {
        expect(find.byType(LoginScreen), findsOneWidget);
      }
      if (entry.key == 'unverified') {
        expect(find.byType(VerifyEmailScreen), findsOneWidget);
      }
      if (entry.key == 'verified') {
        expect(find.byType(UserProfileScreen), findsOneWidget);
        expect(find.text('Player'), findsOneWidget);
      } else {
        expect(find.byType(UserProfileScreen), findsNothing);
      }
    });
  }
}
