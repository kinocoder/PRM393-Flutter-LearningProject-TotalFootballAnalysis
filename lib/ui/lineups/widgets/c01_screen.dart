import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/providers/current_user_provider.dart';
import '../../../domain/models/lineup.dart';
import '../../../routing/app_routes.dart';
import '../../../utils/app_exception.dart';
import '../../../utils/formatters.dart';
import '../../core/themes/app_theme.dart';
import '../../core/widgets/state_views.dart';
import '../view_models/c01_view_model.dart';
import 'lineup_name_dialog.dart';

/// C01 — Danh sách đội hình (KAN-43).
///
/// Xem theo UID, tạo, mở, đổi tên, đổi sơ đồ, xoá có xác nhận + Hoàn tác.
/// SQLite là nguồn chính; đồng bộ Firestore chạy nền và không chặn giao diện.
class C01Screen extends ConsumerWidget {
  const C01Screen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final today = DateTime.now();
    final name = await askLineupName(
      context,
      title: 'Tạo đội hình mới',
      initial: 'Đội hình ${today.day}/${today.month}',
      confirmText: 'Tạo',
    );
    if (name == null || !context.mounted) return;
    try {
      final lineup = await ref.read(c01ViewModelProvider.notifier).create(name);
      if (context.mounted) context.push(AppRoutes.c02(lineup.id, openPitchAfter: true));
    } catch (e) {
      if (context.mounted) showMessage(context, describeError(e));
    }
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Lineup lineup) async {
    final name = await askLineupName(context, title: 'Đổi tên đội hình', initial: lineup.name);
    if (name == null || name == lineup.name) return;
    try {
      await ref.read(c01ViewModelProvider.notifier).rename(lineup, name);
    } catch (e) {
      if (context.mounted) showMessage(context, describeError(e));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Lineup lineup) async {
    final ok = await confirmDialog(
      context,
      title: 'Xoá đội hình?',
      message: 'Xoá "${lineup.name}"? Bạn có thể hoàn tác ngay sau khi xoá.',
      confirmText: 'Xoá',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final viewModel = ref.read(c01ViewModelProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await viewModel.delete(lineup);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Đã xoá "${lineup.name}"'),
          action: SnackBarAction(label: 'Hoàn tác', onPressed: () => viewModel.restore(lineup)),
        ));
    } catch (e) {
      if (context.mounted) showMessage(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineups = ref.watch(c01ViewModelProvider);
    final sync = ref.watch(lineupSyncProvider);
    final syncResult = sync.valueOrNull;
    final signedIn = ref.watch(currentUidProvider) != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đội hình của tôi'),
        actions: [
          if (syncResult?.enabled ?? false)
            IconButton(
              tooltip: 'Đồng bộ',
              onPressed: sync.isLoading ? null : () => ref.invalidate(lineupSyncProvider),
              icon: sync.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(syncResult!.ok ? Icons.cloud_done_outlined : Icons.cloud_off_outlined),
            ),
        ],
      ),
      floatingActionButton: signedIn
          ? FloatingActionButton.extended(
              backgroundColor: AreaColors.lineup,
              foregroundColor: Colors.white,
              onPressed: () => _create(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Tạo đội hình'),
            )
          : null,
      body: Column(
        children: [
          if (syncResult != null && syncResult.enabled && !syncResult.ok)
            MaterialBanner(
              leading: const Icon(Icons.cloud_off_outlined),
              content: const Text('Chưa đồng bộ được với máy chủ. Dữ liệu vẫn lưu trên máy và sẽ đồng bộ sau.'),
              actions: [
                TextButton(onPressed: () => ref.invalidate(lineupSyncProvider), child: const Text('Thử lại')),
              ],
            ),
          Expanded(
            child: !signedIn
                ? const EmptyView(
                    icon: Icons.lock_outline,
                    title: 'Bạn cần đăng nhập',
                    message: 'Đội hình được lưu riêng theo tài khoản.',
                  )
                : AsyncValueView<List<Lineup>>(
                    value: lineups,
                    onRetry: () => ref.invalidate(c01ViewModelProvider),
                    isEmpty: (l) => l.isEmpty,
                    empty: EmptyView(
                      icon: Icons.stadium_outlined,
                      title: 'Chưa có đội hình nào',
                      message: 'Tạo đội hình 4-3-3 hoặc 4-4-2 từ các thẻ bạn sở hữu.',
                      action: FilledButton.icon(
                        onPressed: () => _create(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('Tạo đội hình đầu tiên'),
                      ),
                    ),
                    data: (list) => RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(lineupSyncProvider);
                        await ref.read(lineupSyncProvider.future);
                        await ref.read(c01ViewModelProvider.notifier).reload();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) => _LineupTile(
                          lineup: list[i],
                          onOpen: () => context.push(AppRoutes.c04(list[i].id)),
                          onFormation: () => context.push(AppRoutes.c02(list[i].id, openPitchAfter: true)),
                          onRename: () => _rename(context, ref, list[i]),
                          onDelete: () => _delete(context, ref, list[i]),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LineupTile extends StatelessWidget {
  const _LineupTile({
    required this.lineup,
    required this.onOpen,
    required this.onFormation,
    required this.onRename,
    required this.onDelete,
  });

  final Lineup lineup;
  final VoidCallback onOpen;
  final VoidCallback onFormation;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AreaColors.lineup,
        foregroundColor: Colors.white,
        child: Text(lineup.formationId.replaceAll('-', ''), style: const TextStyle(fontSize: 12)),
      ),
      title: Text(lineup.name),
      subtitle: Text(
        '${lineup.formationId} · ${lineup.filledCount}/${lineup.formation.slots.length} vị trí · '
        'sửa ${formatDateTime(lineup.updatedAt)}',
      ),
      onTap: onOpen,
      trailing: PopupMenuButton<String>(
        tooltip: 'Thêm thao tác',
        onSelected: (v) {
          switch (v) {
            case 'open':
              onOpen();
            case 'formation':
              onFormation();
            case 'rename':
              onRename();
            case 'delete':
              onDelete();
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'open', child: Text('Mở sân đội hình')),
          PopupMenuItem(value: 'formation', child: Text('Đổi sơ đồ')),
          PopupMenuItem(value: 'rename', child: Text('Đổi tên')),
          PopupMenuItem(value: 'delete', child: Text('Xoá')),
        ],
      ),
    );
  }
}
