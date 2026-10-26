import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/player.dart';
import '../../../data/repositories/player_repository.dart';
part 'b02_view_model.g.dart';

class SearchState {
  final String query;
  final bool isLoading;
  final List<Player> results;

  const SearchState({
    this.query = '',
    this.isLoading = false,
    this.results = const [],
  });

  bool get isInitial => query.trim().isEmpty;
  bool get isEmptyResult => !isInitial && !isLoading && results.isEmpty;

  SearchState copyWith({
    String? query,
    bool? isLoading,
    List<Player>? results,
  }) {
    return SearchState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
    );
  }
}

@riverpod
class B02ViewModel extends _$B02ViewModel {
  Timer? _debounceTimer;
  int _latestRequestId = 0;

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const SearchState();
  }

  void onQueryChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      _latestRequestId++;
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: query, isLoading: true);

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    final currentRequestId = ++_latestRequestId;

    final repository = ref.read(playerRepositoryProvider);
    final searchResults = await repository.searchPlayers(query);

    if (currentRequestId == _latestRequestId) {
      state = state.copyWith(
        isLoading: false,
        results: searchResults,
      );
    }
  }

  void clearQuery() {
    _debounceTimer?.cancel();
    _latestRequestId++;
    state = const SearchState();
  }
}