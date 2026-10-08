import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united2/data/providers/current_user_provider.dart';
import 'package:united2/data/providers/lineup_repository_provider.dart';
import 'package:united2/domain/models/lineup.dart';
import 'package:united2/ui/lineups/widgets/c01_screen.dart';

import 'fakes.dart';

void main() {
  Future<FakeLineupRepository> pump(WidgetTester tester, {String? uid = 'u1', List<Lineup> items = const []}) async {
    final repo = FakeLineupRepository();
    for (final l in items) {
      repo.items[l.id] = l;
    }
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentUidProvider.overrideWithValue(uid),
        lineupRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: C01Screen()),
    ));
    await tester.pumpAndSettle();
    return repo;
  }

  testWidgets('C01: chưa có đội hình thì hiện màn rỗng + nút tạo', (tester) async {
    await pump(tester);
    expect(find.text('Chưa có đội hình nào'), findsOneWidget);
    expect(find.text('Tạo đội hình đầu tiên'), findsOneWidget);
  });

  testWidgets('C01: hiện đội hình của UID hiện tại', (tester) async {
    await pump(tester, items: [
      Lineup(
        id: 'l1',
        uid: 'u1',
        name: 'Đội chính',
        formationId: '4-4-2',
        slots: const {'GK': 'p1'},
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1, 9, 30),
      ),
      Lineup(
        id: 'l2',
        uid: 'u2',
        name: 'Đội người khác',
        formationId: '4-3-3',
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1),
      ),
    ]);
    expect(find.text('Đội chính'), findsOneWidget);
    expect(find.textContaining('4-4-2 · 1/11 vị trí'), findsOneWidget);
    expect(find.text('Đội người khác'), findsNothing);
  });

  testWidgets('C01: tạo đội hình qua hộp thoại tên', (tester) async {
    final repo = await pump(tester);
    await tester.tap(find.text('Tạo đội hình đầu tiên'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Đội mới');
    await tester.tap(find.widgetWithText(FilledButton, 'Tạo'));
    await tester.pump();
    await tester.pump();
    expect(repo.items.values.single.name, 'Đội mới');
  });

  testWidgets('C01: chưa đăng nhập thì yêu cầu đăng nhập', (tester) async {
    await pump(tester, uid: null);
    expect(find.text('Bạn cần đăng nhập'), findsOneWidget);
  });
}
