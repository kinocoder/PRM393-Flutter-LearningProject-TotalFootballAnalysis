import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/formation.dart';
import '../../../data/model/lineup.dart';
import '../../../data/model/player.dart';
import '../view_models/c04_view_model.dart';
import 'c02_screen.dart';
import 'c03_screen.dart';
import 'pitch_view.dart';

/// C04 — Sân đội hình và lưu.
class C04Screen extends ConsumerWidget {
  final String lineupId;

  const C04Screen({super.key, required this.lineupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineupState = ref.watch(c04ViewModelProvider(lineupId));
    final viewModel = ref.read(c04ViewModelProvider(lineupId).notifier);
    final players = ref.watch(c04PlayersProvider).value ?? [];
    final ownedIds = ref.watch(c04OwnedIdsProvider).value;

    return lineupState.when(
      data: (lineup) => PopScope(
        // Còn thay đổi chưa lưu thì chặn nút Back để hỏi trước
        canPop: !viewModel.hasUnsavedChanges,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _askBeforeLeaving(context, viewModel);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(lineup.name),
            actions: [
              IconButton(
                tooltip: 'Đổi sơ đồ',
                icon: const Icon(Icons.grid_view),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => C02Screen(lineupId: lineupId),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Lưu',
                icon: const Icon(Icons.save),
                onPressed: viewModel.hasUnsavedChanges
                    ? () => _save(context, viewModel)
                    : null,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Sơ đồ ${lineup.formationId} · ${lineup.playerCount}/11 cầu thủ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              PitchView(
                formation: lineup.formation,
                slotBuilder: (slot) =>
                    _buildSlot(context, ref, lineup, slot, players, ownedIds),
              ),
            ],
          ),
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lỗi: $error'),
              TextButton(
                onPressed: () => ref.invalidate(c04ViewModelProvider(lineupId)),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlot(
    BuildContext context,
    WidgetRef ref,
    Lineup lineup,
    FormationSlot slot,
    List<Player> players,
    Set<String>? ownedIds,
  ) {
    final playerId = lineup.slots[slot.id];

    // Vị trí trống: chạm để chọn cầu thủ
    if (playerId == null) {
      return SlotChip(
        label: '+',
        caption: slot.id,
        onTap: () => _openC03(context, slot),
      );
    }

    Player? player;
    for (final p in players) {
      if (p.id == playerId) player = p;
    }
    final status = slotStatusOf(
      playerId: playerId,
      player: player,
      slot: slot,
      ownedIds: ownedIds,
    );

    return SlotChip(
      label: player == null ? '?' : '${player.ovr}',
      caption: player?.name ?? playerId,
      // Đỏ: không còn sở hữu; cam: lệch vị trí; trắng: bình thường
      color: switch (status) {
        SlotStatus.notOwned => Colors.red,
        SlotStatus.wrongPosition => Colors.orange,
        SlotStatus.ok => Colors.white,
      },
      onTap: () => _showSlotMenu(context, ref, slot, status),
    );
  }

  void _openC03(BuildContext context, FormationSlot slot) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => C03Screen(
          lineupId: lineupId,
          slot: slot,
        ),
      ),
    );
  }

  //Vị trí đã có người: chọn Thay cầu thủ hoặc Bỏ trống
  void _showSlotMenu(
    BuildContext context,
    WidgetRef ref,
    FormationSlot slot,
    SlotStatus status,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == SlotStatus.notOwned)
            const ListTile(
              leading: Icon(Icons.warning, color: Colors.red),
              title: Text('Cầu thủ này không còn trong bộ sưu tập'),
            ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Thay cầu thủ'),
            onTap: () {
              Navigator.pop(sheetContext);
              _openC03(context, slot);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_remove),
            title: const Text('Bỏ trống vị trí'),
            onTap: () {
              Navigator.pop(sheetContext);
              ref
                  .read(c04ViewModelProvider(lineupId).notifier)
                  .clearSlot(slot.id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context, C04ViewModel viewModel) async {
    final saved = await _trySave(context, viewModel);
    if (!saved || !context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu đội hình')));
  }

  //Lưu lỗi thì báo cho người dùng; bản đang sửa vẫn còn nguyên để lưu lại
  Future<bool> _trySave(BuildContext context, C04ViewModel viewModel) async {
    try {
      await viewModel.save();
      return true;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không lưu được đội hình, hãy thử lại')),
        );
      }
      return false;
    }
  }

  //Thoát khi chưa lưu: hỏi Lưu / Bỏ thay đổi / Ở lại
  Future<void> _askBeforeLeaving(
    BuildContext context,
    C04ViewModel viewModel,
  ) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chưa lưu đội hình'),
        content: const Text('Bạn có muốn lưu trước khi thoát không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'stay'),
            child: const Text('Ở lại'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('Bỏ thay đổi'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;

    if (choice == 'save') {
      final saved = await _trySave(context, viewModel);
      if (saved && context.mounted) Navigator.pop(context);
    } else if (choice == 'discard') {
      viewModel.discardChanges();
      Navigator.pop(context);
    }
  }
}
