import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united2/data/model/player.dart';
import 'package:united2/data/model/player_query.dart';
import 'package:united2/data/repositories/player_repository.dart';
import 'package:united2/ui/catalog/view_models/b03_view_model.dart';

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
    when(() => mockRepository.getFilterOptions()).thenReturn({
      'positions': ['RW', 'ST'],
      'nations': ['Pháp'],
      'clubs': ['FC Barcelona'],
      'cardVersions': ['TOTS'],
    });
    when(() => mockRepository.filterPlayers(any())).thenReturn([player1]);
  });

  setUpAll(() {
    registerFallbackValue(const PlayerQuery());
  });

  group('B03ViewModel Unit Tests (Filter)', () {
    test('build() loads filter options and matched count', () {
      final container = ProviderContainer(
        overrides: [
          playerRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(b03ViewModelProvider);

      expect(state.matchedCount, 1);
      expect(state.filterOptions['positions'], contains('RW'));
      verify(() => mockRepository.getFilterOptions()).called(1);
      verify(() => mockRepository.filterPlayers(any())).called(1);
    });

    test('togglePosition() updates position draft query', () {
      final container = ProviderContainer(
        overrides: [
          playerRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(b03ViewModelProvider.notifier);
      notifier.togglePosition('ST');

      final state = container.read(b03ViewModelProvider);
      expect(state.draftQuery.positions, contains('ST'));
    });

    test('applyFilter() updates CatalogFilter provider state', () {
      final container = ProviderContainer(
        overrides: [
          playerRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(b03ViewModelProvider.notifier);
      notifier.selectClub('FC Barcelona');
      notifier.applyFilter();

      final appliedFilter = container.read(catalogFilterProvider);
      expect(appliedFilter.club, 'FC Barcelona');
    });
  });
}
