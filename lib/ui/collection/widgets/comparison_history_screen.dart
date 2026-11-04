import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../comparison/view_models/a01_view_model.dart';
import '../../comparison/view_models/a04_view_model.dart';
import '../../comparison/widgets/a04_screen.dart';
import '../../../data/model/comparison_record.dart';
import '../view_models/collection_view_models.dart';

class ComparisonHistoryScreen extends ConsumerWidget {
  const ComparisonHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(collectionComparisonHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử so sánh')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Không tải được lịch sử: $error')),
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Text('Chưa có kết quả so sánh nào được lưu.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              final playerNames = _playerNames(record);
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE1F1E9),
                    foregroundColor: const Color(0xFF176B46),
                    child: const Icon(Icons.compare_arrows),
                  ),
                  title: Text(
                    playerNames.join('  vs  '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      'Đánh giá vị trí ${record.roleCode} · ${_formatDate(record.createdAt)}',
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Xóa lịch sử',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(collectionComparisonHistoryProvider.notifier)
                            .removeRecord(record.id),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => _openSavedComparison(context, ref, record),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  /// entries là snapshot do A04 lưu cùng bản ghi, nên tên vẫn hiển thị đúng
  /// ngay cả khi PlayerRepository đổi thứ tự danh sách.
  List<String> _playerNames(ComparisonRecord record) {
    final names = record.entries
        .map((entry) => (entry['name'] as String? ?? '').trim())
        .where((name) => name.isNotEmpty)
        .toList();

    return names.isNotEmpty ? names : record.playerIds;
  }

  /// Khôi phục dữ liệu đã lưu vào state dùng chung của phần A, sau đó mở
  /// A04. Nhờ vậy E04 chỉ là màn hình lịch sử, còn giao diện kết quả vẫn do A
  /// quản lý và không bị nhân bản.
  void _openSavedComparison(
    BuildContext context,
    WidgetRef ref,
    ComparisonRecord record,
  ) {
    ref.read(compareSelectionProvider.notifier).setSelection(record.playerIds);

    final config = ref.read(a04ConfigProvider.notifier);
    config.setPosition(record.roleCode);
    for (final weight in record.weights.entries) {
      config.setExactWeight(weight.key, weight.value);
    }

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const A04Screen()));
  }
}
