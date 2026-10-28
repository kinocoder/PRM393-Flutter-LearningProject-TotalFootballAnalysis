import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/player.dart';
import '../../../data/repositories/player_repository.dart';
import '../../../routing/app_routes.dart';
import '../view_models/a01_view_model.dart';
import 'comparison_navigation_bar.dart';

/// Màn hình A01: Chọn cầu thủ so sánh (FR-A01, UC-06, BR-01, AC-A01)
class A01Screen extends ConsumerStatefulWidget {
  const A01Screen({super.key});

  @override
  ConsumerState<A01Screen> createState() => _A01ScreenState();
}

class _A01ScreenState extends ConsumerState<A01Screen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Đọc danh sách các playerId đang được chọn từ compareSelectionProvider
    final selectedIds = ref.watch(compareSelectionProvider);
    final candidateAsync = ref.watch(a01CandidatePlayersProvider);
    final canContinue = ref.watch(compareSelectionProvider.notifier).canContinue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('So sánh cầu thủ (A01)'),
        elevation: 1,
        actions: [
          if (selectedIds.isNotEmpty)
            IconButton(
              tooltip: 'Xóa toàn bộ lựa chọn',
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref.read(compareSelectionProvider.notifier).clear();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Thanh điều hướng Tab A01, A02, A03, A04
          const ComparisonNavigationBar(currentRoute: AppRoutes.a01),

          // Ô nhập từ khóa tìm kiếm ứng viên
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, câu lạc bộ, vị trí...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(a01SearchQueryProvider.notifier).setQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (val) {
                setState(() {});
                // Cập nhật từ khóa tìm kiếm vào Provider
                ref.read(a01SearchQueryProvider.notifier).setQuery(val);
              },
            ),
          ),

          // Thanh hiển thị các cầu thủ đang được chọn ở trên cùng
          _buildSelectedPlayersHeader(context, selectedIds),

          const Divider(height: 1),

          // Danh sách ứng viên cầu thủ tìm kiếm
          Expanded(
            child: candidateAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Đã xảy ra lỗi: $err'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(a01CandidatePlayersProvider),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              data: (candidates) {
                if (candidates.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy cầu thủ phù hợp',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: candidates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final player = candidates[index];
                    final isSelected = selectedIds.contains(player.id);

                    return _buildPlayerTile(context, player, isSelected);
                  },
                );
              },
            ),
          ),

          // Thanh hành động dưới cùng
          _buildBottomBar(context, selectedIds, canContinue),
        ],
      ),
    );
  }

  /// Dựng widget danh sách tóm tắt thẻ cầu thủ đã chọn
  Widget _buildSelectedPlayersHeader(
      BuildContext context, List<String> selectedIds) {
    if (selectedIds.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.amber.withOpacity(0.1),
        child: const Text(
          'Vui lòng chọn từ 2 đến 3 cầu thủ để bắt đầu so sánh (MSG-06).',
          style: TextStyle(fontSize: 13, color: Colors.amber),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã chọn (${selectedIds.length}/3 thẻ)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (selectedIds.length < 2)
                Text(
                  'Chọn thêm ${2 - selectedIds.length} thẻ nữa',
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
            ],
          ),
          const SizedBox(height: 6),
          FutureBuilder<List<Player>>(
            future: _getPlayersByIds(selectedIds),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }

              final players = snapshot.data!;
              return Wrap(
                spacing: 8,
                runSpacing: 6,
                children: players.map((player) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        player.position,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    label: Text(
                      '${player.name} (${player.ovr})',
                      style: const TextStyle(fontSize: 13),
                    ),
                    deleteIcon: const Icon(Icons.cancel, size: 18),
                    onDeleted: () {
                      ref
                          .read(compareSelectionProvider.notifier)
                          .remove(player.id);
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Dựng widget từng dòng cầu thủ ứng viên trong danh sách
  Widget _buildPlayerTile(
      BuildContext context, Player player, bool isSelected) {
    return Card(
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blueGrey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${player.ovr}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                player.position,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          player.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${player.cardVersion} · ${player.club} · ${player.nation}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Colors.red[700]
                : Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (isSelected) {
              ref.read(compareSelectionProvider.notifier).remove(player.id);
            } else {
              final result =
                  ref.read(compareSelectionProvider.notifier).add(player.id);
              if (result == CompareAddResult.full) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Tối đa 3 cầu thủ. Vui lòng bỏ chọn một cầu thủ trước (MSG-06).'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          child: Text(isSelected ? 'Bỏ chọn' : 'Chọn'),
        ),
      ),
    );
  }

  /// Dựng thanh nút bấm dưới cùng để chuyển sang A02
  Widget _buildBottomBar(
      BuildContext context, List<String> selectedIds, bool canContinue) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Đã chọn ${selectedIds.length}/3',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  canContinue
                      ? 'Đủ điều kiện so sánh (A02, A03, A04)'
                      : 'Cần chọn ít nhất 2 cầu thủ',
                  style: TextStyle(
                    fontSize: 12,
                    color: canContinue ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor:
                  canContinue ? Theme.of(context).primaryColor : Colors.grey,
              foregroundColor: Colors.white,
            ),
            onPressed: canContinue
                ? () {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.a02);
                  }
                : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('So sánh chỉ số (A02)'),
          ),
        ],
      ),
    );
  }

  /// Hàm hỗ trợ tải thông tin chi tiết danh sách cầu thủ theo IDs
  Future<List<Player>> _getPlayersByIds(List<String> ids) async {
    final repo = ref.read(playerRepositoryProvider);
    final List<Player> result = [];
    for (final id in ids) {
      final p = await repo.getPlayerByID(id);
      if (p != null) result.add(p);
    }
    return result;
  }
}
