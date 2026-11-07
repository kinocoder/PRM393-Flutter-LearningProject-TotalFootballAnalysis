import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:united2/data/model/lineup.dart';
import 'package:united2/data/repositories/collection_repository.dart';
import 'package:united2/data/repositories/lineup_repository.dart';
import 'package:united2/data/repositories/player_repository.dart';
import 'package:united2/data/services/local_database_service.dart';
import 'package:united2/ui/lineups/view_models/c04_view_model.dart';
import 'package:united2/ui/lineups/widgets/c04_screen.dart';
import 'package:united2/ui/lineups/widgets/pitch_view.dart';

/// Repository giả cho test giao diện: trả về sẵn một đội hình.
class _FakeLineupRepository extends LineupRepository {
  final Lineup lineup;

  _FakeLineupRepository(this.lineup) : super(LocalDatabaseService());

  @override
  Future<Lineup?> getLineupById(String uid, String id) async => lineup;
}

void main() {
  const uid = 'demo_user';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Color slotColor(WidgetTester tester, String caption) {
    return tester
        .widget<SlotChip>(
          find.byWidgetPredicate(
            (widget) => widget is SlotChip && widget.caption == caption,
          ),
        )
        .color;
  }

  testWidgets('C04: gỡ cầu thủ khỏi bộ sưu tập thì slot chuyển màu đỏ', (
    tester,
  ) async {
    final lineup = Lineup(
      id: 'L1',
      uid: uid,
      name: 'Đội chính',
      formationId: '4-3-3',
      slots: const {'ST': '9284'},
      updatedAt: DateTime(2026, 11, 5),
    );
    final database = LocalDatabaseService(path: inMemoryDatabasePath);
    await PlayerRepository(database).getPlayers();
    final collection = CollectionRepository(database);
    await collection.addToCollection(uid: uid, playerId: '9284');

    final container = ProviderContainer.test(
      overrides: [
        lineupRepositoryProvider.overrideWithValue(
          _FakeLineupRepository(lineup),
        ),
        collectionRepositoryProvider.overrideWith((ref) => collection),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: C04Screen(lineupId: 'L1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(slotColor(tester, 'K. MBAPPÉ'), Colors.white);

    await collection.removeFromCollection(uid: uid, playerId: '9284');
    container.invalidate(c04OwnedIdsProvider);
    await tester.pumpAndSettle();

    expect(slotColor(tester, 'K. MBAPPÉ'), Colors.red);

    await tester.tap(find.text('K. MBAPPÉ'));
    await tester.pumpAndSettle();
    expect(find.text('Cầu thủ này không còn trong bộ sưu tập'), findsOneWidget);
  });
}
