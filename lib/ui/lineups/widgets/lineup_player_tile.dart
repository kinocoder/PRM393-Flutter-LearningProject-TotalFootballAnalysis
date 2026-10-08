import 'package:flutter/material.dart';

import '../../../domain/models/player.dart';
import '../../../utils/formatters.dart';

/// Dòng cầu thủ trong danh sách ứng viên C03.
class LineupPlayerTile extends StatelessWidget {
  const LineupPlayerTile({
    super.key,
    required this.player,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.selected = false,
  });

  final Player player;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      selected: selected,
      onTap: onTap,
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatStat(player.ovr),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: scheme.onPrimaryContainer),
            ),
            Text(player.position, style: TextStyle(fontSize: 10, color: scheme.onPrimaryContainer)),
          ],
        ),
      ),
      title: Row(
        children: [
          Flexible(child: Text(player.name, overflow: TextOverflow.ellipsis)),
          if (player.isSample) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(6)),
              child: Text('Mẫu', style: TextStyle(fontSize: 11, color: scheme.onSecondaryContainer)),
            ),
          ],
        ],
      ),
      subtitle: subtitle == null ? null : Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: trailing,
    );
  }
}
