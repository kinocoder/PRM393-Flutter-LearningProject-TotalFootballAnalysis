import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/lineup.dart';
import '../view_models/c01_view_model.dart';
import 'c04_screen.dart';
import 'pitch_view.dart';

/// C01 — Danh sách đội hình.
class C01Screen extends ConsumerWidget {
  const C01Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineupsState = ref.watch(c01ViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Đội hình của tôi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createLineup(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tạo đội hình'),
      ),
      body: lineupsState.when(
        data: (lineups) {
          if (lineups.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có đội hình nào',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            itemCount: lineups.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final lineup = lineups[index];
              return ListTile(
                leading: const Icon(Icons.groups),
                title: Text(
                  lineup.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${lineup.formationId} · ${lineup.playerCount}/11 cầu thủ',
                ),
                // Mở sân đội hình (C04)
                onTap: () => _openC04(context, lineup.id),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'rename') _renameLineup(context, ref, lineup);
                    if (value == 'delete') _deleteLineup(context, ref, lineup);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'rename', child: Text('Đổi tên')),
                    PopupMenuItem(value: 'delete', child: Text('Xoá')),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lỗi tải dữ liệu: $error',
                style: const TextStyle(color: Colors.red),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(c01ViewModelProvider.notifier).refresh(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Tạo đội hình rồi mở luôn sân (C04)
  Future<void> _createLineup(BuildContext context, WidgetRef ref) async {
    final name = await _askName(context, ref, '');
    if (name == null) return;

    try {
      final lineup = await ref
          .read(c01ViewModelProvider.notifier)
          .createLineup(name);
      if (!context.mounted) return;
      _openC04(context, lineup.id);
    } catch (_) {
      if (context.mounted) _showError(context, 'Không tạo được đội hình');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openC04(BuildContext context, String lineupId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => C04Screen(lineupId: lineupId)),
    );
  }

  Future<void> _renameLineup(
    BuildContext context,
    WidgetRef ref,
    Lineup lineup,
  ) async {
    final name = await _askName(context, ref, lineup.name);
    if (name == null) return;
    try {
      await ref.read(c01ViewModelProvider.notifier).renameLineup(lineup, name);
    } catch (_) {
      if (context.mounted) _showError(context, 'Không đổi được tên đội hình');
    }
  }

  //Xoá phải hỏi lại; bấm Huỷ thì giữ nguyên
  Future<void> _deleteLineup(
    BuildContext context,
    WidgetRef ref,
    Lineup lineup,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xoá đội hình?',
      message: 'Đội hình "${lineup.name}" sẽ bị xoá.',
    );
    if (!confirmed) return;
    try {
      await ref.read(c01ViewModelProvider.notifier).deleteLineup(lineup);
    } catch (_) {
      if (context.mounted) _showError(context, 'Không xoá được đội hình');
    }
  }

  //Hộp thoại nhập tên; trả về null nếu bấm Huỷ
  Future<String?> _askName(
    BuildContext context,
    WidgetRef ref,
    String initialName,
  ) {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: initialName);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tên đội hình'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            validator: ref.read(c01ViewModelProvider.notifier).validateName,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              final isValid = formKey.currentState?.validate() ?? false;
              if (!isValid) return;
              Navigator.pop(context, controller.text);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
