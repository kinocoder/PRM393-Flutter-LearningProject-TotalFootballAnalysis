import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/lineup_repository.dart';
import '../services/lineup_firestore_service.dart';
import '../services/lineup_local_service.dart';
import 'core_providers.dart';

final lineupRepositoryProvider = Provider<LineupRepository>((ref) {
  final remote = ref.watch(firebaseReadyProvider)
      ? LineupFirestoreService(FirebaseFirestore.instance)
      : null;
  return DefaultLineupRepository(
    local: LineupLocalService(ref.watch(databaseProvider)),
    remote: remote,
  );
});
