import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/player_repository.dart';
import '../view_models/collection_view_models.dart';
import 'collection_player_card.dart';
import 'add_player_to_collection_screen.dart';

class MyCollectionScreen extends ConsumerWidget {
  const MyCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(myCollectionProvider);
    final players = ref.watch(playerRepositoryProvider).players;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bộ sưu tập của tôi'),
        actions: [
          IconButton(
            tooltip: 'Thêm cầu thủ',
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddPlayerToCollectionScreen(),
              ),
            ),
          ),
        ],
      ),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Không tải được bộ sưu tập: $error')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddPlayerToCollectionScreen(),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Thêm cầu thủ đầu tiên'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(myCollectionProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final entry = items[index];
                final player = players
                    .where((p) => p.id == entry.playerId)
                    .firstOrNull;
                if (player == null) return const SizedBox.shrink();
                return CollectionPlayerCard(
                  player: player,
                  note: entry.note,
                  trailing: IconButton(
                    tooltip: 'Xóa khỏi bộ sưu tập',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref
                        .read(myCollectionProvider.notifier)
                        .removePlayer(player.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
