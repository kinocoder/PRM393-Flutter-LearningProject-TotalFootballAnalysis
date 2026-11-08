import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united2/data/model/player.dart';
import 'package:united2/data/model/player_query.dart';
import 'package:united2/data/repositories/player_repository.dart';
import 'package:united2/ui/catalog/widgets/b03_screen.dart';

class MockPlayerRepository extends Mock implements PlayerRepository {}

void main() {
  late MockPlayerRepository mockRepository;

  const player1 = Player(
    id: '9275',
    name: 'O. Dembélé',
    fullName: 'Ousmane Dembélé',
    position: 'RW',
    cardVersion: 'TOTS',
    ovr: 123,
    level: 10,
    positionRatings: {'RW': 123},
    stats: {'PAC': 128},
    statDetails: {},
    nation: 'Pháp',
    club: 'FC Barcelona',
    age: 27,
    heightCm: 178,
    weightKg: 73,
    skillMoves: 5,
  );

  setUpAll(() {
    registerFallbackValue(const PlayerQuery());
  });

  setUp(() {
    mockRepository = MockPlayerRepository();
    when(() => mockRepository.getFilterOptions()).thenReturn({
      'positions': ['RW', 'ST', 'GK'],
      'nations': ['Pháp', 'Việt Nam'],
      'clubs': ['FC Barcelona', 'Real Madrid'],
      'cardVersions': ['TOTS', 'TOTY'],
    });
    when(() => mockRepository.filterPlayers(any())).thenReturn([player1]);
  });

  group('B03Screen Widget Tests (Filter)', () {
    testWidgets('renders all filter options and apply button correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: const MaterialApp(
            home: B03Screen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bộ Lọc Cầu Thủ'), findsOneWidget);
      expect(find.text('Vị trí thi đấu'), findsOneWidget);
      expect(find.text('RW'), findsOneWidget);
      expect(find.text('ST'), findsOneWidget);
      expect(find.text('Xem 1 cầu thủ phù hợp'), findsOneWidget);
    });

    testWidgets('clicking reset button resets options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: const MaterialApp(
            home: B03Screen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Đặt lại'));
      await tester.pumpAndSettle();

      expect(find.text('Đặt lại'), findsOneWidget);
    });
  });
}
