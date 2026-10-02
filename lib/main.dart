import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/providers/core_providers.dart';
import 'data/services/local_database_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseReady = await _initFirebase();
  final database = await LocalDatabaseService.open();

  runApp(
    ProviderScope(
      overrides: [
        firebaseReadyProvider.overrideWithValue(firebaseReady),
        databaseProvider.overrideWithValue(database),
      ],
      child: const App(),
    ),
  );
}

/// Chưa chạy `flutterfire configure` thì app vẫn chạy (chỉ lưu trên máy).
Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return true;
  } catch (e) {
    debugPrint('Firebase chưa sẵn sàng, chạy chế độ local: $e');
    return false;
  }
}
