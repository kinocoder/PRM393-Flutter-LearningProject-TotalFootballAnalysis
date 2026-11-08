import 'package:flutter_test/flutter_test.dart';
import 'package:united2/data/model/player_query.dart';
import 'package:united2/data/repositories/player_repository.dart';

void main() {
  late PlayerRepository repository;

  setUp(() {
    repository = PlayerRepository();
  });

  group('PlayerRepository Unit Tests', () {
    test('getPlayers() returns list of players', () async {
      final result = await repository.getPlayers();

      expect(result.isNotEmpty, isTrue);
      expect(result.first.name, 'O. Dembélé');
    });

    test('getPlayerByID() returns correct player when ID matches', () async {
      final result = await repository.getPlayerByID('9284');

      expect(result, isNotNull);
      expect(result?.name, 'K. MBAPPÉ');
    });

    test('getPlayerByID() returns null when ID does not exist', () async {
      final result = await repository.getPlayerByID('invalid_id');

      expect(result, isNull);
    });

    test('searchPlayers() returns matching players with normalized text', () async {
      final result = await repository.searchPlayers('mbappe');

      expect(result.length, 1);
      expect(result.first.name, 'K. MBAPPÉ');
    });

    test('searchPlayers() returns empty list for blank query', () async {
      final result = await repository.searchPlayers('   ');

      expect(result, isEmpty);
    });

    test('getFilterOptions() extracts unique positions, nations, clubs, versions', () {
      final options = repository.getFilterOptions();

      expect(options['positions'], containsAll(['RW', 'ST']));
      expect(options['nations'], containsAll(['Pháp', 'Na Uy']));
      expect(options['clubs'], containsAll(['FC Barcelona', 'Real Madrid', 'Manchester City']));
      expect(options['cardVersions'], containsAll(['TOTS', 'TOTY']));
    });

    test('filterPlayers() filters by position and nation correctly', () {
      const query = PlayerQuery(
        positions: ['ST'],
        nation: 'Pháp',
      );

      final result = repository.filterPlayers(query);

      expect(result.length, 1);
      expect(result.first.name, 'K. MBAPPÉ');
    });

    test('filterPlayers() sorts by ovr_asc and ovr_desc', () {
      const queryAsc = PlayerQuery(sort: 'ovr_asc');
      final resultAsc = repository.filterPlayers(queryAsc);
      expect(resultAsc.first.ovr, 95);

      const queryDesc = PlayerQuery(sort: 'ovr_desc');
      final resultDesc = repository.filterPlayers(queryDesc);
      expect(resultDesc.first.ovr, 125);
    });
  });
}
