import 'package:flutter/material.dart';

import '../../../routing/app_routes.dart';
import '../view_models/home_view_model.dart';

enum _AccountAction { details }

class AccountMenu extends StatelessWidget {
  const AccountMenu({
    super.key,
    required this.account,
    required this.isSigningOut,
  });
  final HomeViewModel account;
  final bool isSigningOut;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_AccountAction>(
      tooltip: 'Tài khoản',
      enabled: !isSigningOut,
      position: PopupMenuPosition.under,
      onSelected: (action) {
        switch (action) {
          case _AccountAction.details:
            Navigator.pushNamed(context, AppRoutes.userProfile);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _AccountAction.details,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.account_circle_outlined),
            title: Text('Chi tiết tài khoản'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSigningOut)
              const SizedBox(
                width: 36,
                height: 36,
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              _Avatar(url: account.avatarUrl),
            if (MediaQuery.sizeOf(context).width >= 420) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  account.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const Icon(Icons.expand_more, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});
  final String? url;
  final double size = 36;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.person_outline, size: size * 0.6);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: const Color(0xFFDDEEE3),
      foregroundColor: const Color(0xFF176B46),
      child: url == null
          ? fallback
          : ClipOval(
              child: Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) => fallback,
              ),
            ),
    );
  }
}
