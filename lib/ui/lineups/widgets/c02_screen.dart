import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/formation.dart';
import '../view_models/c04_view_model.dart';
import 'pitch_view.dart';

/// C02 — Chọn sơ đồ (mở từ nút "Đổi sơ đồ" ở C04).
/// Chọn thử thoải mái; chỉ khi bấm "Áp dụng" mới đổi đội hình.
class C02Screen extends ConsumerStatefulWidget {
  final String lineupId;

  const C02Screen({super.key, required this.lineupId});

  @override
  ConsumerState<C02Screen> createState() => _C02ScreenState();
}

class _C02ScreenState extends ConsumerState<C02Screen> {
  // Sơ đồ đang chọn thử (null = chưa chọn, đang xem sơ đồ hiện tại)
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final lineupState = ref.watch(c04ViewModelProvider(widget.lineupId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn sơ đồ')),
      body: lineupState.when(
        data: (lineup) {
          final selected = Formations.byId(_selectedId ?? lineup.formationId);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hai nút chọn sơ đồ
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final formation in Formations.all)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ChoiceChip(
                        label: Text(formation.id),
                        selected: formation.id == selected.id,
                        onSelected: (_) {
                          setState(() => _selectedId = formation.id);
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Xem trước các vị trí của sơ đồ đang chọn
              PitchView(
                formation: selected,
                slotBuilder: (slot) => SlotChip(
                  label: slot.role,
                  caption: slot.id,
                  color: lineup.slots.containsKey(slot.id)
                      ? Colors.white
                      : Colors.white24,
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () => _apply(selected.id),
                child: const Text('Áp dụng'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  Future<void> _apply(String formationId) async {
    final viewModel = ref.read(c04ViewModelProvider(widget.lineupId).notifier);

    // Đổi sơ đồ mà có cầu thủ bị gỡ thì phải hỏi lại
    final removed = viewModel.slotsRemovedBy(formationId);
    if (removed.isNotEmpty) {
      final confirmed = await showConfirmDialog(
        context,
        title: 'Đổi sơ đồ?',
        message: 'Cầu thủ ở vị trí ${removed.join(', ')} sẽ bị bỏ ra.',
      );
      if (!confirmed) return;
    }

    viewModel.changeFormation(formationId);
    if (!mounted) return;
    Navigator.pop(context);
  }
}
