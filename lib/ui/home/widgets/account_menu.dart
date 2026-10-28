import 'package:flutter/material.dart';

import '../view_models/home_view_model.dart';

enum _AccountAction { details, logout }

class AccountMenu extends StatelessWidget {
  const AccountMenu({
    super.key,
    required this.account,
    required this.isSigningOut,
    required this.onSignOut,
  });
  final HomeViewModel account;
  final bool isSigningOut;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_AccountAction>(
      tooltip: 'Tài khoản',
      enabled: !isSigningOut,
      position: PopupMenuPosition.under,
      onSelected: (action) {
        switch (action) {
          case _AccountAction.details:
            _showDetails(context);
          case _AccountAction.logout:
            onSignOut();
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
        PopupMenuDivider(),
        PopupMenuItem(
          value: _AccountAction.logout,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout),
            title: Text('Đăng xuất'),
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

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Chi tiết tài khoản',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(child: _Avatar(url: account.avatarUrl, size: 72)),
              const SizedBox(height: 20),
              const Text('Tên hiển thị'),
              SelectableText(
                account.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Email'),
              SelectableText(
                account.email,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(account.verificationLabel),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, this.size = 36});
  final String? url;
  final double size;

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
