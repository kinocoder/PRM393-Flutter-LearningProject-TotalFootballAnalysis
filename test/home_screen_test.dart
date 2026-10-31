import 'package:united2/data/model/user_profile.dart';
import 'package:united2/ui/authentication/view_models/user_profile_view_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united2/data/model/auth_session.dart';
import 'package:united2/routing/app_routes.dart';
import 'package:united2/ui/authentication/view_models/auth_session_view_model.dart';
import 'package:united2/ui/home/widgets/home_screen.dart';

class RecoveredTestProfile extends UserProfileViewModel {
  @override
  Future<UserProfile> build() async => const UserProfile(
    uid: 'one',
    email: 'player@example.com',
    displayName: 'Player',
  );
}

void main() {
  Future<void> mount(WidgetTester tester, AuthSession user) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileViewModelProvider.overrideWith(RecoveredTestProfile.new),
          authSessionProvider.overrideWith((ref) => Stream.value(user)),
        ],
        child: MaterialApp(
          home: const HomeScreen(),
          routes: {
            AppRoutes.userProfile: (_) =>
                const Scaffold(body: Text('Profile destination')),
            AppRoutes.b01: (_) => const Scaffold(body: Text('B01 destination')),
            AppRoutes.b02: (_) => const Scaffold(body: Text('B02 destination')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Account menu opens profile', (tester) async {
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
    expect(find.text('Đăng xuất'), findsNothing);
    await tester.tap(find.text('Chi tiết tài khoản'));
    await tester.pumpAndSettle();
    expect(find.text('Profile destination'), findsOneWidget);
  });

  testWidgets('Three cards navigate to existing routes', (tester) async {
    await mount(tester, const AuthSession(uid: '1', emailVerified: true));
    final cards = find.byType(Card);
    expect(cards, findsNWidgets(3));
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
