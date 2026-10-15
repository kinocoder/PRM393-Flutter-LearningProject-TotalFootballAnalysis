import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/player.dart';
import '../../../data/repositories/player_repository.dart';
part 'b01_view_model.g.dart';

@riverpod
class B01ViewModel extends _$B01ViewModel {
  @override
  FutureOr<List<Player>> build() async {
    return _fetchPlayers();
  }

  Future<List<Player>> _fetchPlayers() async {
    final repository = ref.read(playerRepositoryProvider);
    return await repository.getPlayers();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPlayers());
  }
}
