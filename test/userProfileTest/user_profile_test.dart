import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united2/data/model/user_profile.dart';

void main() {
  test('M01 deserializes all fields and Firestore timestamps', () {
    final date = DateTime.utc(2026, 10, 1);
    final profile = UserProfile.fromJson({
      'uid': 'untrusted-id',
      'email': 'a@example.com',
      'displayName': 'Player',
      'avatarId': 'ball',
      'avatarUrl': 'https://example.test/a.png',
      'avatarPublicId': 'avatars/1',
      'createdAt': Timestamp.fromDate(date),
      'updatedAt': date,
    }, uid: 'one');
    expect(profile.uid, 'one');
    expect(profile.email, 'a@example.com');
    expect(profile.displayName, 'Player');
    expect(profile.avatarUrl, 'https://example.test/a.png');
    expect(profile.avatarPublicId, 'avatars/1');
    expect(profile.createdAt!.isAtSameMomentAs(date), isTrue);
    expect(profile.updatedAt, date);
  });
  test('M02 serialization excludes server-managed dates and round trips', () {
    final profile = UserProfile(
      uid: 'one',
      email: 'a@example.com',
      displayName: 'Player',
      avatarId: 'shirt',
      avatarUrl: 'url',
      avatarPublicId: 'id',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    expect(profile.toJson(), {
      'uid': 'one',
      'email': 'a@example.com',
      'displayName': 'Player',
      'avatarId': 'shirt',
      'avatarUrl': 'url',
      'avatarPublicId': 'id',
    });
    expect(
      UserProfile.fromJson(profile.toJson(), uid: 'one').toJson(),
      profile.toJson(),
    );
  });
  for (final data in <Map<String, dynamic>>[
    {},
    {
      'email': null,
      'displayName': null,
      'avatarId': null,
      'avatarUrl': null,
      'avatarPublicId': null,
      'createdAt': 'invalid',
    },
  ]) {
    test('M03 defaults and nullable fields: $data', () {
      final profile = UserProfile.fromJson(data, uid: 'one');
      expect(profile.email, '');
      expect(profile.displayName, '');
      expect(profile.avatarId, 'ball');
      expect(profile.avatarUrl, isNull);
      expect(profile.avatarPublicId, isNull);
      expect(profile.createdAt, isNull);
      expect(profile.updatedAt, isNull);
    });
  }
  test('M04 legacy name supported; displayName takes precedence', () {
    expect(
      UserProfile.fromJson({'name': 'Legacy'}, uid: 'one').displayName,
      'Legacy',
    );
    expect(
      UserProfile.fromJson({
        'name': 'Legacy',
        'displayName': 'New',
      }, uid: 'one').displayName,
      'New',
    );
  });
}
