import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/player.dart';
import '../view_models/c03_view_model.dart';
import '../view_models/c04_view_model.dart';
import 'pitch_view.dart';

/// C03 — Chọn cầu thủ cho một vị trí (mở khi chạm vị trí ở C04).
class C03Screen extends ConsumerStatefulWidget {
  final String lineupId;
  final String slotId;
  final String role;

  const C03Screen({
    super.key,
    required this.lineupId,
    required this.slotId,
    required this.role,
  });

  @override
  ConsumerState<C03Screen> createState() => _C03ScreenState();
}

class _C03ScreenState extends ConsumerState<C03Screen> {
  String _keyword = '';
  bool _onlyMatching = true;

  @override
  Widget build(BuildContext context) {
    final playersState = ref.watch(c03ViewModelProvider);
    final viewModel = ref.read(c03ViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('Chọn cầu thủ cho ${widget.slotId}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm theo tên',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _keyword = value),
            ),
          ),
          SwitchListTile(
            title: Text('Chỉ hiện cầu thủ chơi được ${widget.role}'),
            value: _onlyMatching,
            onChanged: (value) => setState(() => _onlyMatching = value),
          ),
          Expanded(
            child: playersState.when(
              data: (players) {
                // Chưa có cầu thủ sở hữu → hướng dẫn sang Bộ sưu tập (AC-C03)
                if (players.isEmpty) {
                  return const Center(
                    child: Text(
                      'Bạn chưa có cầu thủ nào.\nHãy thêm ở mục Bộ sưu tập.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                final result = viewModel.filterPlayers(
                  players,
                  keyword: _keyword,
                  role: widget.role,
                  onlyMatching: _onlyMatching,
                );
                if (result.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không có cầu thủ phù hợp',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: result.length,
                  itemBuilder: (context, index) {
                    final player = result[index];
                    final canPlay = canPlayRole(player, widget.role);
                    return ListTile(
                      leading: CircleAvatar(child: Text('${player.ovr}')),
                      title: Text(player.name),
                      subtitle: Text('${player.position} · ${player.club}'),
                      trailing: canPlay
                          ? null
                          : const Text(
                              'Lệch vị trí',
                              style: TextStyle(color: Colors.orange),
                            ),
                      onTap: () => _pickPlayer(player, canPlay),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPlayer(Player player, bool canPlay) async {
    final lineup = ref.read(c04ViewModelProvider(widget.lineupId)).value;
    if (lineup == null) return;

    // Cầu thủ đã đứng ở vị trí khác → hỏi có chuyển sang không
    String? currentSlot;
    lineup.slots.forEach((slotId, playerId) {
      if (playerId == player.id) currentSlot = slotId;
    });
    if (currentSlot != null && currentSlot != widget.slotId) {
      final confirmed = await showConfirmDialog(
        context,
        title: 'Chuyển vị trí?',
        message: '${player.name} đang ở $currentSlot. Chuyển sang ${widget.slotId}?',
      );
      if (!confirmed || !mounted) return;
    }

    // Không đúng vị trí → cảnh báo, vẫn cho chọn
    if (!canPlay) {
      final confirmed = await showConfirmDialog(
        context,
        title: 'Lệch vị trí',
        message: '${player.name} không đá ${widget.role}. Vẫn xếp vào?',
      );
      if (!confirmed || !mounted) return;
    }

    ref
        .read(c04ViewModelProvider(widget.lineupId).notifier)
        .setPlayer(widget.slotId, player.id);
    Navigator.pop(context);
  }
}
