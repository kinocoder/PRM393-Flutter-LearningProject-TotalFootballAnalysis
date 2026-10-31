import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user_profile.dart';

class ProfileFirestoreService {
  ProfileFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // Lấy thông tin hồ sơ theo Firebase Auth UID.
  Future<UserProfile?> getProfile(String uid) async {
    final snapshot = await _users.doc(uid).get();

    if (!snapshot.exists) {
      return null;
    }

    return UserProfile.fromJson(snapshot.data()!, uid: snapshot.id);
  }

  // Tạo hồ sơ lần đầu nếu chưa tồn tại.
  Future<void> createProfile(UserProfile profile) async {
    final document = _users.doc(profile.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);

      if (snapshot.exists) {
        throw StateError('User profile already exists');
      }

      transaction.set(document, {
        ...profile.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Cập nhật tên hiển thị.
  Future<void> updateDisplayName(String uid, String displayName) async {
    final name = displayName.trim();

    if (name.length < 2 || name.length > 40) {
      throw ArgumentError('Tên hiển thị phải từ 2 đến 40 ký tự');
    }

    await _users.doc(uid).update({
      'displayName': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Lưu thông tin ảnh đã upload lên Cloudinary.
  Future<void> updateAvatar(
    String uid, {
    required String avatarUrl,
    required String avatarPublicId,
  }) async {
    await _users.doc(uid).update({
      'avatarUrl': avatarUrl,
      'avatarPublicId': avatarPublicId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Quay về avatar mặc định của ứng dụng.
  Future<void> resetAvatar(String uid, {String avatarId = 'ball'}) async {
    await _users.doc(uid).update({
      'avatarId': avatarId,
      'avatarUrl': null,
      'avatarPublicId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
