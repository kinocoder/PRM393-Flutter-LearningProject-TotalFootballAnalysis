import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/player.dart';
import '../../../data/model/stat_row.dart';
import '../../../routing/app_routes.dart';
import '../view_models/a01_view_model.dart';
import '../view_models/a02_view_model.dart';
import 'comparison_navigation_bar.dart';

/// Màn hình A02: So sánh chỉ số cầu thủ (FR-A02, UC-06, BR-02, AC-A02)
class A02Screen extends ConsumerWidget {
  const A02Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonAsync = ref.watch(a02ViewModelProvider);
    final selectedIds = ref.watch(compareSelectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('So sánh chỉ số (A02)'),
        elevation: 1,
        actions: [
          IconButton(
            tooltip: 'Đổi danh sách lựa chọn',
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.a01);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh điều hướng Tab A01, A02, A03, A04
          const ComparisonNavigationBar(currentRoute: AppRoutes.a02),

          Expanded(
            child: comparisonAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi khi tải dữ liệu: $err'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(a02ViewModelProvider.notifier).refresh();
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              data: (data) {
                if (data.players.isEmpty) {
                  return _buildEmptyState(context);
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Khung tóm tắt thẻ cầu thủ ở trên cùng
                      _buildHeaderPlayerCards(context, data.players),

                      const SizedBox(height: 16),

                      // Bảng so sánh chỉ số chi tiết và độ chênh lệch Δ
                      _buildStatTable(context, data.players, data.statRows),
                    ],
                  ),
                );
              },
            ),
          ),

          // Thanh điều hướng thao tác dưới cùng
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
                    Navigator.of(context).pushReplacementNamed(AppRoutes.a01);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Thêm/Bỏ thẻ (A01)'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: selectedIds.length >= 2
                      ? () {
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.a03);
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Xem kỹ thuật (A03)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Giao diện khi chưa chọn đủ cầu thủ để so sánh
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.compare_arrows, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Chưa có đủ cầu thủ để so sánh',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng chọn từ 2 đến 3 cầu thủ tại màn hình A01.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.a01);
              },
              child: const Text('Quay lại chọn cầu thủ (A01)'),
            ),
          ],
        ),
      ),
    );
  }

  /// Dựng danh sách các thẻ cầu thủ tóm tắt ở đầu màn hình
  Widget _buildHeaderPlayerCards(BuildContext context, List<Player> players) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: players.map((p) {
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      '${p.ovr}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        p.position,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      p.cardVersion,
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.club,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Dựng bảng dữ liệu so sánh chỉ số cuộn ngang
  Widget _buildStatTable(
      BuildContext context, List<Player> players, List<StatRow> statRows) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bảng so sánh chỉ số tổng quát',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Chênh lệch Δ = Giá trị thẻ − Giá trị cao nhất của các thẻ còn lại. Dữ liệu thiếu hiện N/A, delta hiện — (BR-02).',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 52,
                columns: [
                  const DataColumn(
                    label: Text(
                      'Chỉ số',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...players.map(
                    (p) => DataColumn(
                      label: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${p.position} (${p.ovr})',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                rows: statRows.map((row) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          row.statName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      ...players.map((player) {
                        final val = row.playerValues[player.id];
                        final delta = row.deltas[player.id];
                        final isBest = row.bestPlayerIds.contains(player.id);

                        return DataCell(
                          _buildStatCell(val, delta, isBest),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dựng ô hiển thị giá trị chỉ số và độ chênh lệch (được làm nổi bật nếu có chỉ số cao nhất)
  Widget _buildStatCell(int? val, int? delta, bool isBest) {
    if (val == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'N/A (—)',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }

    String deltaStr = '—';
    Color deltaColor = Colors.grey;

    if (delta != null) {
      if (delta > 0) {
        deltaStr = '+$delta';
        deltaColor = Colors.green[700]!;
      } else if (delta < 0) {
        deltaStr = '$delta';
        deltaColor = Colors.red[700]!;
      } else {
        deltaStr = '0';
        deltaColor = Colors.blue[700]!;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isBest ? Colors.green.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isBest
            ? Border.all(color: Colors.green, width: 1)
            : Border.all(color: Colors.grey[300]!, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$val',
            style: TextStyle(
              fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: isBest ? Colors.green[900] : Colors.black87,
            ),
          ),
          Text(
            '($deltaStr)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: deltaColor,
            ),
          ),
        ],
      ),
    );
  }
}
