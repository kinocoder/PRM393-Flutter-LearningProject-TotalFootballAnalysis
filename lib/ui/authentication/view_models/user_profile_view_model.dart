import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/model/user_profile.dart';
import '../../../data/repositories/profile_repository.dart';

part 'user_profile_view_model.g.dart';

// Overridable boundary for isolated profile tests; production uses Firebase.
final profileAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

@riverpod
class UserProfileViewModel extends _$UserProfileViewModel {
  @override
  Future<UserProfile> build(String uid) async {
    final user = ref.read(profileAuthProvider).currentUser;

    if (user == null || user.uid != uid) {
      throw StateError('Người dùng chưa đăng nhập');
    }

    final repository = ref.read(profileRepositoryProvider);
    final profile = await repository.getProfile(uid);

    if (profile != null) {
      return profile;
    }

    // Hỗ trợ tài khoản đã đăng ký trước khi tạo Firestore.
    _requireCurrentSession();
    final newProfile = UserProfile(
      uid: uid,
      email: user.email ?? '',
      displayName: user.displayName ?? user.email?.split('@').first ?? 'Player',
    );

    try {
      await repository.createProfile(newProfile);
    } on StateError {
      // Một yêu cầu khác có thể đã tạo hồ sơ trước đó.
      _requireCurrentSession();
      final existing = await repository.getProfile(uid);
      if (existing != null) return existing;
      rethrow;
    }

    _requireCurrentSession();
    return await repository.getProfile(uid) ?? newProfile;
  }

// Listener còn được giữ lại có thể khiến provider của UID này tiếp tục tồn tại sau khi đăng xuất.
  bool get _isCurrentSession =>
      ref.mounted && ref.read(profileAuthProvider).currentUser?.uid == uid;

  void _requireCurrentSession() {
    if (!_isCurrentSession) {
      throw StateError('Phiên đăng nhập đã thay đổi');
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    if (!_isCurrentSession) return;
    final previous = state.value;
    if (previous == null || state.isLoading) return;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);

      await repository.updateDisplayName(previous.uid, displayName);

      _requireCurrentSession();
      return await repository.getProfile(previous.uid) ??
          (throw StateError('Không tìm thấy hồ sơ người dùng'));
    });
    if (_isCurrentSession) state = result;
  }

  Future<void> updateAvatar(XFile image) async {
    if (!_isCurrentSession) return;
    final previous = state.value;
    if (previous == null || state.isLoading) return;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);

      await repository.updateAvatar(previous.uid, image);

      _requireCurrentSession();
      return await repository.getProfile(previous.uid) ??
          (throw StateError('Không tìm thấy hồ sơ người dùng'));
    });
    if (_isCurrentSession) state = result;
  }

  Future<void> resetAvatar() async {
    if (!_isCurrentSession) return;
    final previous = state.value;
    if (previous == null || state.isLoading) return;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);

      await repository.resetAvatar(previous.uid);

      _requireCurrentSession();
      return await repository.getProfile(previous.uid) ??
          (throw StateError('Không tìm thấy hồ sơ người dùng'));
    });
    if (_isCurrentSession) state = result;
  }
}
