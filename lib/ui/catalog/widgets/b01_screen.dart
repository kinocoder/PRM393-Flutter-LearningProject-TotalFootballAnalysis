import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/player.dart';
import '../../../routing/app_routes.dart';
import '../view_models/b01_view_model.dart';

class B01Screen extends ConsumerWidget {
  const B01Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersState = ref.watch(b01ViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Danh mục cầu thủ',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.b02);
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.b03);
            },
          ),
        ],
      ),
      body: playersState.when(
        data: (players) {
          if (players.isEmpty) {
            return const Center(
              child: Text(
                'Danh sách rỗng',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(b01ViewModelProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: players.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 0.8,
                color: Color(0xFFF0F0F0),
              ),
              itemBuilder: (context, index) {
                final player = players[index];
                return _PlayerTile(player: player);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Lỗi tải dữ liệu: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final Player player;

  const _PlayerTile({required this.player});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 52,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E4FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${player.ovr}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1A3A),
              ),
            ),
            Text(
              player.position.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B658A),
              ),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              player.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (player.cardVersion.isNotEmpty && player.cardVersion != 'Base')
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Mẫu',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF666666),
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        '${player.club} · ${player.nation}',
        style: const TextStyle(fontSize: 13, color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
        size: 20,
      ),
      onTap: () {
        // Mở chi tiết cầu thủ
      },
    );
  }
}
