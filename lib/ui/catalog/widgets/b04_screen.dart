import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/player.dart';
import '../../../data/repositories/collection_repository.dart';
import '../../../data/repositories/current_user_provider.dart';
import '../../../routing/app_routes.dart';
import '../../collection/view_models/collection_view_models.dart';
import '../../collection/widgets/add_player_to_collection_screen.dart';
import '../view_models/b04_view_model.dart';

class B04Screen extends ConsumerWidget {
  final String playerId;

  const B04Screen({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(b04ViewModelProvider(playerId));
    final favoritesAsync = ref.watch(favoritePlayerIdsProvider);
    final isFavorite = favoritesAsync.value?.contains(playerId) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Cầu Thủ'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            tooltip: isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
            onPressed: () async {
              final repository = ref.read(collectionRepositoryProvider);
              final currentUid = ref.read(currentUidProvider);
              final newFavoriteState = !isFavorite;

              await repository.setFavorite(
                uid: currentUid,
                playerId: playerId,
                isFavorite: newFavoriteState,
              );
              ref.invalidate(favoritePlayerIdsProvider);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      newFavoriteState
                          ? 'Đã thêm vào danh sách yêu thích'
                          : 'Đã bỏ khỏi danh sách yêu thích',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: 'So sánh cầu thủ',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.a01);
            },
          ),
        ],
      ),
      body: playerAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Đang tải thông tin cầu thủ...'),
            ],
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  err.toString().replaceAll('Exception: ', ''),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(b04ViewModelProvider(playerId).notifier).refresh(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
        data: (player) => _buildPlayerDetails(context, player),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.library_add_outlined),
            label: const Text('Thêm Vào Bộ Sưu Tập Thẻ', style: TextStyle(fontSize: 16)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddPlayerToCollectionScreen(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerDetails(BuildContext context, Player player) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(player),
          const SizedBox(height: 20),
          const Text('Chỉ số chính', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildMainStats(player),
          const SizedBox(height: 20),
          const Text('Thông số cá nhân & Kỹ năng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildPhysicalTraits(player),
          const SizedBox(height: 20),
          const Text('Kỹ thuật đặc biệt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSkillsSection(player),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(Player player) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${player.ovr}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (player.fullName.isNotEmpty && player.fullName != player.name)
                    Text(
                      player.fullName,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      Chip(
                        label: Text(player.position, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.blue.shade50,
                      ),
                      if (player.cardVersion.isNotEmpty)
                        Chip(
                          label: Text(player.cardVersion, style: const TextStyle(fontSize: 12)),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${player.club} • ${player.nation}', style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStats(Player player) {
    final stats = {
      'PAC': player.stats['PAC'],
      'SHO': player.stats['SHO'],
      'PAS': player.stats['PAS'],
      'DRI': player.stats['DRI'],
      'DEF': player.stats['DEF'],
      'PHY': player.stats['PHY'],
    };

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: stats.entries.map((entry) {
        final displayValue = entry.value != null ? '${entry.value}' : 'N/A';
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.key,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                displayValue,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: entry.value == null ? Colors.red.shade400 : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPhysicalTraits(Player player) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          children: [
            _buildRow('Tuổi', player.age > 0 ? '${player.age}' : 'N/A'),
            const Divider(height: 12),
            _buildRow('Thể hình', '${player.heightCm > 0 ? "${player.heightCm} cm" : "N/A"} / ${player.weightKg > 0 ? "${player.weightKg} kg" : "N/A"}'),
            const Divider(height: 12),
            _buildRow('Kỹ thuật (Skill Moves)', player.skillMoves > 0 ? '★' * player.skillMoves : 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection(Player player) {
    if (player.skills == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Chưa có thông tin kỹ thuật đặc biệt.', style: TextStyle(color: Colors.brown)),
      );
    }

    if (player.skills!.isEmpty) {
      return const Text('Cầu thủ này không có kỹ thuật đặc biệt.', style: TextStyle(color: Colors.grey));
    }

    return Column(
      children: player.skills!.map((skill) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.stars, color: Colors.amber),
            title: Text(skill.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              skill.description.isNotEmpty
                  ? skill.description
                  : (skill.type ?? 'Kỹ năng'),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
