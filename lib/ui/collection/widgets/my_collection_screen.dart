import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/collection_view_models.dart';
import 'add_player_to_collection_screen.dart';
import 'collection_player_card.dart';

class MyCollectionScreen extends ConsumerWidget {
  const MyCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(myCollectionProvider);
    final players = ref.watch(collectionCandidatesProvider);
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
          if (items.isEmpty) return _EmptyCollection();
          return players.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('Không tải được cầu thủ: $error')),
            data: (allPlayers) => RefreshIndicator(
              onRefresh: () => ref.refresh(myCollectionProvider.future),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final entry = items[index];
                  final player = allPlayers
                      .where((item) => item.id == entry.playerId)
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
            ),
          );
        },
      ),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}
