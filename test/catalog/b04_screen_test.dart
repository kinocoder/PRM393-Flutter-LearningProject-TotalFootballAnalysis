import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united2/data/model/player.dart';
import 'package:united2/data/model/skill.dart';
import 'package:united2/data/repositories/collection_repository.dart';
import 'package:united2/data/repositories/player_repository.dart';
import 'package:united2/ui/catalog/widgets/b04_screen.dart';

class MockPlayerRepository extends Mock implements PlayerRepository {}
class MockCollectionRepository extends Mock implements CollectionRepository {}

void main() {
  late MockPlayerRepository mockPlayerRepo;
  late MockCollectionRepository mockCollectionRepo;

  const player1 = Player(
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

  setUp(() {
    mockPlayerRepo = MockPlayerRepository();
    mockCollectionRepo = MockCollectionRepository();

    when(() => mockCollectionRepo.getFavoriteIds(any()))
        .thenAnswer((_) async => <String>{});
  });

  group('B04Screen Widget Tests (Player Details)', () {
    testWidgets('displays full player details when data is loaded', (tester) async {
      when(() => mockPlayerRepo.getPlayerByID('9275'))
          .thenAnswer((_) async => player1);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerRepositoryProvider.overrideWith((ref) => mockPlayerRepo),
            collectionRepositoryProvider.overrideWith((ref) => mockCollectionRepo),
          ],
          child: const MaterialApp(
            home: B04Screen(playerId: '9275'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Chi Tiết Cầu Thủ'), findsOneWidget);
      expect(find.text('O. Dembélé'), findsOneWidget);
      expect(find.text('FC Barcelona • Pháp'), findsOneWidget);
      expect(find.text('Chỉ số chính'), findsOneWidget);
      expect(find.text('128'), findsOneWidget);
      expect(find.text('Speed Dribbler'), findsOneWidget);
      expect(find.text('Thêm Vào Bộ Sưu Tập Thẻ'), findsOneWidget);
    });

    testWidgets('toggling favorite heart icon updates favorite state', (tester) async {
      when(() => mockPlayerRepo.getPlayerByID('9275'))
          .thenAnswer((_) async => player1);
      when(() => mockCollectionRepo.setFavorite(
            uid: any(named: 'uid'),
            playerId: '9275',
            isFavorite: true,
          )).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerRepositoryProvider.overrideWith((ref) => mockPlayerRepo),
            collectionRepositoryProvider.overrideWith((ref) => mockCollectionRepo),
          ],
          child: const MaterialApp(
            home: B04Screen(playerId: '9275'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      verify(() => mockCollectionRepo.setFavorite(
            uid: any(named: 'uid'),
            playerId: '9275',
            isFavorite: true,
          )).called(1);
    });

    testWidgets('displays error message when player ID does not exist', (tester) async {
      when(() => mockPlayerRepo.getPlayerByID('invalid'))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerRepositoryProvider.overrideWith((ref) => mockPlayerRepo),
            collectionRepositoryProvider.overrideWith((ref) => mockCollectionRepo),
          ],
          child: const MaterialApp(
            home: B04Screen(playerId: 'invalid'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Không tìm thấy thông tin cầu thủ (ID: invalid)'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });
  });
}
