import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united2/app.dart';
import 'package:united2/data/model/auth_session.dart';
import 'package:united2/data/repositories/auth_repository.dart';
import 'package:united2/routing/app_routes.dart';
import 'package:united2/ui/authentication/view_models/logout_view_model.dart';
import 'package:united2/ui/authentication/view_models/verify_email_view_model.dart';
import 'package:united2/ui/authentication/widgets/login_screen.dart';
import 'package:united2/ui/authentication/widgets/verify_email_screen.dart';
import 'package:united2/ui/home/widgets/home_screen.dart';

const verified = AuthSession(uid: 'one', emailVerified: true);
const unverified = AuthSession(uid: 'one', emailVerified: false);

class FakeCredential implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthRepository implements AuthRepository {
  bool failLogin = false;

  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    if (failLogin) throw FirebaseAuthException(code: 'invalid-credential');
    events.add(verified);
    return FakeCredential();
  }

  @override
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    events.add(unverified);
    return FakeCredential();
  }

  final events = StreamController<AuthSession?>.broadcast();
  int subscriptions = 0;
  int logoutCalls = 0;
  int sendCalls = 0;
  bool failLogout = false;
  bool emailVerified = false;
  Object? verificationError;
  Completer<void>? logoutPending;
  Completer<void>? sendPending;

  @override
  Stream<AuthSession?> sessionChanges() {
    subscriptions++;
    return events.stream;
  }

  @override
  Future<void> signOut() async {
    logoutCalls++;
    if (logoutPending != null) await logoutPending!.future;
    if (failLogout) throw StateError('offline');
    events.add(null);
  }

  @override
  Future<void> sendEmailVerification() async {
    sendCalls++;
    if (sendPending != null) await sendPending!.future;
    if (verificationError != null) throw verificationError!;
  }

  @override
  Future<bool> reloadAndCheckEmailVerified() async {
    if (verificationError != null) throw verificationError!;
    if (emailVerified) events.add(verified);
    return emailVerified;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> mount(WidgetTester tester, FakeAuthRepository repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
      child: const FootballApp(),
    ),
  );
}

NavigatorState navigator(WidgetTester tester) =>
    tester.state(find.byType(Navigator));

