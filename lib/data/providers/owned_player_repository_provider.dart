import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/owned_player_repository.dart';
import '../services/owned_player_service.dart';
import 'core_providers.dart';

final ownedPlayerRepositoryProvider = Provider<OwnedPlayerRepository>(
  (ref) => SqliteOwnedPlayerRepository(OwnedPlayerService(ref.watch(databaseProvider))),
);
