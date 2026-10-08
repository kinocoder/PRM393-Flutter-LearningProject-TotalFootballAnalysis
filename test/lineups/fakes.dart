import 'package:united2/data/repositories/lineup_repository.dart';
import 'package:united2/data/repositories/owned_player_repository.dart';
import 'package:united2/data/repositories/player_repository.dart';
import 'package:united2/domain/models/lineup.dart';
import 'package:united2/domain/models/player.dart';

/// Repository đội hình trong bộ nhớ cho test (thay SQLite/Firestore).
class FakeLineupRepository implements LineupRepository {
  final Map<String, Lineup> items = {};
  int saveCalls = 0;
  bool failSave = false;

  @override
  Future<List<Lineup>> list(String uid) async =>
      items.values.where((l) => l.uid == uid).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  @override
  Future<Lineup?> get(String uid, String id) async {
    final l = items[id];
    return l != null && l.uid == uid ? l : null;
  }

  @override
  Future<void> save(Lineup lineup) async {
    saveCalls++;
    if (failSave) throw Exception('save failed');
    items[lineup.id] = lineup;
  }

  @override
  Future<void> delete(String uid, String id) async {
    items.remove(id);
  }

  @override
  Future<void> restore(Lineup lineup) async {
    items[lineup.id] = lineup;
  }

  @override
  Future<SyncResult> sync(String uid) async => const SyncResult(enabled: false);
}

class FakeOwnedPlayerRepository implements OwnedPlayerRepository {
  FakeOwnedPlayerRepository([Map<String, List<String>>? initial]) : owned = initial ?? {};

  final Map<String, List<String>> owned;

  @override
  Future<List<String>> ownedPlayerIds(String uid) async => owned[uid] ?? const [];

  @override
  Future<void> addSampleOwned(String uid, List<String> playerIds) async {
    owned[uid] = {...?owned[uid], ...playerIds}.toList();
  }
}

class FakePlayerRepository implements PlayerRepository {
  FakePlayerRepository(List<Player> players) : _players = {for (final p in players) p.id: p};

  final Map<String, Player> _players;

  @override
  Future<Map<String, Player>> getPlayersByIds(Iterable<String> ids) async => {
        for (final id in ids)
          if (_players[id] != null) id: _players[id]!,
      };

  @override
  Future<List<Player>> samplePlayers() async => _players.values.toList();
}

Player makePlayer(String id, String position, {int ovr = 90, Map<String, int> ratings = const {}}) => Player(
      id: id,
      name: id.toUpperCase(),
      position: position,
      ovr: ovr,
      positionRatings: ratings,
      dataVersion: 'test',
    );
