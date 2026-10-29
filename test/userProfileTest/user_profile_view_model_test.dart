import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united2/data/model/user_profile.dart';
import 'package:united2/data/repositories/profile_repository.dart';
import 'package:united2/ui/authentication/view_models/user_profile_view_model.dart';

import 'support/profile_fakes.dart';

void main() {
  late MemoryProfileRepository repo;
  late MockProfileAuth auth;
  late MockProfileUser user;
  late ProviderContainer container;
  late List<AsyncValue<UserProfile>> states;
  final image = XFile('never-read.png');
  setUp(() {
    repo = MemoryProfileRepository();
    auth = MockProfileAuth();
    user = MockProfileUser();
    when(() => user.uid).thenReturn('one');
    when(() => user.email).thenReturn('a@example.com');
    when(() => user.displayName).thenReturn('Auth Name');
    when(() => auth.currentUser).thenReturn(user);
    states = [];
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        profileAuthProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
  });
  Future<UserProfile> load() {
    container.listen(
      userProfileViewModelProvider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );
    return container.read(userProfileViewModelProvider.future);
  }

  test(
    'V01 signed out gives AsyncError without accessing repository',
    () async {
      when(() => auth.currentUser).thenReturn(null);
      await expectLater(load(), throwsStateError);
      expect(container.read(userProfileViewModelProvider).hasError, isTrue);
      expect(repo.reads, 0);
    },
  );
  test(
    'V02 existing profile transitions loading to data without creation',
    () async {
      expect(await load(), same(sampleProfile));
      expect(states.first.isLoading, isTrue);
      expect(states.last.value, same(sampleProfile));
      expect(repo.creates, 0);
      expect(repo.lastUid, 'one');
    },
  );
  for (final fallback in ['Auth Name', 'a', 'Player']) {
    test('V03 missing profile created using name fallback $fallback', () async {
      repo.profile = null;
      if (fallback != 'Auth Name') {
        when(() => user.displayName).thenReturn(null);
      }
      if (fallback == 'Player') when(() => user.email).thenReturn(null);
      final result = await load();
      expect(result.displayName, fallback);
      expect(result.uid, 'one');
      expect(result.email, fallback == 'Player' ? '' : 'a@example.com');
      expect(result.avatarId, 'ball');
      expect(repo.creates, 1);
      expect(repo.reads, 2);
    });
  }
  test('V04 concurrent creator profile is reloaded', () async {
    repo
      ..profile = null
      ..createError = StateError('exists')
      ..concurrentProfile = sampleProfile;
    expect(await load(), same(sampleProfile));
    expect(repo.creates, 1);
  });
  test(
    'V05 create StateError without concurrent profile remains error',
    () async {
      final error = StateError('failed');
      repo
        ..profile = null
        ..createError = error;
      await expectLater(load(), throwsA(same(error)));
    },
  );
  test('V06 read failure surfaces without trying to create', () async {
    final error = StateError('offline');
    repo.readError = error;
    await expectLater(load(), throwsA(same(error)));
    expect(repo.creates, 0);
  });
  for (final action in ['name', 'avatar', 'reset']) {
    Future<void> invoke(UserProfileViewModel vm) => switch (action) {
      'name' => vm.updateDisplayName('New Name'),
      'avatar' => vm.updateAvatar(image),
      _ => vm.resetAvatar(),
    };
    test(
      'V07 $action loading, success, refreshed data and no overlap',
      () async {
        await load();
        repo.pending = Completer<void>();
        final vm = container.read(userProfileViewModelProvider.notifier);
        final work = invoke(vm);
        expect(container.read(userProfileViewModelProvider).isLoading, isTrue);
        await vm.updateDisplayName('duplicate');
        await vm.updateAvatar(image);
        await vm.resetAvatar();
        expect(repo.names + repo.uploads + repo.resets, 1);
        repo.pending!.complete();
        await work;
        final result = container.read(userProfileViewModelProvider);
        expect(result, isA<AsyncData<UserProfile>>());
        expect(result.value, same(repo.profile));
        expect(repo.lastUid, 'one');
        if (action == 'name') expect(result.value!.displayName, 'New Name');
        if (action == 'avatar') {
          expect(result.value!.avatarPublicId, 'id');
          expect(repo.lastImage, same(image));
        }
        if (action == 'reset') expect(result.value!.avatarUrl, isNull);
      },
    );
    test('V08 $action failure is AsyncError with original error', () async {
      await load();
      final error = StateError('$action failed');
      repo.mutationError = error;
      await invoke(container.read(userProfileViewModelProvider.notifier));
      expect(container.read(userProfileViewModelProvider).error, same(error));
      expect(container.read(userProfileViewModelProvider).isLoading, isFalse);
    });
    test(
      'V09 $action completing after provider disposal does not throw',
      () async {
        await load();
        repo.pending = Completer<void>();
        final work = invoke(
          container.read(userProfileViewModelProvider.notifier),
        );
        container.dispose();
        repo.pending!.complete();
        await expectLater(work, completes);
      },
    );
    test('V10 $action deleted profile reports meaningful error', () async {
      await load();
      repo.disappearAfterWrite = true;
      await invoke(container.read(userProfileViewModelProvider.notifier));
      expect(
        container.read(userProfileViewModelProvider).error,
        isA<StateError>(),
      );
    });
  }
  test('V11 commands ignored during initial loading', () async {
    repo.readPending = Completer<void>();
    final loading = load();
    final vm = container.read(userProfileViewModelProvider.notifier);
    await vm.updateDisplayName('New');
    await vm.updateAvatar(image);
    await vm.resetAvatar();
    expect(repo.names + repo.uploads + repo.resets, 0);
    repo.readPending!.complete();
    await loading;
  });
  test('V12 non-StateError creation failure is propagated unchanged', () async {
    final error = Exception('permission-denied');
    repo
      ..profile = null
      ..createError = error;
    await expectLater(load(), throwsA(same(error)));
    expect(repo.creates, 1);
    expect(repo.reads, 1);
  });
  test(
    'V13 failed refresh after successful write surfaces AsyncError',
    () async {
      await load();
      final error = StateError('read unavailable');
      repo.readError = error;
      await container
          .read(userProfileViewModelProvider.notifier)
          .updateDisplayName('New');
      expect(repo.names, 1);
      expect(container.read(userProfileViewModelProvider).error, same(error));
    },
  );
}
