import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/formation.dart';
import '../../../routing/app_routes.dart';
import '../../core/themes/app_theme.dart';
import '../../core/widgets/state_views.dart';
import '../view_models/c02_view_model.dart';
import '../view_models/lineup_draft_view_model.dart';
import 'pitch_view.dart';

/// C02 — Chọn sơ đồ (KAN-48).
///
/// Hai sơ đồ MVP: 4-3-3 và 4-4-2. Đổi sơ đồ chỉ sửa bản nháp; nếu có cầu thủ
/// ở vị trí không còn trong sơ đồ mới thì phải xác nhận trước khi gỡ.
class C02Screen extends ConsumerWidget {
  const C02Screen({super.key, required this.lineupId, this.openPitchAfter = false});

  final String lineupId;

  /// Mở từ C01 (tạo mới / menu): xong thì sang C04. Mở từ C04: quay lại.
  final bool openPitchAfter;

  Future<void> _apply(BuildContext context, WidgetRef ref, C02State s) async {
    if (s.needsConfirm) {
      final removed = s.plan.removedSlots.keys;
      final ok = await confirmDialog(
        context,
        title: 'Đổi sang ${s.selected.name}?',
        message: '${removed.length} cầu thủ ở vị trí ${removed.join(', ')} sẽ bị gỡ vì sơ đồ mới '
            'không có vị trí này. Các vị trí trùng tên được giữ nguyên.',
        confirmText: 'Đổi sơ đồ',
        destructive: true,
      );
      if (!ok) return;
    }
    ref.read(c02ViewModelProvider(lineupId).notifier).apply();
    if (!context.mounted) return;
    if (openPitchAfter) {
      context.pushReplacement(AppRoutes.c04(lineupId));
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(c02StateProvider(lineupId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn sơ đồ')),
      body: AsyncValueView<C02State>(
        value: state,
        onRetry: () => ref.invalidate(lineupDraftViewModelProvider(lineupId)),
        data: (s) {
          final plan = s.plan;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Đội hình: ${s.draft.current.name}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final f in Formations.all)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _FormationOption(
                          formation: f,
                          selected: f.id == s.selected.id,
                          current: f.id == s.draft.current.formationId,
                          onTap: () => ref.read(c02ViewModelProvider(lineupId).notifier).select(f.id),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('${s.selected.name}: ${s.selected.slots.length} vị trí — '
                  '${s.selected.slots.map((x) => x.id).join(', ')}'),
              if (s.needsConfirm)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Cảnh báo: sẽ gỡ ${plan.removedSlots.length} cầu thủ ở ${plan.removedSlots.keys.join(', ')}.',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              const SizedBox(height: 16),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: PitchView(
                    formation: s.selected,
                    slotWidth: 56,
                    slotHeight: 48,
                    slotBuilder: (context, slot) {
                      final filled = s.isChange
                          ? plan.keptSlots.containsKey(slot.id)
                          : s.draft.current.slots.containsKey(slot.id);
                      return SlotChip(label: slot.role, caption: slot.id, filled: filled);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: state.hasValue
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AreaColors.lineup),
                  onPressed: () => _apply(context, ref, state.value!),
                  child: Text(openPitchAfter ? 'Tiếp tục xếp đội hình' : 'Áp dụng sơ đồ'),
                ),
              ),
            )
          : null,
    );
  }
}

class _FormationOption extends StatelessWidget {
  const _FormationOption({
    required this.formation,
    required this.selected,
    required this.current,
    required this.onTap,
  });

  final Formation formation;
  final bool selected;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? AreaColors.lineup : scheme.outlineVariant, width: selected ? 3 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(formation.name, style: Theme.of(context).textTheme.headlineSmall),
              Text('${formation.slots.length} vị trí'),
              if (current) const Text('Đang dùng', style: TextStyle(fontSize: 12)),
              if (selected) const Icon(Icons.check_circle, color: AreaColors.lineup),
            ],
          ),
        ),
      ),
    );
  }
}
