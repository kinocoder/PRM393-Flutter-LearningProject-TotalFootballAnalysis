import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/user_profile.dart';
import '../model/avatar_failure.dart';
import '../services/cloudinary_service.dart';
import '../services/profile_firestore_service.dart';

part 'profile_repository.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository();
}

class ProfileRepository {
  ProfileRepository({
    AvatarCloudinaryService? cloudinaryService,
    ProfileFirestoreService? firestoreService,
    Duration avatarWriteTimeout = const Duration(seconds: 15),
  }) : assert(avatarWriteTimeout > Duration.zero),
       _avatarWriteTimeout = avatarWriteTimeout,
       _cloudinaryService = cloudinaryService ?? AvatarCloudinaryService(),
       _firestoreService = firestoreService ?? ProfileFirestoreService();

  final AvatarCloudinaryService _cloudinaryService;
  final ProfileFirestoreService _firestoreService;
  final Duration _avatarWriteTimeout;

  // Lấy hồ sơ người dùng.
  Future<UserProfile?> getProfile(String uid) {
    return _firestoreService.getProfile(uid);
  }

  // Tạo hồ sơ khi chưa tồn tại.
  Future<void> createProfile(UserProfile profile) {
    return _firestoreService.createProfile(profile);
  }

  // Cập nhật tên hiển thị.
  Future<void> updateDisplayName(String uid, String displayName) {
    return _firestoreService.updateDisplayName(uid, displayName);
  }

  // Upload ảnh lên Cloudinary, sau đó lưu vào Firestore.
  Future<void> updateAvatar(String uid, XFile image) async {
    final result = await _cloudinaryService.uploadAvatar(image);

    try {
      await _firestoreService
          .updateAvatar(
            uid,
            avatarUrl: result.url,
            avatarPublicId: result.publicId,
          )
          .timeout(_avatarWriteTimeout);
    } catch (error) {
      // Never delete here: timeout does not cancel a queued Firestore write.
      // Keep the returned identity for diagnosis/reconciliation, not UI output.
      throw AvatarSaveException(
        uid: uid,
        avatarUrl: result.url,
        avatarPublicId: result.publicId,
        cause: error,
        timedOut: error is TimeoutException,
      );
    }
  }

  // Khôi phục avatar mặc định.
  Future<void> resetAvatar(String uid, {String avatarId = 'ball'}) {
    return _firestoreService.resetAvatar(uid, avatarId: avatarId);
  }
}
