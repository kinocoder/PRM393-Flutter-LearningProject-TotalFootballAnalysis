import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/collection_entry.dart';

part 'collection_repository.g.dart';

@Riverpod(keepAlive: true)
CollectionRepository collectionRepository(Ref ref) => CollectionRepository();

class CollectionRepository {
  final Map<String, List<CollectionEntry>> _collectionsByUid = {};

  final Map<String, Set<String>> _favoriteIdsByUid = {
    'demo_user': {'9275', '9284'},
  };

  Future<List<CollectionEntry>> getCollection(String uid) async {
    final entries = _collectionsByUid[uid] ?? const <CollectionEntry>[];
    final copy = List<CollectionEntry>.from(entries)
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return List.unmodifiable(copy);
  }

  Future<bool> addToCollection({
    required String uid,
    required String playerId,
    String note = '',
  }) async {
    final entries = _collectionsByUid.putIfAbsent(uid, () => []);
    if (entries.any((entry) => entry.playerId == playerId)) return false;

    entries.add(
      CollectionEntry(
        playerId: playerId,
        note: note.trim(),
        addedAt: DateTime.now(),
      ),
    );
    return true;
  }

  Future<void> removeFromCollection({
    required String uid,
    required String playerId,
  }) async {
    _collectionsByUid[uid]?.removeWhere((entry) => entry.playerId == playerId);
  }

  Future<Set<String>> getFavoriteIds(String uid) async {
    return Set.unmodifiable(_favoriteIdsByUid[uid] ?? const <String>{});
  }

  Future<void> setFavorite({
    required String uid,
    required String playerId,
    required bool isFavorite,
  }) async {
    final ids = _favoriteIdsByUid.putIfAbsent(uid, () => <String>{});
    if (isFavorite) {
      ids.add(playerId);
    } else {
      ids.remove(playerId);
    }
  }
}
