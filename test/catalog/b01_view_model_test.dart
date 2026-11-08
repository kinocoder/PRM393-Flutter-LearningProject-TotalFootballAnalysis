import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united2/data/model/player.dart';
import 'package:united2/data/model/player_query.dart';
import 'package:united2/data/repositories/player_repository.dart';
import 'package:united2/ui/catalog/view_models/b01_view_model.dart';

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
    when(() => mockRepository.getPlayers()).thenAnswer((_) async => [player1]);
    when(() => mockRepository.filterPlayers(any())).thenReturn([player1]);
  });

  group('B01ViewModel Unit Tests', () {
    test('build() fetches players from PlayerRepository', () async {
      final container = ProviderContainer(
        overrides: [
          playerRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(b01ViewModelProvider.future);

      expect(result.length, 1);
      expect(result.first.name, 'O. Dembélé');
    });

    test('refresh() reloads players list', () async {
      final container = ProviderContainer(
        overrides: [
          playerRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(b01ViewModelProvider.future);

      await container.read(b01ViewModelProvider.notifier).refresh();

      final result = container.read(b01ViewModelProvider).value;
      expect(result, isNotNull);
      expect(result?.length, 1);
    });
  });
}
