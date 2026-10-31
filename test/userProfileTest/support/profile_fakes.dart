import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united2/data/model/user_profile.dart';
import 'package:united2/data/repositories/profile_repository.dart';

class MockProfileAuth extends Mock implements FirebaseAuth {}

class MockProfileUser extends Mock implements User {}

const sampleProfile = UserProfile(
  uid: 'one',
  email: 'a@example.com',
  displayName: 'Player',
);

class MemoryProfileRepository implements ProfileRepository {
  UserProfile? profile = sampleProfile;
  Object? readError;
  Object? mutationError;
  Object? createError;
  UserProfile? concurrentProfile;
  Completer<void>? pending;
  Completer<void>? readPending;
  bool disappearAfterWrite = false;
  int reads = 0;
  int creates = 0;
  int names = 0;
  int uploads = 0;
  int resets = 0;
  UserProfile? created;
  String? lastUid;
  String? lastName;
  XFile? lastImage;

  @override
  Future<UserProfile?> getProfile(String uid) async {
    reads++;
    lastUid = uid;
    if (readPending != null) await readPending!.future;
    if (readError != null) throw readError!;
    return profile;
  }

  @override
  Future<void> createProfile(UserProfile value) async {
    creates++;
    created = value;
    if (createError != null) {
      profile = concurrentProfile;
      throw createError!;
    }
    profile = value;
  }

  Future<void> _wait() async {
    if (pending != null) await pending!.future;
    if (mutationError != null) throw mutationError!;
  }

  @override
  Future<void> updateDisplayName(String uid, String displayName) async {
    names++;
    lastUid = uid;
    lastName = displayName;
    await _wait();
    profile = disappearAfterWrite
        ? null
        : UserProfile(
            uid: uid,
            email: sampleProfile.email,
            displayName: displayName,
          );
  }

  @override
  Future<void> updateAvatar(String uid, XFile image) async {
    uploads++;
    lastUid = uid;
    lastImage = image;
    await _wait();
    profile = disappearAfterWrite
        ? null
        : UserProfile(
            uid: uid,
            email: sampleProfile.email,
            displayName: 'Player',
            avatarUrl: 'https://example.test/a.png',
            avatarPublicId: 'id',
          );
  }

  @override
  Future<void> resetAvatar(String uid, {String avatarId = 'ball'}) async {
    resets++;
    lastUid = uid;
    await _wait();
    profile = disappearAfterWrite
        ? null
        : UserProfile(
            uid: uid,
            email: sampleProfile.email,
            displayName: 'Player',
            avatarId: avatarId,
          );
  }
}
