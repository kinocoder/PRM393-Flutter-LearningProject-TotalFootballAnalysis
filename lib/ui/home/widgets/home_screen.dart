import 'package:flutter/material.dart';
import '../../../routing/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chào mừng bạn đến với Total Football Analysis!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.b01);
              },
              icon: const Icon(Icons.people_alt),
              label: const Text('Xem danh mục cầu thủ (B01)'),
            ),
          ],
        ),
      ),
    );
  }
}
