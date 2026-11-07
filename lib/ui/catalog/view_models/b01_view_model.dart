import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/player.dart';
import '../../../data/repositories/player_repository.dart';
import 'b03_view_model.dart';

part 'b01_view_model.g.dart';

@riverpod
class B01ViewModel extends _$B01ViewModel {
  @override
  FutureOr<List<Player>> build() async {
    final filter = ref.watch(catalogFilterProvider);
    final repository = ref.watch(playerRepositoryProvider);
    return repository.filterPlayers(filter);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final filter = ref.read(catalogFilterProvider);
      final repository = ref.read(playerRepositoryProvider);
      return repository.filterPlayers(filter);
    });
  }
}
