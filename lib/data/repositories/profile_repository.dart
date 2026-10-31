import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/user_profile.dart';
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
  }) : _cloudinaryService = cloudinaryService ?? AvatarCloudinaryService(),
       _firestoreService = firestoreService ?? ProfileFirestoreService();

  final AvatarCloudinaryService _cloudinaryService;
  final ProfileFirestoreService _firestoreService;

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

    await _firestoreService.updateAvatar(
      uid,
      avatarUrl: result.url,
      avatarPublicId: result.publicId,
    );
  }

  // Khôi phục avatar mặc định.
  Future<void> resetAvatar(String uid, {String avatarId = 'ball'}) {
    return _firestoreService.resetAvatar(uid, avatarId: avatarId);
  }
}
