import 'package:flutter/material.dart';

import '../../../data/model/player.dart';

class CollectionPlayerCard extends StatelessWidget {
  const CollectionPlayerCard({
    super.key,
    required this.player,
    this.note,
    this.trailing,
  });

  final Player player;
  final String? note;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE9E0FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${player.ovr}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(player.position, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        title: Text(
          player.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${player.club} · ${player.nation}'),
            if (note != null && note!.isNotEmpty)
              Text(
                'Ghi chú: $note',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}
