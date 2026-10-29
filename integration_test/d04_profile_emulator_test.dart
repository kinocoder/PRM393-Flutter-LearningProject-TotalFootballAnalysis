import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';
import 'package:united2/data/repositories/profile_repository.dart';
import 'package:united2/data/services/cloudinary_service.dart';
import 'package:united2/data/services/profile_firestore_service.dart';
import 'package:united2/ui/authentication/view_models/user_profile_view_model.dart';

// Dedicated demo project only. Never imports production firebase_options.dart.
// Requires locally supplied owner-only users/{uid} rules. No rules are deployed.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const enabled = bool.fromEnvironment('D04_EMULATORS');
  const host = String.fromEnvironment(
    'D04_EMULATOR_HOST',
    defaultValue: '127.0.0.1',
  );
  const restartPhase = String.fromEnvironment('D04_RESTART_PHASE');
  const runId = String.fromEnvironment('D04_RUN_ID');
  late FirebaseApp app;
  late FirebaseAuth auth;
  late FirebaseFirestore db;
  late ProfileRepository repo;
  late http.Client client;
  var ready = false;

  setUpAll(() async {
    if (!enabled) {
      throw StateError(
        'Set D04_EMULATORS=true with local Auth/Firestore emulators.',
      );
    }
    if (!['127.0.0.1', 'localhost', '10.0.2.2'].contains(host)) {
      throw StateError('Only loopback/Android emulator host is permitted.');
    }
    for (final port in [9099, 8080]) {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
    }
    app = await Firebase.initializeApp(
      name: 'd04-test',
      options: const FirebaseOptions(
        apiKey: 'demo-only-api-key',
        appId: '1:123456789:android:d04test',
        messagingSenderId: '123456789',
        projectId: 'demo-totalfootball-d04',
      ),
    );
    auth = FirebaseAuth.instanceFor(app: app);
    db = FirebaseFirestore.instanceFor(app: app);
    await auth.useAuthEmulator(host, 9099);
    db.settings = const Settings(persistenceEnabled: false);
    db.useFirestoreEmulator(host, 8080);
    client = MockClient((request) async {
      expect(request.method, 'POST');
      return http.Response(
        '{"secure_url":"https://example.test/avatar.png","public_id":"d04/test"}',
        200,
      );
    });
    repo = ProfileRepository(
      firestoreService: ProfileFirestoreService(firestore: db),
      cloudinaryService: AvatarCloudinaryService(client: client),
    );
    ready = true;
  });
  tearDownAll(() async {
    if (ready) {
      client.close();
      await auth.signOut();
      await app.delete();
    }
  });

  ProviderContainer container() {
    final result = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        profileAuthProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(repo),
      ],
    );
    result.listen(userProfileViewModelProvider, (_, _) {});
    return result;
  }

  if (restartPhase.isEmpty) {
    testWidgets(
      'I01 Auth -> profile, users/uid, edit, fake upload, reload, permission-denied',
      (tester) async {
        final email =
            'd04-${DateTime.now().microsecondsSinceEpoch}@example.test';
        const password = 'D04-Test-Only-123!';
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = auth.currentUser!.uid;
        await auth.signOut();
        await auth.signInWithEmailAndPassword(email: email, password: password);
        final first = container();
        addTearDown(first.dispose);
        final profile = await first.read(userProfileViewModelProvider.future);
        expect(profile.uid, uid);
        final document = db.collection('users').doc(uid);
        expect(
          (await document.get(const GetOptions(source: Source.server))).exists,
          isTrue,
        );
        final vm = first.read(userProfileViewModelProvider.notifier);
        await vm.updateDisplayName('Emulator Player');
        expect(
          first.read(userProfileViewModelProvider).value!.displayName,
          'Emulator Player',
        );
        final temporary = await Directory.systemTemp.createTemp(
          'd04_integration_',
        );
        addTearDown(() => temporary.delete(recursive: true));
        final image = await File('${temporary.path}/avatar.png')
            .writeAsBytes([1, 2, 3]);
        await vm.updateAvatar(XFile(image.path));
        expect(
          first.read(userProfileViewModelProvider).value!.avatarUrl,
          'https://example.test/avatar.png',
        );
        final saved = (await document.get(
          const GetOptions(source: Source.server),
        )).data()!;
        expect(saved['avatarPublicId'], 'd04/test');
        first.dispose();
        final second = container();
        addTearDown(second.dispose);
        final reloaded = await second.read(userProfileViewModelProvider.future);
        expect(reloaded.displayName, 'Emulator Player');
        expect(reloaded.avatarUrl, 'https://example.test/avatar.png');
        await auth.signOut();
        await expectLater(
          document.get(const GetOptions(source: Source.server)),
          throwsA(
            isA<FirebaseException>().having(
              (e) => e.code,
              'code',
              'permission-denied',
            ),
          ),
        );
      },
    );
  } else {
    testWidgets('I02 process restart persistence: $restartPhase', (
      tester,
    ) async {
      expect(
        runId,
        isNotEmpty,
        reason: 'Supply the same unique D04_RUN_ID for seed and verify invocations.',
      );
      expect(['seed', 'verify'], contains(restartPhase));
      final email = 'd04-restart-$runId@example.test';
      const password = 'D04-Restart-Only-123!';
      if (restartPhase == 'seed') {
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await auth.signInWithEmailAndPassword(email: email, password: password);
      }
      final scope = container();
      addTearDown(scope.dispose);
      await scope.read(userProfileViewModelProvider.future);
      if (restartPhase == 'seed') {
        await scope
            .read(userProfileViewModelProvider.notifier)
            .updateDisplayName('Restart $runId');
      }
      expect(
        scope.read(userProfileViewModelProvider).value!.displayName,
        'Restart $runId',
      );
      final saved = await db
          .collection('users')
          .doc(auth.currentUser!.uid)
          .get(const GetOptions(source: Source.server));
      expect(saved.data()!['displayName'], 'Restart $runId');
    });
  }
}
