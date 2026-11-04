import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/model/collection_entry.dart';
import '../../../data/model/comparison_record.dart';
import '../../../data/model/player.dart';
import '../../../data/repositories/collection_repository.dart';
import '../../../data/repositories/comparison_history_repository.dart';
import '../../../data/repositories/current_user_provider.dart';
import '../../../data/repositories/player_repository.dart';

part 'collection_view_models.g.dart';

/// Màn E01: danh sách các cầu thủ trong bộ sưu tập của người dùng hiện tại.
@riverpod
class MyCollection extends _$MyCollection {
  @override
  Future<List<CollectionEntry>> build() {
    return ref
        .watch(collectionRepositoryProvider)
        .getCollection(ref.watch(currentUidProvider));
  }

  Future<bool> addPlayer(String playerId, {String note = ''}) async {
    final added = await ref
        .read(collectionRepositoryProvider)
        .addToCollection(
          uid: ref.read(currentUidProvider),
          playerId: playerId,
          note: note,
        );
    ref.invalidateSelf();
    return added;
  }

  Future<void> removePlayer(String playerId) async {
    await ref
        .read(collectionRepositoryProvider)
        .removeFromCollection(
          uid: ref.read(currentUidProvider),
          playerId: playerId,
        );
    ref.invalidateSelf();
  }
}

/// Nguồn dữ liệu cho E02. Phần E chỉ đọc danh mục mock dùng chung của phần B.
@riverpod
Future<List<Player>> collectionCandidates(Ref ref) {
  return ref.watch(playerRepositoryProvider).getPlayers();
}

/// Màn E03: chỉ trả về cầu thủ đã được đánh dấu tim.
@riverpod
class FavoritePlayerIds extends _$FavoritePlayerIds {
  @override
  Future<Set<String>> build() {
    return ref
        .watch(collectionRepositoryProvider)
        .getFavoriteIds(ref.watch(currentUidProvider));
  }

  Future<void> removeFavorite(String playerId) async {
    await ref
        .read(collectionRepositoryProvider)
        .setFavorite(
          uid: ref.read(currentUidProvider),
          playerId: playerId,
          isFavorite: false,
        );
    ref.invalidateSelf();
  }
}

/// Màn E04: đọc lịch sử mà phần A đã lưu, không tạo một nguồn dữ liệu thứ hai.
@riverpod
class CollectionComparisonHistory extends _$CollectionComparisonHistory {
  @override
  Future<List<ComparisonRecord>> build() {
    return ref
        .watch(comparisonHistoryRepositoryProvider)
        .getHistoryByUid(ref.watch(currentUidProvider));
  }

  Future<void> removeRecord(String id) async {
    await ref.read(comparisonHistoryRepositoryProvider).deleteRecord(id);
    ref.invalidateSelf();
  }
}
