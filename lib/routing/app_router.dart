import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ui/home/widgets/home_screen.dart';
import '../ui/lineups/widgets/c01_screen.dart';
import '../ui/lineups/widgets/c02_screen.dart';
import '../ui/lineups/widgets/c03_screen.dart';
import '../ui/lineups/widgets/c04_screen.dart';
import 'app_routes.dart';

/// Router của ứng dụng. Các mảng khác thêm GoRoute của mình vào danh sách
/// [routes]; route guard đăng nhập do mảng D bổ sung.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Không tìm thấy trang')),
      body: Center(child: Text('Đường dẫn không tồn tại: ${state.uri}')),
    ),
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),

      // C — Đội hình
      GoRoute(path: AppRoutes.c01, builder: (_, __) => const C01Screen()),
      GoRoute(
        path: '/C02/:lineupId',
        builder: (_, state) => C02Screen(
          lineupId: state.pathParameters['lineupId']!,
          openPitchAfter: state.uri.queryParameters['next'] == 'C04',
        ),
      ),
      GoRoute(
        path: '/C03/:lineupId/:slotId',
        builder: (_, state) => C03Screen(
          lineupId: state.pathParameters['lineupId']!,
          slotId: state.pathParameters['slotId']!,
        ),
      ),
      GoRoute(
        path: '/C04/:lineupId',
        builder: (_, state) => C04Screen(lineupId: state.pathParameters['lineupId']!),
      ),
    ],
  );
});
