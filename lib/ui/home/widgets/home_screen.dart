import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routing/app_routes.dart';
import '../../authentication/view_models/logout_view_model.dart';
import '../../collection/widgets/collection_home_screen.dart';
import '../view_models/home_view_model.dart';
import 'account_menu.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(homeViewModelProvider);
    final logout = ref.watch(logoutViewModelProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Total Football',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          AccountMenu(account: account, isSigningOut: logout.isLoading),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF176B46),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.sports_soccer,
                        size: 36,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Xin chào, ${account.displayName}!',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Khám phá cầu thủ và tìm hiểu thế giới bóng đá.',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Khám phá',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 16) / 2;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _FeatureCard(
                          width: width,
                          height: width,
                          compact: true,
                          icon: Icons.groups_outlined,
                          title: 'Danh mục cầu thủ',
                          description:
                              'Khám phá danh sách và thông tin cầu thủ.',
                          onTap: logout.isLoading
                              ? null
                              : () =>
                                    Navigator.pushNamed(context, AppRoutes.b01),
                        ),
                        _FeatureCard(
                          width: width,
                          height: width,
                          compact: true,
                          icon: Icons.person_search_outlined,
                          title: 'Tìm kiếm cầu thủ',
                          description: 'Tìm cầu thủ theo tên hoặc biệt danh.',
                          onTap: logout.isLoading
                              ? null
                              : () =>
                                    Navigator.pushNamed(context, AppRoutes.b02),
                        ),
                        _FeatureCard(
                          width: width,
                          height: width,
                          compact: true,
                          icon: Icons.compare_arrows,
                          title: 'So sánh cầu thủ',
                          description:
                              'So sánh chỉ số, kỹ thuật và đánh giá cầu thủ.',
                          onTap: logout.isLoading
                              ? null
                              : () =>
                                    Navigator.pushNamed(context, AppRoutes.a01),
                        ),
                        _FeatureCard(
                          width: width,
                          height: width,
                          compact: true,
                          icon: Icons.collections_bookmark_outlined,
                          title: 'Bộ sưu tập',
                          description: 'Quản lý cầu thủ và lịch sử của bạn.',
                          onTap: logout.isLoading
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const CollectionHomeScreen(),
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.height,
    this.compact = false,
  });
  final double width;
  final double? height;
  final bool compact;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: compact ? 0 : null,
        color: compact ? const Color(0xFFF8F4FC) : null,
        shape: compact
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            : null,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(compact ? 10 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: compact ? 26 : 36,
                  color: const Color(0xFF176B46),
                ),
                if (compact) const Spacer() else const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: compact ? 14 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: compact ? 2 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                ),
                SizedBox(height: compact ? 3 : 8),
                Text(
                  description,
                  maxLines: compact ? 2 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  style: TextStyle(fontSize: compact ? 11 : 14),
                ),
                SizedBox(height: compact ? 3 : 20),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.arrow_forward, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
