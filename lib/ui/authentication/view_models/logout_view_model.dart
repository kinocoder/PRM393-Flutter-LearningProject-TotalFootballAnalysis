import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/auth_repository.dart';

part 'logout_view_model.g.dart';

@Riverpod(keepAlive: true)
class LogoutViewModel extends _$LogoutViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signOut() async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
    if (ref.mounted) state = result;
  }

  String get errorMessage => 'Không thể đăng xuất. Vui lòng thử lại.';
}
