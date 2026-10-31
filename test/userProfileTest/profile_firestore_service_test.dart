import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:united2/data/model/user_profile.dart';
import 'package:united2/data/services/profile_firestore_service.dart';

class BrokenFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late FakeFirebaseFirestore db;
  late ProfileFirestoreService service;
  const profile = UserProfile(
    uid: 'one',
    email: 'a@example.com',
    displayName: 'Player',
  );
  setUp(() {
    db = FakeFirebaseFirestore();
    service = ProfileFirestoreService(firestore: db);
  });
  test('F01 missing document returns null', () async {
    expect(await service.getProfile('one'), isNull);
  });
  test('F02 creates users/uid with timestamps and reads it back', () async {
    await service.createProfile(profile);
    final raw = (await db.collection('users').doc('one').get()).data()!;
    expect(raw, containsPair('uid', 'one'));
    expect(raw['createdAt'], isA<Timestamp>());
    expect(raw['updatedAt'], isA<Timestamp>());
    expect((await service.getProfile('one'))!.toJson(), profile.toJson());
  });
  test('F03 duplicate creation fails without overwriting', () async {
    await service.createProfile(profile);
    await expectLater(
      service.createProfile(
        const UserProfile(uid: 'one', email: 'changed', displayName: 'Changed'),
      ),
      throwsStateError,
    );
    expect((await service.getProfile('one'))!.displayName, 'Player');
  });
  for (final length in [0, 1, 41]) {
    test('F04 rejects trimmed name length $length without writes', () async {
      await service.createProfile(profile);
      await expectLater(
        service.updateDisplayName('one', ' ${'a' * length} '),
        throwsArgumentError,
      );
      expect((await service.getProfile('one'))!.displayName, 'Player');
    });
  }
  for (final length in [2, 40]) {
    test('F05 accepts boundary $length and trims whitespace', () async {
      await service.createProfile(profile);
      await service.updateDisplayName('one', ' ${'a' * length} ');
      expect((await service.getProfile('one'))!.displayName, 'a' * length);
      expect((await service.getProfile('one'))!.email, profile.email);
    });
  }
  test('F06 avatar update and reset clear both remote fields', () async {
    await service.createProfile(profile);
    await service.updateAvatar(
      'one',
      avatarUrl: 'https://example.test/a.png',
      avatarPublicId: 'avatars/one',
    );
    var result = (await service.getProfile('one'))!;
    expect(result.avatarUrl, 'https://example.test/a.png');
    expect(result.avatarPublicId, 'avatars/one');
    await service.resetAvatar('one', avatarId: 'shirt');
    result = (await service.getProfile('one'))!;
    expect(result.avatarId, 'shirt');
    expect(result.avatarUrl, isNull);
    expect(result.avatarPublicId, isNull);
    await service.resetAvatar('one');
    expect((await service.getProfile('one'))!.avatarId, 'ball');
  });
  test('F07 updating absent document propagates not-found', () async {
    await expectLater(
      service.updateDisplayName('missing', 'New'),
      throwsA(
        isA<FirebaseException>().having((e) => e.code, 'code', 'not-found'),
      ),
    );
  });
  test(
    'F08 Firestore errors propagate unchanged for every operation',
    () async {
      final broken = BrokenFirestore();
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
      when(() => broken.collection('users')).thenThrow(error);
      final subject = ProfileFirestoreService(firestore: broken);
      for (final action in <Future<void> Function()>[
        () async {
          await subject.getProfile('one');
        },
        () => subject.createProfile(profile),
        () => subject.updateDisplayName('one', 'New'),
        () =>
            subject.updateAvatar('one', avatarUrl: 'url', avatarPublicId: 'id'),
        () => subject.resetAvatar('one'),
      ]) {
        await expectLater(action(), throwsA(same(error)));
      }
    },
  );
  test(
    'F09 asynchronous read and write failures preserve Firebase error',
    () async {
      final document = db.collection('users').doc('one');
      await service.createProfile(profile);
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
      whenCalling(Invocation.method(#get, null)).on(document).thenThrow(error);
      whenCalling(Invocation.method(#update, null))
          .on(document)
          .thenThrow(error);
      final subject = service;
      await expectLater(subject.getProfile('one'), throwsA(same(error)));
      await expectLater(
        subject.updateDisplayName('one', 'New'),
        throwsA(same(error)),
      );
      await expectLater(
        subject.updateAvatar('one', avatarUrl: 'url', avatarPublicId: 'id'),
        throwsA(same(error)),
      );
      await expectLater(subject.resetAvatar('one'), throwsA(same(error)));
    },
  );
}
