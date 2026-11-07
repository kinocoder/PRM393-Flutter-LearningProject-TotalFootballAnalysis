import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/model/player_query.dart';
import '../../../data/repositories/player_repository.dart';
part 'b03_view_model.g.dart';

/// Provider toàn cục lưu bộ lọc đang áp dụng cho Catalog (B01 đọc, B03 ghi)
@Riverpod(keepAlive: true)
class CatalogFilter extends _$CatalogFilter {
  @override
  PlayerQuery build() {
    return const PlayerQuery();
  }

  void update(PlayerQuery query) {
    state = query;
  }

  void reset() {
    state = const PlayerQuery();
  }
}

/// Trạng thái giao diện của màn hình B03
class B03State {
  final PlayerQuery draftQuery; // Bộ lọc bản nháp người dùng đang tinh chỉnh
  final Map<String, List<String>>
  filterOptions; // Danh sách tùy chọn thực tế từ dữ liệu (BR-11)
  final int matchedCount; // Số lượng kết quả khớp tính trước (Preview count)

  const B03State({
    required this.draftQuery,
    required this.filterOptions,
    required this.matchedCount,
  });

  B03State copyWith({
    PlayerQuery? draftQuery,
    Map<String, List<String>>? filterOptions,
    int? matchedCount,
  }) {
    return B03State(
      draftQuery: draftQuery ?? this.draftQuery,
      filterOptions: filterOptions ?? this.filterOptions,
      matchedCount: matchedCount ?? this.matchedCount,
    );
  }
}

/// ViewModel quản lý màn hình bộ lọc B03 (Auto-dispose khi thoát màn hình)
@riverpod
class B03ViewModel extends _$B03ViewModel {
  @override
  B03State build() {
    final appliedQuery = ref.watch(catalogFilterProvider);
    final initial = B03State(
      draftQuery: appliedQuery,
      filterOptions: const {},
      matchedCount: 0,
    );
    var disposed = false;
    ref.onDispose(() => disposed = true);
    Future<void>(() async {
      final repo = ref.read(playerRepositoryProvider);
      final options = await repo.getFilterOptions();
      final count = (await repo.filterPlayers(appliedQuery)).length;
      if (!disposed) {
        state = initial.copyWith(filterOptions: options, matchedCount: count);
      }
    });
    return initial;
  }

  /// Cập nhật nháp và tính lại số cầu thủ khớp ngay lập tức
  void _updateDraft(PlayerQuery newDraft) {
    state = state.copyWith(draftQuery: newDraft);
    Future<void>(() async {
      final count =
          (await ref.read(playerRepositoryProvider).filterPlayers(newDraft))
              .length;
      state = state.copyWith(matchedCount: count);
    });
  }

  /// Bật / tắt chọn vị trí thi đấu (cho phép chọn nhiều)
  void togglePosition(String pos) {
    final positions = List<String>.from(state.draftQuery.positions);
    if (positions.contains(pos)) {
      positions.remove(pos);
    } else {
      positions.add(pos);
    }
    _updateDraft(state.draftQuery.copyWith(positions: positions));
  }

  /// Chọn Câu lạc bộ
  void selectClub(String? club) {
    _updateDraft(
      state.draftQuery.copyWith(club: club, clearClub: club == null),
    );
  }

  /// Chọn Quốc gia / Quốc tịch
  void selectNation(String? nation) {
    _updateDraft(
      state.draftQuery.copyWith(nation: nation, clearNation: nation == null),
    );
  }

  /// Chọn Mùa thẻ (Card Version)
  void selectCardVersion(String? version) {
    _updateDraft(
      state.draftQuery.copyWith(
        cardVersion: version,
        clearCardVersion: version == null,
      ),
    );
  }

  /// Thay đổi chỉ số OVR tối thiểu
  void setMinOvr(int? ovr) {
    _updateDraft(
      state.draftQuery.copyWith(minOvr: ovr, clearMinOvr: ovr == null),
    );
  }

  /// Thay đổi kiểu sắp xếp ('ovr_desc', 'ovr_asc', 'name_asc')
  void setSort(String sort) {
    _updateDraft(state.draftQuery.copyWith(sort: sort));
  }

  /// Đặt lại toàn bộ bộ lọc nháp về mặc định
  void resetFilter() {
    const defaultQuery = PlayerQuery();
    _updateDraft(defaultQuery);
  }

  /// Nhấn nút "Áp dụng": Ghi đè bản nháp vào catalogFilterProvider dùng chung
  void applyFilter() {
    ref.read(catalogFilterProvider.notifier).update(state.draftQuery);
  }
}
