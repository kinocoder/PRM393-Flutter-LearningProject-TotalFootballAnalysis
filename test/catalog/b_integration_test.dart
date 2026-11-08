import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united2/data/model/auth_session.dart';
import 'package:united2/data/model/player.dart';
import 'package:united2/data/model/player_query.dart';
import 'package:united2/data/model/skill.dart';
import 'package:united2/data/repositories/collection_repository.dart';
import 'package:united2/data/repositories/player_repository.dart';
import 'package:united2/routing/app_router.dart';
import 'package:united2/routing/app_routes.dart';

class MockPlayerRepository extends Mock implements PlayerRepository {}
class MockCollectionRepository extends Mock implements CollectionRepository {}

void main() {
  late MockPlayerRepository mockPlayerRepo;
  late MockCollectionRepository mockCollectionRepo;

  const dembele = Player(
    id: '9275',
    name: 'O. Dembélé',
    fullName: 'Ousmane Dembélé',
    position: 'RW',
    cardVersion: 'TOTS',
    ovr: 123,
    level: 10,
    positionRatings: {'RW': 123},
    stats: {'PAC': 128, 'SHO': 112, 'PAS': 116, 'DRI': 124, 'DEF': 55, 'PHY': 89},
    statDetails: {},
    skills: [
      Skill(id: 'sk_01', name: 'Speed Dribbler', type: 'Special', description: 'Rê bóng tốc độ cao')
    ],
    nation: 'Pháp',
    club: 'FC Barcelona',
    age: 27,
    heightCm: 178,
    weightKg: 73,
    skillMoves: 5,
  );

  const mbappe = Player(
    id: '9284',
    name: 'K. Mbappé',
    fullName: 'Kylian Mbappé',
    position: 'ST',
    cardVersion: 'TOTY',
    ovr: 125,
    level: 10,
    positionRatings: {'ST': 125},
    stats: {'PAC': 132},
    statDetails: {},
    nation: 'Pháp',
    club: 'Real Madrid',
    age: 25,
    heightCm: 178,
    weightKg: 75,
    skillMoves: 5,
  );

  setUpAll(() {
    registerFallbackValue(const PlayerQuery());
  });

  setUp(() {
    mockPlayerRepo = MockPlayerRepository();
    mockCollectionRepo = MockCollectionRepository();

    when(() => mockPlayerRepo.getPlayers())
        .thenAnswer((_) async => [dembele, mbappe]);
    when(() => mockPlayerRepo.getPlayerByID('9275'))
        .thenAnswer((_) async => dembele);
    when(() => mockPlayerRepo.getPlayerByID('9284'))
        .thenAnswer((_) async => mbappe);
    when(() => mockPlayerRepo.searchPlayers('mbappe'))
        .thenAnswer((_) async => [mbappe]);
    when(() => mockPlayerRepo.getFilterOptions()).thenReturn({
      'positions': ['RW', 'ST'],
      'nations': ['Pháp'],
      'clubs': ['FC Barcelona', 'Real Madrid'],
      'cardVersions': ['TOTS', 'TOTY'],
    });
    when(() => mockPlayerRepo.filterPlayers(any()))
        .thenReturn([dembele, mbappe]);

    when(() => mockCollectionRepo.getFavoriteIds(any()))
        .thenAnswer((_) async => <String>{});
    when(() => mockCollectionRepo.setFavorite(
          uid: any(named: 'uid'),
          playerId: any(named: 'playerId'),
          isFavorite: any(named: 'isFavorite'),
        )).thenAnswer((_) async {});
  });

  Widget createCatalogApp({String initialRoute = AppRoutes.b01}) {
    const session = AsyncData(AuthSession(uid: 'test_user_01', emailVerified: true));
    final router = AppRouter(session, onRetry: () {});

    return ProviderScope(
      overrides: [
        playerRepositoryProvider.overrideWith((ref) => mockPlayerRepo),
        collectionRepositoryProvider.overrideWith((ref) => mockCollectionRepo),
      ],
      child: MaterialApp(
        key: router.navigationKey,
        initialRoute: initialRoute,
        onGenerateRoute: router.onGenerateRoute,
      ),
    );
  }

  group('Catalog Module Integration Tests (Mảng B Integration)', () {
    testWidgets('Integration Flow 1: E2E Browse B01 -> Open B04 Details -> Toggle Favorite -> Pop Back', (tester) async {
      await tester.pumpWidget(createCatalogApp());
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      // 1. Verify B01 screen loaded with players
      expect(find.text('Danh mục cầu thủ'), findsOneWidget);
      expect(find.text('O. DEMBÉLÉ'), findsOneWidget);
      expect(find.text('K. MBAPPÉ'), findsOneWidget);

      // 2. Tap on O. Dembélé to open B04 Player Details
      await tester.tap(find.text('O. DEMBÉLÉ'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      // 3. Verify B04 Player Details screen
      expect(find.text('Chi Tiết Cầu Thủ'), findsOneWidget);
      expect(find.text('O. Dembélé'), findsOneWidget);
      expect(find.text('Speed Dribbler'), findsOneWidget);

      // 4. Toggle favorite heart icon
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      verify(() => mockCollectionRepo.setFavorite(
            uid: any(named: 'uid'),
            playerId: '9275',
            isFavorite: true,
          )).called(1);

      // 5. Tap back arrow to return to B01
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Danh mục cầu thủ'), findsOneWidget);
    });

    testWidgets('Integration Flow 2: E2E Search Flow B01 -> B02 Search -> Type Query -> Open B04 Result', (tester) async {
      await tester.pumpWidget(createCatalogApp());
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      // 1. Tap search icon in B01
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // 2. Verify B02 Search Screen opened
      expect(find.text('Nhập tên hoặc biệt danh cầu thủ để tìm kiếm'), findsOneWidget);

      // 3. Enter search query 'mbappe'
      await tester.enterText(find.byType(TextField), 'mbappe');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      // 4. Verify search result tile
      expect(find.text('K. Mbappé'), findsOneWidget);

      // 5. Tap player tile to open B04 Details
      await tester.tap(find.text('K. Mbappé'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      // 6. Verify B04 Details screen for K. Mbappé
      expect(find.text('Chi Tiết Cầu Thủ'), findsOneWidget);
      expect(find.text('K. Mbappé'), findsOneWidget);
      expect(find.text('Real Madrid • Pháp'), findsOneWidget);
    });

    testWidgets('Integration Flow 3: E2E Filter Flow B01 -> B03 Filter -> Select Position -> Apply Filter', (tester) async {
      await tester.pumpWidget(createCatalogApp());
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      // 1. Tap tune/filter icon in B01
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      // 2. Verify B03 Filter Screen opened
      expect(find.text('Bộ Lọc Cầu Thủ'), findsOneWidget);
      expect(find.text('RW'), findsOneWidget);
      expect(find.text('ST'), findsOneWidget);

      // 3. Tap ST position chip
      await tester.tap(find.text('ST'));
      await tester.pumpAndSettle();

      // 4. Tap Apply Filter button
      await tester.tap(find.text('Xem 2 cầu thủ phù hợp'));
      await tester.pumpAndSettle();

      // 5. Verify returned to B01 catalog list
      expect(find.text('Danh mục cầu thủ'), findsOneWidget);
    });
  });
}
