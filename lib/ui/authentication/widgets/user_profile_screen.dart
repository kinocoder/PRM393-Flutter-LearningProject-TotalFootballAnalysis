import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../view_models/user_profile_view_model.dart';
import '../view_models/logout_view_model.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreen();
}

class _UserProfileScreen extends ConsumerState<UserProfileScreen> {
  final _nameController = TextEditingController();
  final _imagePicker = ImagePicker();

  void _showSuccess(String message) {
    if (!mounted) return;
    final state = ref.read(userProfileViewModelProvider);
    if (state.isLoading || state.hasError || !state.hasValue) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF176B46),
          content: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Chưa có thông tin';
    final date = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}:${two(date.second)}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null || !mounted) return;

      await ref.read(userProfileViewModelProvider.notifier).updateAvatar(image);
      _showSuccess('Đã cập nhật ảnh đại diện.');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Không thể chọn ảnh: $error')));
    }
  }

  Future<void> _editDisplayName(String currentName) async {
    _nameController.text = currentName;

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chỉnh sửa tên hiển thị'),
        content: TextField(
          controller: _nameController,
          maxLength: 40,
          decoration: const InputDecoration(
            labelText: 'Tên hiển thị',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final name = _nameController.text.trim();

              if (name.length < 2 || name.length > 40) {
                return;
              }

              Navigator.pop(dialogContext, name);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (newName == null || newName == currentName || !mounted) return;

    await ref
        .read(userProfileViewModelProvider.notifier)
        .updateDisplayName(newName);
    _showSuccess('Đã cập nhật tên hiển thị.');
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileViewModelProvider);
    final logout = ref.watch(logoutViewModelProvider);
    ref.listen(logoutViewModelProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(logoutViewModelProvider.notifier).errorMessage,
            ),
          ),
        );
      }
    });

    ref.listen(userProfileViewModelProvider, (previous, next) {
      if (!mounted) return;

      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi hồ sơ: ${next.error}')));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: logout.isLoading
                ? null
                : () => ref.read(logoutViewModelProvider.notifier).signOut(),
            icon: logout.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: Text(logout.isLoading ? 'Đang đăng xuất...' : 'Đăng xuất'),
          ),
        ),
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Không thể tải hồ sơ'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  ref.invalidate(userProfileViewModelProvider);
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (profile) {
          final avatarUrl = profile.avatarUrl;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 55)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _pickAvatar,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Thay đổi ảnh đại diện'),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Tên hiển thị'),
                subtitle: Text(profile.displayName),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _editDisplayName(profile.displayName),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(profile.email),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Thời gian tạo hồ sơ'),
                subtitle: Text(_formatDate(profile.createdAt)),
              ),
              ListTile(
                leading: const Icon(Icons.update),
                title: const Text('Cập nhật lần cuối'),
                subtitle: Text(_formatDate(profile.updatedAt)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref
                      .read(userProfileViewModelProvider.notifier)
                      .resetAvatar();
                  _showSuccess('Đã khôi phục ảnh đại diện mặc định.');
                },
                icon: const Icon(Icons.restore),
                label: const Text('Khôi phục avatar mặc định'),
              ),
            ],
          );
        },
      ),
    );
  }
}
