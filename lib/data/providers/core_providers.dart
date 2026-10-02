import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

/// `true` nếu `Firebase.initializeApp` thành công (đặt trong main.dart).
final firebaseReadyProvider = Provider<bool>((ref) => false);

/// Database SQLite đã mở sẵn trong main.dart.
final databaseProvider = Provider<Database>(
  (ref) => throw UnimplementedError('databaseProvider phải được override trong main()'),
);
