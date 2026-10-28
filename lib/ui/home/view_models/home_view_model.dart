import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/view_models/auth_session_view_model.dart';

final homeViewModelProvider = Provider.autoDispose<HomeViewModel>((ref) {
  final session = ref.watch(authSessionProvider).asData?.value;
  final name = session?.name?.trim() ?? '';
  final email = session?.email?.trim() ?? '';
  final emailName = email.split('@').first;
  final avatar = session?.avatarUrl?.trim();
  return HomeViewModel(
    displayName: name.isNotEmpty
        ? name
        : emailName.isNotEmpty
        ? emailName
        : 'Người dùng',
    email: email.isEmpty ? 'Chưa có email' : email,
    avatarUrl: avatar == null || avatar.isEmpty ? null : avatar,
    verificationLabel: session?.emailVerified == true
        ? 'Đã xác minh email'
        : 'Chưa xác minh email',
  );
});

/// Read-only presentation data derived reactively from the current session.
class HomeViewModel {
  const HomeViewModel({
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    required this.verificationLabel,
  });
  final String displayName;
  final String email;
  final String? avatarUrl;
  final String verificationLabel;
}
