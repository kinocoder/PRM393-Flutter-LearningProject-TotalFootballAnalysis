import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/scoring_config.dart';
import '../../../routing/app_routes.dart';
import '../view_models/a01_view_model.dart';
import '../view_models/a04_view_model.dart';
import 'comparison_navigation_bar.dart';

/// Màn hình A04: Đánh giá kết quả so sánh theo tiêu chí vị trí (FR-A04, UC-07, BR-04, BR-10, MSG-07)
class A04Screen extends ConsumerWidget {
  const A04Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(a04ConfigProvider);
    final scoreResultsAsync = ref.watch(a04ScoreResultsProvider);
    final selectedIds = ref.watch(compareSelectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá theo tiêu chí'),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Thanh điều hướng Tab A01, A02, A03, A04
          const ComparisonNavigationBar(currentRoute: AppRoutes.a04),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Khung chọn vị trí tiêu chí
                  _buildPositionSelector(context, ref, config),

                  const SizedBox(height: 12),

                  // Khung điều chỉnh trọng số chỉ số (PAC, SHO, PAS, DRI, DEF, PHY)
                  _buildWeightAdjustmentPanel(context, ref, config),

                  const SizedBox(height: 16),

                  // Cảnh báo tổng trọng số chưa bằng 100% (MSG-07)
                  if (!config.isValid)
                    _buildTotalWeightWarning(context, config.totalWeight),

                  const SizedBox(height: 16),

                  // Danh sách kết quả xếp hạng và điểm số
                  const Text(
                    'Bảng điểm và Xếp hạng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  scoreResultsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Text('Lỗi khi tính điểm: $err'),
                    ),
                    data: (results) {
                      if (!config.isValid) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Chỉnh tổng trọng số về đúng 100% để hiển thị kết quả tính điểm.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      if (results.isEmpty) {
                        return const Center(
                          child: Text('Chưa có cầu thủ nào được chọn'),
                        );
                      }

                      return Column(
                        children: results.map((res) {
                          return _buildScoreResultCard(context, res);
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Thanh hành động dưới cùng: Nút Lưu kết quả vào lịch sử
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
                    Navigator.of(context).pushReplacementNamed(AppRoutes.a03);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Xem kỹ thuật'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: config.isValid && selectedIds.isNotEmpty
                        ? const Color(0xFF176B46)
                        : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: config.isValid && selectedIds.isNotEmpty
                      ? () async {
                          try {
                            final saveFn =
                                ref.read(saveComparisonResultProvider);
                            await saveFn();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Đã lưu kết quả so sánh vào lịch sử.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Không thể lưu: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Lưu kết quả'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dựng Dropdown chọn vị trí tiêu chí
  Widget _buildPositionSelector(
      BuildContext context, WidgetRef ref, ScoringConfig config) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn tiêu chí vị trí',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: config.positionCode,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              items: ScoringConfig.positionDisplayNames.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (posCode) {
                if (posCode != null) {
                  ref.read(a04ConfigProvider.notifier).setPosition(posCode);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Dựng bảng điều chỉnh slider trọng số của 6 chỉ số
  Widget _buildWeightAdjustmentPanel(
      BuildContext context, WidgetRef ref, ScoringConfig config) {
    final statKeys = ['PAC', 'SHO', 'PAS', 'DRI', 'DEF', 'PHY'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Điều chỉnh trọng số chỉ số',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF176B46),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: const Size(50, 30),
                      ),
                      onPressed: () {
                        ref
                            .read(a04ConfigProvider.notifier)
                            .resetToDefaults();
                      },
                      child: const Text('Mặc định', style: TextStyle(fontSize: 12)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF176B46),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: const Size(50, 30),
                      ),
                      onPressed: () {
                        ref
                            .read(a04ConfigProvider.notifier)
                            .normalizeWeights();
                      },
                      child: const Text('Chuẩn hóa 100%', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            ...statKeys.map((key) {
              final w = config.weights[key] ?? 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        '$key:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      color: const Color(0xFF176B46),
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: w > 0
                          ? () {
                              ref
                                  .read(a04ConfigProvider.notifier)
                                  .updateWeight(key, -1);
                            }
                          : null,
                    ),
                    Expanded(
                      child: Slider(
                        activeColor: const Color(0xFF176B46),
                        value: w.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 100, // Nấc 1%
                        label: '$w%',
                        onChanged: (val) {
                          ref
                              .read(a04ConfigProvider.notifier)
                              .setExactWeight(key, val.round());
                        },
                      ),
                    ),
                    IconButton(
                      color: const Color(0xFF176B46),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: w < 100
                          ? () {
                              ref
                                  .read(a04ConfigProvider.notifier)
                                  .updateWeight(key, 1);
                            }
                          : null,
                    ),
                    SizedBox(
                      width: 42,
                      child: Text(
                        '$w%',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// Dựng banner cảnh báo khi tổng trọng số khác 100% (MSG-07)
  Widget _buildTotalWeightWarning(BuildContext context, int totalWeight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tổng trọng số đang là $totalWeight%, cần đúng 100% mới tính điểm. Nút "Chuẩn hóa 100%" sẽ tự động chia lại.',
              style: TextStyle(color: Colors.red[900], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// Dựng thẻ kết quả điểm số và thứ hạng của từng cầu thủ
  Widget _buildScoreResultCard(BuildContext context, PlayerScoreResult res) {
    if (res.isUnranked) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: Colors.grey[100],
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.close, color: Colors.white, size: 20),
          ),
          title: Text(
            res.playerName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            res.unrankedReason ?? 'Không thể xếp hạng do thiếu dữ liệu',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          trailing: const Chip(
            label: Text('Không xếp hạng', style: TextStyle(fontSize: 11)),
            backgroundColor: Colors.grey,
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final isTop1 = res.rank == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isTop1 ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isTop1
            ? const BorderSide(color: Colors.amber, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTop1 ? Colors.amber : Colors.blueGrey,
          child: Text(
            '#${res.rank}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          res.playerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Điểm công thức: ${res.score?.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isTop1 ? Colors.amber[100] : Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            res.score?.toStringAsFixed(2) ?? '0.00',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isTop1 ? Colors.amber[900] : Colors.blue[900],
            ),
          ),
        ),
      ),
    );
  }
}
