import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united2/data/model/user_profile.dart';
import 'package:united2/data/repositories/profile_repository.dart';
import 'package:united2/ui/authentication/view_models/user_profile_view_model.dart';
import 'package:united2/ui/authentication/widgets/user_profile_screen.dart';

import 'support/profile_fakes.dart';

void main() {
  late MemoryProfileRepository repo;
  late MockProfileAuth auth;
  setUp(() {
    repo = MemoryProfileRepository();
    auth = MockProfileAuth();
    final user = MockProfileUser();
    when(() => user.uid).thenReturn('one');
    when(() => auth.currentUser).thenReturn(user);
  });
  Future<void> mount(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        profileAuthProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: UserProfileScreen()),
    ),
  );
  Future<void> edit(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
  }

  testWidgets('W01 loading then profile fields and default icon', (
    tester,
  ) async {
    repo.readPending = Completer<void>();
    await mount(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    repo.readPending!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Player'), findsOneWidget);
    expect(find.text('a@example.com'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(
      tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundImage,
      isNull,
    );
  });
  testWidgets(
    'W02 Cloudinary URL uses network image with cached pixels, no network',
    (tester) async {
      const url = 'https://res.cloudinary.com/demo/image/upload/avatar.png';
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawColor(Colors.blue, BlendMode.src);
      final picture = recorder.endRecording();
      final pixel = await tester.runAsync(() => picture.toImage(1, 1));
      picture.dispose();
      const provider = NetworkImage(url);
      PaintingBinding.instance.imageCache.putIfAbsent(
        provider,
        () => OneFrameImageStreamCompleter(
          Future.value(ImageInfo(image: pixel!)),
        ),
      );
      addTearDown(() => PaintingBinding.instance.imageCache.clear());
      repo.profile = const UserProfile(
        uid: 'one',
        email: 'a@example.com',
        displayName: 'Player',
        avatarUrl: url,
      );
      await mount(tester);
      await tester.pumpAndSettle();
      expect(
        tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundImage,
        provider,
      );
      expect(find.byIcon(Icons.person), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('W03 dialog prefilled; cancel does not save', (tester) async {
    await mount(tester);
    await tester.pumpAndSettle();
    await edit(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Player',
    );
    await tester.enterText(find.byType(TextField), 'New');
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(repo.names, 0);
    expect(find.text('Player'), findsOneWidget);
  });
  testWidgets('W04 invalid short/blank names stay in dialog without writes', (
    tester,
  ) async {
    await mount(tester);
    await tester.pumpAndSettle();
    await edit(tester);
    for (final name in ['', ' ', ' A ']) {
      await tester.enterText(find.byType(TextField), name);
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(repo.names, 0);
    }
    expect(tester.widget<TextField>(find.byType(TextField)).maxLength, 40);
  });
  for (final name in [' AB ', 'a' * 40]) {
    testWidgets(
      'W05 save accepts boundary name ${name.trim().length}, trims and refreshes',
      (tester) async {
        await mount(tester);
        await tester.pumpAndSettle();
        await edit(tester);
        await tester.enterText(find.byType(TextField), name);
        await tester.tap(find.text('Lưu'));
        await tester.pumpAndSettle();
        expect(repo.names, 1);
        expect(repo.lastUid, 'one');
        expect(repo.lastName, name.trim());
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text(name.trim()), findsOneWidget);
        expect(find.text('Đã cập nhật tên hiển thị.'), findsOneWidget);
        expect(
          tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
          const Color(0xFF176B46),
        );
      },
    );
  }
  testWidgets('W06 read error shows retry, retry reloads profile', (
    tester,
  ) async {
    repo.readError = StateError('offline');
    await mount(tester);
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải hồ sơ'), findsOneWidget);
    expect(find.textContaining('Lỗi hồ sơ:'), findsOneWidget);
    repo.readError = null;
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(repo.reads, 2);
    expect(find.text('Player'), findsOneWidget);
  });
  testWidgets('W07 save failure displays snackbar and error state', (
    tester,
  ) async {
    await mount(tester);
    await tester.pumpAndSettle();
    repo.mutationError = StateError('permission-denied');
    await edit(tester);
    await tester.enterText(find.byType(TextField), 'New');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.textContaining('permission-denied'), findsOneWidget);
    expect(find.text('Không thể tải hồ sơ'), findsOneWidget);
  });
  testWidgets('W08 reset invokes ViewModel and restores default avatar', (
    tester,
  ) async {
    await mount(tester);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Khôi phục avatar mặc định'), 200);
    await tester.tap(find.text('Khôi phục avatar mặc định'));
    await tester.pumpAndSettle();
    expect(repo.resets, 1);
    expect(find.text('Đã khôi phục ảnh đại diện mặc định.'), findsOneWidget);
    expect(repo.lastUid, 'one');
    await tester.scrollUntilVisible(find.byIcon(Icons.person), -200);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('Profile displays local creation and update timestamps', (
    tester,
  ) async {
    repo.profile = UserProfile(
      uid: 'one',
      email: 'a@example.com',
      displayName: 'Player',
      createdAt: DateTime(2026, 10, 28, 9, 5, 2),
      updatedAt: DateTime(2026, 10, 29, 14, 30, 45),
    );
    await mount(tester);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    await tester.ensureVisible(find.text('Cập nhật lần cuối'));
    expect(find.text('28/10/2026 09:05:02'), findsOneWidget);
    expect(find.text('29/10/2026 14:30:45'), findsOneWidget);
  });
}
