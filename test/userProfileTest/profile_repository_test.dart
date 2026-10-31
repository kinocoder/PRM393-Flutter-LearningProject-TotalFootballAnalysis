import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united2/data/model/user_profile.dart';
import 'package:united2/data/repositories/profile_repository.dart';
import 'package:united2/data/services/cloudinary_service.dart';
import 'package:united2/data/services/profile_firestore_service.dart';

class MockCloudinary extends Mock implements AvatarCloudinaryService {}

class MockStore extends Mock implements ProfileFirestoreService {}

void main() {
  late MockCloudinary cloud;
  late MockStore store;
  late ProfileRepository repo;
  final image = XFile('never-read.png');
  const profile = UserProfile(
    uid: 'one',
    email: 'a@example.com',
    displayName: 'Player',
  );
  setUp(() {
    cloud = MockCloudinary();
    store = MockStore();
    repo = ProfileRepository(cloudinaryService: cloud, firestoreService: store);
  });
  test('R01 delegates reads, creation, name and reset arguments', () async {
    when(() => store.getProfile('one')).thenAnswer((_) async => profile);
    when(() => store.createProfile(profile)).thenAnswer((_) async {});
    when(() => store.updateDisplayName('one', 'New')).thenAnswer((_) async {});
    when(() => store.resetAvatar('one', avatarId: 'ball'))
        .thenAnswer((_) async {});
    when(() => store.resetAvatar('one', avatarId: 'shirt'))
        .thenAnswer((_) async {});
    expect(await repo.getProfile('one'), same(profile));
    await repo.createProfile(profile);
    await repo.updateDisplayName('one', 'New');
    await repo.resetAvatar('one');
    await repo.resetAvatar('one', avatarId: 'shirt');
    verify(() => store.createProfile(profile)).called(1);
    verify(() => store.updateDisplayName('one', 'New')).called(1);
    verify(() => store.resetAvatar('one', avatarId: 'ball')).called(1);
    verify(() => store.resetAvatar('one', avatarId: 'shirt')).called(1);
    verifyZeroInteractions(cloud);
  });
  test(
    'R02 upload finishes before Firestore receives returned URL/id',
    () async {
      final events = <String>[];
      when(() => cloud.uploadAvatar(image)).thenAnswer((_) async {
        events.add('upload');
        return const AvatarUploadResult(url: 'url', publicId: 'id');
      });
      when(
        () => store.updateAvatar('one', avatarUrl: 'url', avatarPublicId: 'id'),
      ).thenAnswer((_) async {
        events.add('write');
      });
      await repo.updateAvatar('one', image);
      expect(events, ['upload', 'write']);
      verify(
        () => store.updateAvatar('one', avatarUrl: 'url', avatarPublicId: 'id'),
      ).called(1);
    },
  );
  test('R03 failed upload never writes Firestore', () async {
    final error = StateError('upload failed');
    when(() => cloud.uploadAvatar(image)).thenThrow(error);
    await expectLater(repo.updateAvatar('one', image), throwsA(same(error)));
    verifyZeroInteractions(store);
  });
  test('R04 failed Firestore after upload reports original error', () async {
    final error = StateError('write failed');
    when(() => cloud.uploadAvatar(image)).thenAnswer(
      (_) async => const AvatarUploadResult(url: 'url', publicId: 'id'),
    );
    when(
      () => store.updateAvatar('one', avatarUrl: 'url', avatarPublicId: 'id'),
    ).thenThrow(error);
    await expectLater(repo.updateAvatar('one', image), throwsA(same(error)));
    verify(() => cloud.uploadAvatar(image)).called(1);
  });
}
