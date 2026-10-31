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
  Future<UserProfile> build() async {
    final user = ref.read(profileAuthProvider).currentUser;

    if (user == null) {
      throw StateError('Người dùng chưa đăng nhập');
    }

    final repository = ref.read(profileRepositoryProvider);
    final profile = await repository.getProfile(user.uid);

    if (profile != null) {
      return profile;
    }

    // Hỗ trợ tài khoản đã đăng ký trước khi tạo Firestore.
    final newProfile = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? user.email?.split('@').first ?? 'Player',
    );

    try {
      await repository.createProfile(newProfile);
    } on StateError {
      // Một yêu cầu khác có thể đã tạo hồ sơ trước đó.
      final existing = await repository.getProfile(user.uid);
      if (existing != null) return existing;
      rethrow;
    }

    return await repository.getProfile(user.uid) ?? newProfile;
  }

  Future<void> updateDisplayName(String displayName) async {
    final previous = state.value;
    if (previous == null || state.isLoading) return;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);

      await repository.updateDisplayName(previous.uid, displayName);

      return await repository.getProfile(previous.uid) ??
          (throw StateError('Không tìm thấy hồ sơ người dùng'));
    });
    if (ref.mounted) state = result;
  }

  Future<void> updateAvatar(XFile image) async {
    final previous = state.value;
    if (previous == null || state.isLoading) return;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);

      await repository.updateAvatar(previous.uid, image);

      return await repository.getProfile(previous.uid) ??
          (throw StateError('Không tìm thấy hồ sơ người dùng'));
    });
    if (ref.mounted) state = result;
  }

  Future<void> resetAvatar() async {
    final previous = state.value;
    if (previous == null || state.isLoading) return;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);

      await repository.resetAvatar(previous.uid);

      return await repository.getProfile(previous.uid) ??
          (throw StateError('Không tìm thấy hồ sơ người dùng'));
    });
    if (ref.mounted) state = result;
  }
}
