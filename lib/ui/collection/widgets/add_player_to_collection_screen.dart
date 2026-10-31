import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/model/player.dart';
import '../view_models/collection_view_models.dart';
import 'collection_player_card.dart';

class AddPlayerToCollectionScreen extends ConsumerStatefulWidget {
  const AddPlayerToCollectionScreen({super.key});

  @override
  ConsumerState<AddPlayerToCollectionScreen> createState() =>
      _AddPlayerToCollectionScreenState();
}

class _AddPlayerToCollectionScreenState
    extends ConsumerState<AddPlayerToCollectionScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final candidates = ref.watch(collectionCandidatesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm cầu thủ')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Tìm theo tên cầu thủ',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: candidates.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Không tải được cầu thủ: $error')),
              data: (players) {
                final filtered = players.where(_matchesQuery).toList();
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Không tìm thấy cầu thủ phù hợp.'),
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => CollectionPlayerCard(
                    player: filtered[index],
                    trailing: IconButton(
                      tooltip: 'Thêm vào bộ sưu tập',
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _showAddDialog(filtered[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesQuery(Player player) {
    return _query.isEmpty ||
        player.name.toLowerCase().contains(_query) ||
        player.fullName.toLowerCase().contains(_query);
  }

  Future<void> _showAddDialog(Player player) async {
    final note = await showDialog<String?>(
      context: context,
      builder: (_) => _AddPlayerNoteDialog(playerName: player.name),
    );
    if (note == null || !mounted) return;
    final added = await ref
        .read(myCollectionProvider.notifier)
        .addPlayer(player.id, note: note);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? 'Đã thêm ${player.name}.'
              : '${player.name} đã có trong bộ sưu tập.',
        ),
      ),
    );
    if (added) Navigator.pop(context);
  }
}

/// Controller thuộc về chính dialog, nên khi người dùng bấm Hủy nó được dispose
/// sau khi dialog rời widget tree; không làm lỗi đỏ do controller bị dùng muộn.
class _AddPlayerNoteDialog extends StatefulWidget {
  const _AddPlayerNoteDialog({required this.playerName});

  final String playerName;

  @override
  State<_AddPlayerNoteDialog> createState() => _AddPlayerNoteDialogState();
}

class _AddPlayerNoteDialogState extends State<_AddPlayerNoteDialog> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Thêm ${widget.playerName}?'),
      content: TextField(
        controller: _noteController,
        autofocus: true,
        maxLength: 100,
        autocorrect: false,
        enableSuggestions: false,
        decoration: const InputDecoration(
          labelText: 'Ghi chú (không bắt buộc)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _noteController.text),
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
