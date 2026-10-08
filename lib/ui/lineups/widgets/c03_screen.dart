import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/app_exception.dart';
import '../../core/themes/app_theme.dart';
import '../../core/widgets/state_views.dart';
import '../view_models/c03_view_model.dart';
import '../view_models/lineup_draft_view_model.dart';
import 'lineup_player_tile.dart';

/// C03 — Chọn cầu thủ cho vị trí (KAN-58).
///
/// Nhận slot từ C04; ứng viên lấy từ bộ sưu tập (E01). Một cầu thủ không ở
/// hai slot: chọn người đang ở slot khác thì hỏi chuyển. Lệch vị trí thì cảnh
/// báo nhưng vẫn cho xếp.
class C03Screen extends ConsumerWidget {
  const C03Screen({super.key, required this.lineupId, required this.slotId});

  final String lineupId;
  final String slotId;

  SlotArgs get _args => (lineupId: lineupId, slotId: slotId);

  Future<void> _pick(BuildContext context, WidgetRef ref, C03State s, SlotCandidate c) async {
    final viewModel = ref.read(c03ViewModelProvider(_args).notifier);
    final slot = s.slot!;
    for (final check in viewModel.checksFor(c)) {
      final ok = switch (check) {
        PickCheck.movesFromOtherSlot => await confirmDialog(
            context,
            title: 'Chuyển vị trí?',
            message: '${c.player.name} đang ở ${c.currentSlot}. Chuyển sang ${slot.id}? '
                '(${c.currentSlot} sẽ bị bỏ trống)',
            confirmText: 'Chuyển',
          ),
        PickCheck.wrongPosition => await confirmDialog(
            context,
            title: 'Lệch vị trí',
            message: '${c.player.name} (${c.player.playablePositions.join('/')}) không chơi vị trí '
                '${slot.role}. Vẫn xếp vào ${slot.id}?',
            confirmText: 'Vẫn xếp',
          ),
        PickCheck.ok => true,
      };
      if (!ok || !context.mounted) return;
    }
    viewModel.assign(c.player.id);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(c03StateProvider(_args));
    final filter = ref.watch(c03ViewModelProvider(_args));
    final viewModel = ref.read(c03ViewModelProvider(_args).notifier);

    return Scaffold(
      appBar: AppBar(title: Text('Chọn cầu thủ · $slotId')),
      body: AsyncValueView<C03State>(
        value: stateAsync,
        onRetry: () {
          ref.invalidate(lineupDraftViewModelProvider(lineupId));
          ref.invalidate(ownedPlayerIdsProvider);
        },
        data: (s) {
          final slot = s.slot;
          if (slot == null) {
            return EmptyView(
              icon: Icons.error_outline,
              title: 'Vị trí $slotId không có trong sơ đồ ${s.lineup.formationId}',
              action: OutlinedButton(onPressed: () => context.pop(), child: const Text('Quay lại sân')),
            );
          }
          if (s.ownedCount == 0) {
            return EmptyView(
              icon: Icons.style_outlined,
              title: 'Bộ sưu tập đang trống',
              message: 'Thêm thẻ bạn sở hữu (màn E02) trước khi xếp đội hình.',
              action: kDebugMode
                  ? OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await viewModel.seedSampleOwned();
                        } catch (e) {
                          if (context.mounted) showMessage(context, describeError(e));
                        }
                      },
                      icon: const Icon(Icons.science_outlined),
                      label: const Text('Thêm thẻ mẫu để thử (bản debug)'),
                    )
                  : null,
            );
          }
          return Column(
            children: [
              ListTile(
                title: Text('Vị trí ${slot.id} · cần ${slot.acceptedPositions.join('/')}'),
                subtitle: Text(s.assignedPlayerId == null ? 'Đang trống' : 'Đang có cầu thủ'),
                trailing: s.assignedPlayerId == null
                    ? null
                    : TextButton(
                        onPressed: () {
                          viewModel.clearSlot();
                          context.pop();
                        },
                        child: const Text('Bỏ trống'),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  onChanged: viewModel.setQuery,
                  decoration: const InputDecoration(
                    hintText: 'Tìm trong bộ sưu tập',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Chỉ hiện cầu thủ đúng vị trí'),
                value: filter.onlyFitting,
                onChanged: viewModel.setOnlyFitting,
              ),
              Expanded(
                child: s.candidates.isEmpty
                    ? EmptyView(
                        icon: Icons.person_search,
                        title: 'Không có cầu thủ phù hợp',
                        message: filter.onlyFitting ? 'Tắt "Chỉ hiện cầu thủ đúng vị trí" để xem tất cả.' : null,
                      )
                    : ListView.separated(
                        itemCount: s.candidates.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final c = s.candidates[i];
                          final here = c.currentSlot == slot.id;
                          return LineupPlayerTile(
                            player: c.player,
                            selected: here,
                            subtitle: [
                              if (c.rating != null) 'Điểm vị trí ${slot.role}: ${c.rating}',
                              if (!c.fits) 'Lệch vị trí (${c.player.playablePositions.join('/')})',
                              if (c.currentSlot != null && !here) 'Đang ở ${c.currentSlot}',
                              if (here) 'Đang ở vị trí này',
                            ].join(' · '),
                            trailing: Icon(
                              here
                                  ? Icons.check_circle
                                  : c.fits
                                      ? Icons.add_circle_outline
                                      : Icons.warning_amber,
                              color: here ? AreaColors.lineup : (c.fits ? null : Colors.amber.shade700),
                            ),
                            onTap: here ? null : () => _pick(context, ref, s, c),
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
}
