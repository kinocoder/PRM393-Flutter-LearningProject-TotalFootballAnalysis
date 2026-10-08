import 'package:flutter/material.dart';

import '../../../domain/models/formation.dart';

/// Sân bóng với các slot đặt theo toạ độ % của sơ đồ (C02 xem trước, C04 xếp).
/// Tự co giãn theo bề rộng màn hình và khi xoay ngang.
class PitchView extends StatelessWidget {
  const PitchView({
    super.key,
    required this.formation,
    required this.slotBuilder,
    this.slotWidth = 76,
    this.slotHeight = 64,
  });

  final Formation formation;
  final Widget Function(BuildContext context, FormationSlot slot) slotBuilder;
  final double slotWidth;
  final double slotHeight;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 68 / 100,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          // Màn hình nhỏ: thu nhỏ slot để không chồng lên nhau.
          final scale = (w / 360).clamp(0.7, 1.3).toDouble();
          final sw = slotWidth * scale;
          final sh = slotHeight * scale;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(child: CustomPaint(painter: _PitchPainter())),
              for (final slot in formation.slots)
                Positioned(
                  left: slot.x / 100 * w - sw / 2,
                  top: slot.y / 100 * h - sh / 2,
                  width: sw,
                  height: sh,
                  child: slotBuilder(context, slot),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  const _PitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cỏ sọc.
    final dark = Paint()..color = const Color(0xFF2E7D32);
    final light = Paint()..color = const Color(0xFF388E3C);
    const stripes = 10;
    for (var i = 0; i < stripes; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, h * i / stripes, w, h / stripes),
        i.isEven ? dark : light,
      );
    }

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final m = w * 0.04;
    final field = Rect.fromLTRB(m, m, w - m, h - m);
    canvas.drawRect(field, line);
    // Vạch giữa sân + vòng tròn giữa.
    canvas.drawLine(Offset(field.left, h / 2), Offset(field.right, h / 2), line);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.13, line);
    // Vòng cấm hai đầu.
    final boxW = field.width * 0.55;
    final boxH = field.height * 0.15;
    final smallW = field.width * 0.28;
    final smallH = field.height * 0.06;
    canvas.drawRect(Rect.fromLTWH((w - boxW) / 2, field.top, boxW, boxH), line);
    canvas.drawRect(Rect.fromLTWH((w - boxW) / 2, field.bottom - boxH, boxW, boxH), line);
    canvas.drawRect(Rect.fromLTWH((w - smallW) / 2, field.top, smallW, smallH), line);
    canvas.drawRect(Rect.fromLTWH((w - smallW) / 2, field.bottom - smallH, smallW, smallH), line);

  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) => false;
}

/// Một slot trên sân: vòng tròn + nhãn.
class SlotChip extends StatelessWidget {
  const SlotChip({
    super.key,
    required this.label,
    required this.caption,
    this.filled = false,
    this.warning = false,
    this.error = false,
    this.onTap,
    this.onLongPress,
  });

  final String label;
  final String caption;
  final bool filled;
  final bool warning;
  final bool error;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final color = error
        ? Colors.red.shade400
        : warning
            ? Colors.amber.shade600
            : filled
                ? Colors.white
                : Colors.white.withValues(alpha: 0.25);
    final textColor = filled && !error ? Colors.black87 : Colors.white;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: filled
                        ? Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: textColor))
                        : const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
