import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united2/data/model/player.dart';
import 'package:united2/data/repositories/player_repository.dart';
import 'package:united2/ui/catalog/view_models/b02_view_model.dart';

class MockPlayerRepository extends Mock implements PlayerRepository {}

void main() {
  late MockPlayerRepository mockRepository;

  const player1 = Player(
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

  setUp(() {
    mockRepository = MockPlayerRepository();
  });

  group('B02ViewModel Unit Tests (Search)', () {
    test('initial state has empty query and no results', () {
      final container = ProviderContainer(
        overrides: [
          playerRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(b02ViewModelProvider);

      expect(state.isInitial, isTrue);
      expect(state.query, isEmpty);
      expect(state.results, isEmpty);
      expect(state.isLoading, isFalse);
    });

    test('onQueryChanged() updates query and triggers search execution', () {
      fakeAsync((async) {
        when(() => mockRepository.searchPlayers('mbappe'))
            .thenAnswer((_) => Future.value([player1]));

        final container = ProviderContainer(
          overrides: [
            playerRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );
        addTearDown(container.dispose);

        container.listen(b02ViewModelProvider, (_, __) {});

        final notifier = container.read(b02ViewModelProvider.notifier);
        notifier.onQueryChanged('mbappe');

        expect(container.read(b02ViewModelProvider).query, 'mbappe');

        async.elapse(const Duration(milliseconds: 400));
        async.flushMicrotasks();

        final finalState = container.read(b02ViewModelProvider);
        expect(finalState.results.length, 1);
        expect(finalState.results.first.name, 'K. Mbappé');
      });
    });

    test('clearQuery() resets search state immediately', () {
      final container = ProviderContainer(
        overrides: [
          playerRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(b02ViewModelProvider.notifier);
      notifier.onQueryChanged('test');
      notifier.clearQuery();

      final state = container.read(b02ViewModelProvider);
      expect(state.isInitial, isTrue);
      expect(state.query, isEmpty);
      expect(state.results, isEmpty);
    });
  });
}
