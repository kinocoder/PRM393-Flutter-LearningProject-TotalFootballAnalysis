import 'package:flutter/material.dart';
import '../../../data/model/player.dart';

class PlayerTile extends StatelessWidget {
  final Player player;
  final VoidCallback? onTap;

  const PlayerTile({
    super.key,
    required this.player,
    this.onTap,
  });

  // Hàm chọn màu huy hiệu theo điểm OVR
  Color _getBadgeColor(int ovr) {
    if (ovr >= 90) return Colors.amber.shade700;
    if (ovr >= 80) return Colors.purple.shade600;
    if (ovr >= 70) return Colors.blue.shade600;
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),

        // 1. Huy hiệu OVR
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _getBadgeColor(player.ovr),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${player.ovr}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),

        // 2. Tên cầu thủ
        title: Text(
          player.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // 3. Vị trí & Câu lạc bộ / Quốc gia
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                player.position,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.0,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${player.club} • ${player.nation}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // 4. Phiên bản thẻ (cardVersion)
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            player.cardVersion,
            style: TextStyle(
              fontSize: 11.0,
              color: Colors.blueAccent.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}