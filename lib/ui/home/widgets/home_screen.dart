import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../core/themes/app_theme.dart';

/// Trang chủ tạm: điểm vào các mảng. Mỗi mảng thêm nút của mình khi merge.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget area(String code, String title, String desc, Color color, {String? route}) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color,
              child: Text(code, style: const TextStyle(color: Colors.white)),
            ),
            title: Text(title),
            subtitle: Text(route == null ? '$desc · đang phát triển' : desc),
            trailing: route == null ? null : const Icon(Icons.chevron_right),
            enabled: route != null,
            onTap: route == null ? null : () => context.push(route),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Total Football Analyzer')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          area('A', 'So sánh cầu thủ', 'A01–A04', AreaColors.compare),
          area('B', 'Danh mục cầu thủ', 'B01–B04', AreaColors.catalog),
          area('C', 'Đội hình', 'C01–C04 · xếp 4-3-3 / 4-4-2', AreaColors.lineup, route: AppRoutes.c01),
          area('D', 'Tài khoản', 'D01–D04', AreaColors.account),
          area('E', 'Bộ sưu tập', 'E01–E04', AreaColors.collection),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Ứng dụng học tập không chính thức, không liên kết với Total Football VNG.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
