import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/player.dart';
import '../../../data/repositories/player_repository.dart';
part 'b04_view_model.g.dart';

@riverpod
class B04ViewModel extends _$B04ViewModel {
  @override
  Future<Player> build(String playerId) async {
    final repo = ref.watch(playerRepositoryProvider);
    final player = await repo.getPlayerByID(playerId);
    if (player == null) {
      throw Exception('Không tìm thấy thông tin cầu thủ (ID: $playerId)');
    }

    return player;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(playerRepositoryProvider);
      final player = await repo.getPlayerByID(playerId);
      if (player == null) {
        throw Exception('Không tìm thấy thông tin cầu thủ (ID: $playerId)');
      }
      return player;
    });
  }
}