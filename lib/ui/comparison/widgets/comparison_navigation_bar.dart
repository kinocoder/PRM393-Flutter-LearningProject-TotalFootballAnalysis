import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../routing/app_routes.dart';
import '../view_models/a01_view_model.dart';

/// Thanh chuyển đổi giữa các màn hình trong Mảng A (A01, A02, A03, A04)
class ComparisonNavigationBar extends ConsumerWidget {
  /// Đường dẫn route hiện tại để đánh dấu tab đang kích hoạt
  final String currentRoute;

  const ComparisonNavigationBar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(compareSelectionProvider);
    // Chỉ cho phép chuyển sang A02, A03, A04 khi đã chọn từ 2 thẻ trở lên
    final canNavigate = selectedIds.length >= 2;

    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTab(
                context,
                route: AppRoutes.a01,
                label: 'A01 Chọn thẻ',
                icon: Icons.person_add_outlined,
                isActive: currentRoute == AppRoutes.a01,
                badgeCount: selectedIds.length,
                enabled: true,
              ),
              const SizedBox(width: 4),
              _buildTab(
                context,
                route: AppRoutes.a02,
                label: 'A02 Chỉ số',
                icon: Icons.bar_chart_outlined,
                isActive: currentRoute == AppRoutes.a02,
                enabled: canNavigate,
              ),
              const SizedBox(width: 4),
              _buildTab(
                context,
                route: AppRoutes.a03,
                label: 'A03 Kỹ thuật',
                icon: Icons.auto_awesome_outlined,
                isActive: currentRoute == AppRoutes.a03,
                enabled: canNavigate,
              ),
              const SizedBox(width: 4),
              _buildTab(
                context,
                route: AppRoutes.a04,
                label: 'A04 Đánh giá',
                icon: Icons.star_outline,
                isActive: currentRoute == AppRoutes.a04,
                enabled: canNavigate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hàm dựng từng nút tab chuyển màn hình
  Widget _buildTab(
    BuildContext context, {
    required String route,
    required String label,
    required IconData icon,
    required bool isActive,
    required bool enabled,
    int? badgeCount,
  }) {
    final color = isActive
        ? Theme.of(context).primaryColor
        : enabled
            ? Colors.black87
            : Colors.grey;

    return InkWell(
      onTap: enabled && !isActive
          ? () {
              Navigator.of(context).pushReplacementNamed(route);
            }
          : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: Theme.of(context).primaryColor, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? Theme.of(context).primaryColor : Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount/3',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
