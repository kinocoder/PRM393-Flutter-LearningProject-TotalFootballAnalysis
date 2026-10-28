import 'package:flutter/material.dart';
import '../../../routing/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Football Analysis - Test Menu'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Chọn chức năng để test:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.a01);
              },
              icon: const Icon(Icons.compare_arrows),
              label: const Text('So sánh cầu thủ (A01 - A04)'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(12)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.b01);
              },
              icon: const Icon(Icons.list),
              label: const Text('Danh mục cầu thủ (B01)'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(12)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.b02);
              },
              icon: const Icon(Icons.grid_view),
              label: const Text('Chi tiết danh mục (B02)'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(12)),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất / Quay lại Login'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(12)),
            ),
          ],
        ),
      ),
    );
  }
}
