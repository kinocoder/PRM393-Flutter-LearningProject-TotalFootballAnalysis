import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united2/data/model/auth_session.dart';
import 'package:united2/data/model/user_profile.dart';
import 'package:united2/data/repositories/profile_repository.dart';
import 'package:united2/ui/authentication/view_models/auth_session_view_model.dart';
import 'package:united2/ui/authentication/view_models/user_profile_view_model.dart';
import 'package:united2/ui/home/view_models/home_view_model.dart';

import 'support/profile_fakes.dart';

class SessionProfileRepository extends Mock implements ProfileRepository {}

void main() {
  const a = UserProfile(uid: 'A', email: 'a@test.com', displayName: 'Alice');
  const b = UserProfile(uid: 'B', email: 'b@test.com', displayName: 'Bob');
  late SessionProfileRepository repository;
  late MockProfileAuth auth;
  late ProviderContainer container;
  late StreamController<AuthSession?> sessions;

  void signIn(String uid) {
    final user = MockProfileUser();
    when(() => user.uid).thenReturn(uid);
    when(() => auth.currentUser).thenReturn(user);
    sessions.add(AuthSession(uid: uid, emailVerified: true));
  }

  setUp(() {
    repository = SessionProfileRepository();
    auth = MockProfileAuth();
    sessions = StreamController<AuthSession?>();
    when(() => repository.getProfile('A')).thenAnswer((_) async => a);
    when(() => repository.getProfile('B')).thenAnswer((_) async => b);
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        profileAuthProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(repository),
        authSessionProvider.overrideWith((ref) => sessions.stream),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await sessions.close();
    });
  });

  Future<void> switchToB() async {
    final received = Completer<void>();
    final subscription = container.listen(authSessionProvider, (_, next) {
      if (next.asData?.value?.uid == 'B' && !received.isCompleted) {
        received.complete();
      }
    });
    signIn('B');
    await received.future;
    subscription.close();
    await container.pump();
    await container.read(userProfileViewModelProvider('B').future);
    await container.pump();
    expect(container.read(homeViewModelProvider).displayName, 'Bob');
  }

  void retainAAndWatchHome() {
    container.listen(userProfileViewModelProvider('A'), (_, _) {});
    container.listen(homeViewModelProvider, (_, _) {});
  }

  test('Home switches to B while A still has a listener', () async {
    signIn('A');
    retainAAndWatchHome();
    await container.read(userProfileViewModelProvider('A').future);
    await container.pump();
    expect(container.read(homeViewModelProvider).displayName, 'Alice');
    await switchToB();
    expect(container.read(userProfileViewModelProvider('A')).value, a);
    expect(container.read(userProfileViewModelProvider('B')).value, b);
  });

  test('A read completing after B loads cannot replace B', () async {
    final pending = Completer<UserProfile?>();
    when(() => repository.getProfile('A')).thenAnswer((_) => pending.future);
    signIn('A');
    retainAAndWatchHome();
    final loadingA = container.read(userProfileViewModelProvider('A').future);
    await switchToB();
    pending.complete(a);
    await loadingA;
    await container.pump();
    expect(container.read(userProfileViewModelProvider('B')).value, b);
    expect(container.read(homeViewModelProvider).displayName, 'Bob');
  });

  test('Missing A profile is not created after switching to B', () async {
    final pending = Completer<UserProfile?>();
    when(() => repository.getProfile('A')).thenAnswer((_) => pending.future);
    signIn('A');
    retainAAndWatchHome();
    final loadingA = container.read(userProfileViewModelProvider('A').future);
    final rejected = expectLater(loadingA, throwsStateError);
    await switchToB();
    pending.complete(null);
    await rejected;
    expect(container.read(homeViewModelProvider).displayName, 'Bob');
    verify(() => repository.getProfile('A')).called(1);
    verify(() => repository.getProfile('B')).called(1);
    verifyNoMoreInteractions(repository);
  });

  for (final action in ['name', 'avatar', 'reset']) {
    for (final fail in [false, true]) {
      test('$action A completes (error=$fail) after switch to B', () async {
        final pending = Completer<void>();
        final image = XFile('unused.png');
        when(() => repository.updateDisplayName('A', 'New'))
            .thenAnswer((_) => pending.future);
        when(() => repository.updateAvatar('A', image))
            .thenAnswer((_) => pending.future);
        when(() => repository.resetAvatar('A'))
            .thenAnswer((_) => pending.future);
        signIn('A');
        retainAAndWatchHome();
        await container.read(userProfileViewModelProvider('A').future);
        final vm = container.read(userProfileViewModelProvider('A').notifier);
        final work = switch (action) {
          'name' => vm.updateDisplayName('New'),
          'avatar' => vm.updateAvatar(image),
          _ => vm.resetAvatar(),
        };
        await switchToB();
        if (fail) {
          pending.completeError(StateError('Old request failed'));
        } else {
          pending.complete();
        }
        await work;
        await container.pump();
        expect(container.read(userProfileViewModelProvider('B')).value, b);
        expect(container.read(homeViewModelProvider).displayName, 'Bob');
        verify(() => repository.getProfile('A')).called(1);

        // A's retained notifier cannot start another write in B's session.
        clearInteractions(repository);
        await vm.updateDisplayName('New');
        await vm.updateAvatar(image);
        await vm.resetAvatar();
        verifyNoMoreInteractions(repository);
      });
    }
  }
}
