import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import '../repositories/player_repository.dart';
import '../services/player_api_service.dart';
import '../services/player_cache_service.dart';
import '../services/sample_player_service.dart';
import 'core_providers.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  final api = PlayerApiService(baseUrl: AppConfig.apiBaseUrl, timeout: AppConfig.requestTimeout);
  ref.onDispose(api.close);
  return DefaultPlayerRepository(
    api: api,
    cache: PlayerCacheService(ref.watch(databaseProvider)),
    sample: SamplePlayerService(),
  );
});
