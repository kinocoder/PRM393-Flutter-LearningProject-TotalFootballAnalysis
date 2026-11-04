import 'package:flutter/material.dart';
import '../../../data/model/formation.dart';

/// Sân bóng màu xanh, đặt từng vị trí theo toạ độ % của sơ đồ.
/// Dùng ở C02 (xem trước sơ đồ) và C04 (xếp cầu thủ).
class PitchView extends StatelessWidget {
  final Formation formation;
  final Widget Function(FormationSlot slot) slotBuilder;

  const PitchView({
    super.key,
    required this.formation,
    required this.slotBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.7,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            const slotSize = 64.0;

            return Stack(
              children: [
                // Vạch giữa sân
                Center(child: Container(height: 2, color: Colors.white54)),
                for (final slot in formation.slots)
                  Positioned(
                    left: slot.x / 100 * width - slotSize / 2,
                    top: slot.y / 100 * height - slotSize / 2,
                    width: slotSize,
                    height: slotSize,
                    child: slotBuilder(slot),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Một vị trí trên sân: vòng tròn + chữ bên dưới.
class SlotChip extends StatelessWidget {
  final String label;
  final String caption;
  final Color color;
  final VoidCallback? onTap;

  const SlotChip({
    super.key,
    required this.label,
    required this.caption,
    this.color = Colors.white24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// Hộp thoại hỏi Có/Không, dùng khi xoá, đổi sơ đồ, chuyển vị trí...
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Đồng ý'),
        ),
      ],
    ),
  );
  return result ?? false;
}
