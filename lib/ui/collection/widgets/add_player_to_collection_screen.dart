import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/model/player.dart';
import '../view_models/collection_view_models.dart';
import 'collection_player_card.dart';

class AddPlayerToCollectionScreen extends ConsumerStatefulWidget {
  /// [initialPlayerId] được dùng khi màn khác muốn mở E02 cho một cầu thủ đã
  /// biết trước. Nếu null, E02 hoạt động như cũ: tìm trong toàn bộ danh mục.
  const AddPlayerToCollectionScreen({super.key, this.initialPlayerId});

  final String? initialPlayerId;

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
    final collectionEntries = ref.watch(myCollectionProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialPlayerId == null
              ? 'Thêm cầu thủ'
              : 'Xác nhận thêm cầu thủ',
        ),
      ),
      body: collectionEntries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Không tải được bộ sưu tập: $error')),
        data: (entries) {
          final addedPlayerIds = entries.map((entry) => entry.playerId).toSet();
          return Column(
            children: [
              if (widget.initialPlayerId == null)
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Center(child: Text('Không tải được cầu thủ: $error')),
                  data: (players) {
                    final filtered = widget.initialPlayerId == null
                        ? players.where(_matchesQuery).toList()
                        : players
                              .where(
                                (player) => player.id == widget.initialPlayerId,
                              )
                              .toList();
                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          widget.initialPlayerId == null
                              ? 'Không tìm thấy cầu thủ phù hợp.'
                              : 'Không tìm thấy cầu thủ được chọn.',
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => CollectionPlayerCard(
                        player: filtered[index],
                        trailing: addedPlayerIds.contains(filtered[index].id)
                            ? const _AlreadyInCollectionLabel()
                            : IconButton(
                                tooltip: 'Thêm vào bộ sưu tập',
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () =>
                                    _showAddDialog(filtered[index]),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
  }
}

class _AlreadyInCollectionLabel extends StatelessWidget {
  const _AlreadyInCollectionLabel();

  @override
  Widget build(BuildContext context) {
    return const Chip(
      avatar: Icon(Icons.check_circle, size: 16, color: Color(0xFF176B46)),
      label: Text('Đã có'),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
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
