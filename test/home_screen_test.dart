import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united2/data/model/auth_session.dart';
import 'package:united2/routing/app_routes.dart';
import 'package:united2/ui/authentication/view_models/auth_session_view_model.dart';
import 'package:united2/ui/home/widgets/home_screen.dart';

void main() {
  Future<void> mount(WidgetTester tester, AuthSession user) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith((ref) => Stream.value(user)),
        ],
        child: MaterialApp(
          home: const HomeScreen(),
          routes: {
            AppRoutes.b01: (_) => const Scaffold(body: Text('B01 destination')),
            AppRoutes.b02: (_) => const Scaffold(body: Text('B02 destination')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Account menu shows email fallback and read-only details', (
    tester,
  ) async {
    await mount(
      tester,
      const AuthSession(
        uid: '1',
        emailVerified: true,
        name: ' ',
        email: 'player@example.com',
      ),
    );
    expect(find.text('Xin chào, player!'), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    expect(find.text('Đăng xuất'), findsOneWidget);
    await tester.tap(find.text('Chi tiết tài khoản'));
    await tester.pumpAndSettle();
    expect(find.text('player@example.com'), findsOneWidget);
    expect(find.text('Đã xác minh email'), findsOneWidget);
    await tester.tap(find.byTooltip('Đóng'));
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết tài khoản'), findsNothing);
  });

  testWidgets('Two cards share a row and navigate to existing named routes', (
    tester,
  ) async {
    await mount(tester, const AuthSession(uid: '1', emailVerified: true));
    final cards = find.byType(Card);
    expect(cards, findsNWidgets(2));
    expect(
      tester.getTopLeft(cards.at(0)).dy,
      tester.getTopLeft(cards.at(1)).dy,
    );
    for (final entry in {
      'Danh mục cầu thủ': 'B01 destination',
      'Tìm kiếm cầu thủ': 'B02 destination',
    }.entries) {
      await tester.ensureVisible(find.text(entry.key));
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets(
    'Narrow display and large text remain scrollable without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await mount(
        tester,
        const AuthSession(
          uid: '1',
          emailVerified: true,
          name: 'Tên người dùng rất dài để kiểm tra bố cục',
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Tài khoản'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chi tiết tài khoản'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
