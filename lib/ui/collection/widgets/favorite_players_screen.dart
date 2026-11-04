import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/player_repository.dart';
import '../view_models/collection_view_models.dart';
import 'collection_player_card.dart';

class FavoritePlayersScreen extends ConsumerWidget {
  const FavoritePlayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritePlayerIdsProvider);
    final players = ref.watch(playerRepositoryProvider).players;
    return Scaffold(
      appBar: AppBar(title: const Text('Cầu thủ yêu thích')),
      body: favoriteIds.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Không tải được danh sách: $error')),
        data: (ids) {
          final favorites = players
              .where((player) => ids.contains(player.id))
              .toList();
          if (favorites.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Chưa có cầu thủ yêu thích. Hãy nhấn tim ở màn hình chi tiết cầu thủ.',
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final player = favorites[index];
              return CollectionPlayerCard(
                player: player,
                trailing: IconButton(
                  tooltip: 'Bỏ yêu thích',
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => ref
                      .read(favoritePlayerIdsProvider.notifier)
                      .removeFavorite(player.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
