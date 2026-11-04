import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/player.dart';
import '../../../data/model/skill_comparison.dart';
import '../../../routing/app_routes.dart';
import '../view_models/a03_view_model.dart';
import 'comparison_navigation_bar.dart';

/// Màn hình A03: So sánh kỹ thuật đặc biệt (FR-A03, UC-06, BR-03, AC-A03)
class A03Screen extends ConsumerWidget {
  const A03Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(a03ViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('So sánh kỹ thuật'),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Thanh điều hướng Tab A01, A02, A03, A04
          const ComparisonNavigationBar(currentRoute: AppRoutes.a03),

          Expanded(
            child: stateAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Đã xảy ra lỗi: $err'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(a03ViewModelProvider),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              data: (data) {
                final comp = data.skillComparison;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chú thích các biểu tượng trạng thái sở hữu
                      _buildLegendCard(context),

                      const SizedBox(height: 12),

                      // Nhóm 1: Kỹ thuật chung
                      _buildSectionHeader(
                        context,
                        title: 'Kỹ thuật chung',
                        count: comp.commonSkills.length,
                        subtitle:
                            'Kỹ thuật mà tất cả các cầu thủ đã có dữ liệu đều sở hữu',
                        icon: Icons.verified_outlined,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildSkillList(
                        context,
                        items: comp.commonSkills,
                        players: data.players,
                        emptyMessage: 'Không có kỹ thuật chung nào',
                      ),

                      const SizedBox(height: 20),

                      // Nhóm 2: Kỹ thuật riêng
                      _buildSectionHeader(
                        context,
                        title: 'Kỹ thuật riêng',
                        count: comp.uniqueSkills.length,
                        subtitle: 'Kỹ thuật chỉ một số cầu thủ sở hữu',
                        icon: Icons.stars_outlined,
                        color: Colors.amber[800]!,
                      ),
                      const SizedBox(height: 8),
                      _buildSkillList(
                        context,
                        items: comp.uniqueSkills,
                        players: data.players,
                        emptyMessage: 'Không có kỹ thuật riêng nào',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Thanh nút chuyển màn hình dưới cùng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.a02);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Xem chỉ số'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF176B46),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.a04);
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Đánh giá'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  /// Chú thích các trạng thái dữ liệu kỹ thuật
  Widget _buildLegendCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 4),
              Text('Sở hữu', style: TextStyle(fontSize: 12)),
            ],
          ),
          Row(
            children: [
              Icon(Icons.cancel, color: Colors.red, size: 16),
              SizedBox(width: 4),
              Text('Không sở hữu (—)', style: TextStyle(fontSize: 12)),
            ],
          ),
          Row(
            children: [
              Icon(Icons.help_outline, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text('Chưa có dữ liệu (?)', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  /// Dựng tiêu đề từng phần kỹ thuật
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          '$title ($count)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Dựng danh sách các thẻ kỹ thuật
  Widget _buildSkillList(
    BuildContext context, {
    required List<SkillComparisonItem> items,
    required List<Player> players,
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 1,
          child: ExpansionTile(
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.skillName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (item.hasDuplicateName) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ID: ${item.skillId}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (item.type != null && item.type!.isNotEmpty)
                        Text(
                          'Loại: ${item.type}',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: players.map((player) {
                  final status =
                      item.playerStatuses[player.id] ?? SkillDataStatus.unknown;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getBgColorForStatus(status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: [
                          Text(
                            player.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          _buildStatusIcon(status),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mô tả kỹ thuật:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description.isNotEmpty
                            ? item.description
                            : 'Không có mô tả chi tiết',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getBgColorForStatus(SkillDataStatus status) {
    switch (status) {
      case SkillDataStatus.owned:
        return Colors.green.withOpacity(0.15);
      case SkillDataStatus.notOwned:
        return Colors.red.withOpacity(0.1);
      case SkillDataStatus.unknown:
        return Colors.amber.withOpacity(0.15);
    }
  }

  Widget _buildStatusIcon(SkillDataStatus status) {
    switch (status) {
      case SkillDataStatus.owned:
        return const Icon(Icons.check_circle, color: Colors.green, size: 16);
      case SkillDataStatus.notOwned:
        return const Icon(Icons.cancel, color: Colors.red, size: 16);
      case SkillDataStatus.unknown:
        return const Icon(Icons.help_outline, color: Colors.amber, size: 16);
    }
  }
}