void main() {
  testWidgets(
    'Login failure remains public; successful retry enters Home once',
    (tester) async {
      final repo = FakeAuthRepository()..failLogin = true;
      await mount(tester, repo);
      repo.events.add(null);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'player@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Password1!');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pumpAndSettle();
      expect(find.text('Email hoặc mật khẩu không đúng'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      repo.failLogin = false;
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(navigator(tester).canPop(), isFalse);
      await tester.pumpWidget(const SizedBox());
      await repo.events.close();
    },
  );

  testWidgets(
    'Registration enters verification and removes public route stack',
    (tester) async {
      final repo = FakeAuthRepository();
      await mount(tester, repo);
      repo.events.add(null);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Đăng ký'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'player@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Password1!');
      await tester.enterText(find.byType(TextFormField).at(2), 'Password1!');
      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'Đăng ký'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng ký'));
      await tester.pumpAndSettle();
      expect(find.byType(VerifyEmailScreen), findsOneWidget);
      expect(navigator(tester).canPop(), isFalse);
      await tester.pumpWidget(const SizedBox());
      await repo.events.close();
    },
  );
  testWidgets(
    'Restoring, signed out, direct private routes and restored session',
    (tester) async {
      final repo = FakeAuthRepository();
      await mount(tester, repo);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      repo.events.add(null);
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      for (final route in [
        AppRoutes.home,
        AppRoutes.b01,
        AppRoutes.b02,
        AppRoutes.b04,
      ]) {
        navigator(tester).pushNamed(route);
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);
      }
      repo.events.add(verified);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(navigator(tester).canPop(), isFalse);
      await tester.pumpWidget(const SizedBox());
      await repo.events.close();
    },
  );

  testWidgets('Unverified user is guarded; successful email check opens Home', (
    tester,
  ) async {
    final repo = FakeAuthRepository();
    await mount(tester, repo);
    repo.events.add(unverified);
    await tester.pumpAndSettle();
    expect(find.byType(VerifyEmailScreen), findsOneWidget);
    navigator(tester).pushNamed(AppRoutes.b01);
    await tester.pumpAndSettle();
    expect(find.byType(VerifyEmailScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    repo.emailVerified = true;
    await tester.tap(find.text('Tôi đã xác minh'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(navigator(tester).canPop(), isFalse);
    await tester.pumpWidget(const SizedBox());
    await repo.events.close();
  });

  testWidgets('Profile changes keep stack; sign-out from child removes stack', (
    tester,
  ) async {
    final repo = FakeAuthRepository();
    await mount(tester, repo);
    repo.events.add(verified);
    await tester.pumpAndSettle();
    navigator(tester).pushNamed(AppRoutes.b04);
    await tester.pumpAndSettle();
    final oldNavigator = navigator(tester);
    repo.events.add(
      const AuthSession(uid: 'one', emailVerified: true, name: 'Updated'),
    );
    await tester.pumpAndSettle();
    expect(navigator(tester), same(oldNavigator));
    expect(find.text('Chức năng chưa được triển khai.'), findsOneWidget);
    await repo.signOut();
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(navigator(tester).canPop(), isFalse);
    expect(await navigator(tester).maybePop(), isFalse);
    await tester.pumpWidget(const SizedBox());
    await repo.events.close();
  });

  testWidgets('Session error hides private screens and retry resubscribes', (
    tester,
  ) async {
    final repo = FakeAuthRepository();
    await mount(tester, repo);
    repo.events.add(verified);
    await tester.pumpAndSettle();
    repo.events.addError(StateError('connection lost'));
    await tester.pumpAndSettle();
    expect(find.text('Không thể khôi phục phiên đăng nhập.'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.byType(LoginScreen), findsNothing);
    await tester.tap(find.text('Thử lại'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(repo.subscriptions, 2);
    repo.events.add(verified);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await repo.events.close();
  });

  testWidgets('Failed logout stays at Home; retry succeeds', (tester) async {
    final repo = FakeAuthRepository()..failLogout = true;
    await mount(tester, repo);
    repo.events.add(verified);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Không thể đăng xuất. Vui lòng thử lại.'), findsOneWidget);
    repo.failLogout = false;
    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(navigator(tester).canPop(), isFalse);
    await tester.pumpWidget(const SizedBox());
    await repo.events.close();
  });

  test('Logout command prevents repeated requests', () async {
    final repo = FakeAuthRepository()..logoutPending = Completer<void>();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    final vm = container.read(logoutViewModelProvider.notifier);
    final pending = vm.signOut();
    await vm.signOut();
    expect(repo.logoutCalls, 1);
    expect(container.read(logoutViewModelProvider).isLoading, isTrue);
    repo.logoutPending!.complete();
    await pending;
    expect(container.read(logoutViewModelProvider).hasError, isFalse);
    container.dispose();
    await repo.events.close();
  });

  test(
    'Verification commands prevent overlap and expose actionable errors',
    () async {
      final repo = FakeAuthRepository()..sendPending = Completer<void>();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );
      final subscription = container.listen(
        verifyEmailViewModelProvider,
        (_, _) {},
      );
      final vm = container.read(verifyEmailViewModelProvider.notifier);
      final pending = vm.sendEmail();
      expect(await vm.sendEmail(), isNull);
      expect(await vm.checkEmail(), isNull);
      expect(repo.sendCalls, 1);
      repo.sendPending!.complete();
      expect(await pending, 'Email xác minh đã được gửi');
      expect(await vm.checkEmail(), 'Email chưa được xác minh');
      repo.verificationError = FirebaseAuthException(
        code: 'network-request-failed',
      );
      expect(await vm.checkEmail(), 'Không có kết nối mạng');
      expect(
        container.read(verifyEmailViewModelProvider),
        VerificationAction.idle,
      );
      subscription.close();
      container.dispose();
      await repo.events.close();
    },
  );
}
