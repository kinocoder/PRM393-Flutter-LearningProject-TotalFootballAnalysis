// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'b03_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider toàn cục lưu bộ lọc đang áp dụng cho Catalog (B01 đọc, B03 ghi)

@ProviderFor(CatalogFilter)
final catalogFilterProvider = CatalogFilterProvider._();

/// Provider toàn cục lưu bộ lọc đang áp dụng cho Catalog (B01 đọc, B03 ghi)
final class CatalogFilterProvider
    extends $NotifierProvider<CatalogFilter, PlayerQuery> {
  /// Provider toàn cục lưu bộ lọc đang áp dụng cho Catalog (B01 đọc, B03 ghi)
  CatalogFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogFilterHash();

  @$internal
  @override
  CatalogFilter create() => CatalogFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerQuery>(value),
    );
  }
}

String _$catalogFilterHash() => r'402ce4b17f2f28624b9c2e79c158f817ff0886ca';

/// Provider toàn cục lưu bộ lọc đang áp dụng cho Catalog (B01 đọc, B03 ghi)

abstract class _$CatalogFilter extends $Notifier<PlayerQuery> {
  PlayerQuery build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlayerQuery, PlayerQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayerQuery, PlayerQuery>,
              PlayerQuery,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// ViewModel quản lý màn hình bộ lọc B03 (Auto-dispose khi thoát màn hình)

@ProviderFor(B03ViewModel)
final b03ViewModelProvider = B03ViewModelProvider._();

/// ViewModel quản lý màn hình bộ lọc B03 (Auto-dispose khi thoát màn hình)
final class B03ViewModelProvider
    extends $NotifierProvider<B03ViewModel, B03State> {
  /// ViewModel quản lý màn hình bộ lọc B03 (Auto-dispose khi thoát màn hình)
  B03ViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'b03ViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$b03ViewModelHash();

  @$internal
  @override
  B03ViewModel create() => B03ViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(B03State value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<B03State>(value),
    );
  }
}

String _$b03ViewModelHash() => r'2992fdf2e4ebe8e5b09d0cb4d0b76c75af9715c3';

/// ViewModel quản lý màn hình bộ lọc B03 (Auto-dispose khi thoát màn hình)

abstract class _$B03ViewModel extends $Notifier<B03State> {
  B03State build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<B03State, B03State>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<B03State, B03State>,
              B03State,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
