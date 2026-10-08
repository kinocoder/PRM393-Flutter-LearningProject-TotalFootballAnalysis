import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/formation.dart';
import '../../../domain/models/player.dart';
import '../../../routing/app_routes.dart';
import '../../../utils/app_exception.dart';
import '../../core/themes/app_theme.dart';
import '../../core/widgets/state_views.dart';
import '../view_models/c04_view_model.dart';
import '../view_models/lineup_draft_view_model.dart';
import 'lineup_name_dialog.dart';
import 'pitch_view.dart';

/// C04 — Sân đội hình và lưu (KAN-53).
///
/// Chạm slot trống → C03. Chạm slot có người → thay / xem / bỏ trống. Đặt tên
/// và lưu (SQLite, đồng bộ Firestore nếu có mạng). Thoát khi chưa lưu thì hỏi.
class C04Screen extends ConsumerStatefulWidget {
  const C04Screen({super.key, required this.lineupId});

  final String lineupId;

  @override
  ConsumerState<C04Screen> createState() => _C04ScreenState();
}

class _C04ScreenState extends ConsumerState<C04Screen> {
  bool _saving = false;
  bool _leaving = false;

  LineupDraftViewModel get _viewModel => ref.read(lineupDraftViewModelProvider(widget.lineupId).notifier);

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _viewModel.save();
      if (mounted) showMessage(context, 'Đã lưu đội hình.');
    } catch (e) {
      if (mounted) showMessage(context, describeError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _rename(LineupDraft draft) async {
    final name = await askLineupName(context, title: 'Đổi tên đội hình', initial: draft.current.name);
    if (name != null) _viewModel.rename(name);
  }

  Future<void> _onExitAttempt() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đội hình chưa lưu'),
        content: const Text('Bạn có muốn lưu thay đổi trước khi thoát?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop('stay'), child: const Text('Ở lại')),
          TextButton(onPressed: () => Navigator.of(context).pop('discard'), child: const Text('Bỏ thay đổi')),
          FilledButton(onPressed: () => Navigator.of(context).pop('save'), child: const Text('Lưu')),
        ],
      ),
    );
    if (!mounted || choice == null || choice == 'stay') return;
    if (choice == 'save') {
      await _save();
      final stillDirty = ref.read(lineupDraftViewModelProvider(widget.lineupId)).valueOrNull?.isDirty ?? false;
      if (stillDirty) return; // lưu lỗi: ở lại
    } else {
      _viewModel.discard();
    }
    if (!mounted) return;
    setState(() => _leaving = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  Future<void> _onSlotTap(FormationSlot slot, Player? player, String? playerId) async {
    if (playerId == null) {
      context.push(AppRoutes.c03(widget.lineupId, slot.id));
      return;
    }
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('${slot.id}: ${player?.name ?? playerId}'), subtitle: const Text('Chọn thao tác')),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Thay cầu thủ khác'),
              onTap: () => Navigator.of(context).pop('replace'),
            ),
            ListTile(
              leading: const Icon(Icons.person_remove_outlined),
              title: const Text('Bỏ trống vị trí'),
              onTap: () => Navigator.of(context).pop('clear'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case 'replace':
        context.push(AppRoutes.c03(widget.lineupId, slot.id));
      case 'clear':
        _viewModel.clearSlot(slot.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(c04StateProvider(widget.lineupId));
    final s = stateAsync.valueOrNull;
    final dirty = s?.draft.isDirty ?? false;

    return PopScope(
      canPop: _leaving || !dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onExitAttempt();
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: s == null ? null : () => _rename(s.draft),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(s?.draft.current.name ?? 'Đội hình', overflow: TextOverflow.ellipsis)),
                if (s != null)
                  const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.edit, size: 16)),
              ],
            ),
          ),
          actions: [
            if (s != null)
              TextButton.icon(
                onPressed: () => context.push(AppRoutes.c02(widget.lineupId)),
                icon: const Icon(Icons.grid_view),
                label: Text(s.draft.current.formationId),
              ),
          ],
        ),
        body: AsyncValueView<C04State>(
          value: stateAsync,
          onRetry: () => ref.invalidate(lineupDraftViewModelProvider(widget.lineupId)),
          data: (state) => _PitchBody(
            state: state,
            onSlotTap: _onSlotTap,
            onRemoveUnowned: _viewModel.removePlayers,
          ),
        ),
        bottomNavigationBar: s == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dirty ? 'Có thay đổi chưa lưu' : 'Đã lưu',
                          style: TextStyle(color: dirty ? Theme.of(context).colorScheme.error : null),
                        ),
                      ),
                      if (dirty) TextButton(onPressed: _viewModel.discard, child: const Text('Hoàn tác')),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: AreaColors.lineup),
                        onPressed: dirty && !_saving ? _save : null,
                        icon: _saving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save_outlined),
                        label: const Text('Lưu'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _PitchBody extends StatelessWidget {
  const _PitchBody({required this.state, required this.onSlotTap, required this.onRemoveUnowned});

  final C04State state;
  final void Function(FormationSlot slot, Player? player, String? playerId) onSlotTap;
  final void Function(Set<String> ids) onRemoveUnowned;

  @override
  Widget build(BuildContext context) {
    final lineup = state.draft.current;
    final formation = lineup.formation;
    final warnings = state.warnings;

    return LayoutBuilder(
      builder: (context, constraints) {
        final landscape = constraints.maxWidth > constraints.maxHeight;
        final pitch = PitchView(
          formation: formation,
          slotBuilder: (context, slot) {
            final pid = lineup.slots[slot.id];
            final player = pid == null ? null : state.players[pid];
            return SlotChip(
              filled: pid != null,
              label: player == null ? (pid == null ? '' : '?') : '${player.ovr ?? '?'}',
              caption: player?.name ?? (pid == null ? slot.id : 'Thẻ $pid'),
              warning: warnings.mismatchedSlots.contains(slot.id),
              error: pid != null && warnings.unownedPlayerIds.contains(pid),
              onTap: () => onSlotTap(slot, player, pid),
            );
          },
        );

        final info = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${lineup.filledCount}/${formation.slots.length} vị trí đã có cầu thủ',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            const Text('Chạm vị trí để chọn/thay cầu thủ.'),
            if (warnings.mismatchedSlots.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Lệch vị trí (vàng): ${warnings.mismatchedSlots.join(', ')}',
                  style: TextStyle(color: Colors.amber.shade800),
                ),
              ),
            if (warnings.unownedPlayerIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${warnings.unownedPlayerIds.length} cầu thủ không còn trong bộ sưu tập (đỏ).',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                    TextButton(
                      onPressed: () => onRemoveUnowned(warnings.unownedPlayerIds),
                      child: const Text('Gỡ'),
                    ),
                  ],
                ),
              ),
          ],
        );

        if (landscape) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(height: constraints.maxHeight - 24, child: pitch),
              ),
              Expanded(child: Padding(padding: const EdgeInsets.all(16), child: info)),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [info, const SizedBox(height: 12), pitch],
        );
      },
    );
  }
}
