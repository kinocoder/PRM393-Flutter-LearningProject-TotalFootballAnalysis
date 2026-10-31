import 'package:flutter/material.dart';

import 'add_player_to_collection_screen.dart';
import 'comparison_history_screen.dart';
import 'favorite_players_screen.dart';
import 'my_collection_screen.dart';

class CollectionHomeScreen extends StatelessWidget {
  const CollectionHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bộ sưu tập')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _CollectionMenuTile(
            icon: Icons.collections_bookmark_outlined,
            title: 'Bộ sưu tập của tôi',
            subtitle: 'Xem và quản lý cầu thủ đã thêm',
            screen: MyCollectionScreen(),
          ),
          _CollectionMenuTile(
            icon: Icons.person_add_alt_1_outlined,
            title: 'Thêm cầu thủ',
            subtitle: 'Tìm cầu thủ từ danh mục chung',
            screen: AddPlayerToCollectionScreen(),
          ),
          _CollectionMenuTile(
            icon: Icons.favorite_border,
            title: 'Cầu thủ yêu thích',
            subtitle: 'Các cầu thủ đã được nhấn tim',
            screen: FavoritePlayersScreen(),
          ),
          _CollectionMenuTile(
            icon: Icons.history,
            title: 'Lịch sử so sánh',
            subtitle: 'Các kết quả so sánh đã lưu',
            screen: ComparisonHistoryScreen(),
          ),
        ],
      ),
    );
  }
}

class _CollectionMenuTile extends StatelessWidget {
  const _CollectionMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.screen,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => screen)),
      ),
    );
  }
}
