import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united2/data/model/player.dart';
import 'package:united2/data/repositories/player_repository.dart';
import 'package:united2/ui/catalog/view_models/b04_view_model.dart';

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

  setUp(() {
    mockRepository = MockPlayerRepository();
  });

  group('B04ViewModel Unit Tests (Player Details)', () {
    test('build(playerId) returns player details when ID exists', () async {
      when(() => mockRepository.getPlayerByID('9275'))
          .thenAnswer((_) async => player1);

      final container = ProviderContainer(
        overrides: [
          playerRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(b04ViewModelProvider('9275').future);

      expect(result.id, '9275');
      expect(result.name, 'O. Dembélé');
      verify(() => mockRepository.getPlayerByID('9275')).called(1);
    });

    test('build(playerId) throws exception when player ID is invalid', () async {
      when(() => mockRepository.getPlayerByID('invalid'))
          .thenAnswer((_) async => null);

      final container = ProviderContainer(
        overrides: [
          playerRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(b04ViewModelProvider('invalid').future),
        throwsA(anything),
      );
    });

    test('refresh() reloads player details', () async {
      when(() => mockRepository.getPlayerByID('9275'))
          .thenAnswer((_) async => player1);

      final container = ProviderContainer(
        overrides: [
          playerRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(b04ViewModelProvider('9275').future);

      await container.read(b04ViewModelProvider('9275').notifier).refresh();

      final result = container.read(b04ViewModelProvider('9275')).value;
      expect(result, isNotNull);
      expect(result?.id, '9275');
      verify(() => mockRepository.getPlayerByID('9275')).called(2);
    });
  });
}
