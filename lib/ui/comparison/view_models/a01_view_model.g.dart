// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'a01_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider dùng chung lưu trữ danh sách các playerId được chọn so sánh (SDS 2.4 & 3.1)
/// Được dùng chung giữa các màn hình A01, B04, E03, E04.

@ProviderFor(CompareSelection)
final compareSelectionProvider = CompareSelectionProvider._();

/// Provider dùng chung lưu trữ danh sách các playerId được chọn so sánh (SDS 2.4 & 3.1)
/// Được dùng chung giữa các màn hình A01, B04, E03, E04.
final class CompareSelectionProvider
    extends $NotifierProvider<CompareSelection, List<String>> {
  /// Provider dùng chung lưu trữ danh sách các playerId được chọn so sánh (SDS 2.4 & 3.1)
  /// Được dùng chung giữa các màn hình A01, B04, E03, E04.
  CompareSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'compareSelectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$compareSelectionHash();

  @$internal
  @override
  CompareSelection create() => CompareSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$compareSelectionHash() => r'2282e2c3e87ffae8566f523dce9505665457a90f';

/// Provider dùng chung lưu trữ danh sách các playerId được chọn so sánh (SDS 2.4 & 3.1)
/// Được dùng chung giữa các màn hình A01, B04, E03, E04.

abstract class _$CompareSelection extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider lưu trữ từ khóa tìm kiếm tại màn hình A01

@ProviderFor(A01SearchQuery)
final a01SearchQueryProvider = A01SearchQueryProvider._();

/// Provider lưu trữ từ khóa tìm kiếm tại màn hình A01
final class A01SearchQueryProvider
    extends $NotifierProvider<A01SearchQuery, String> {
  /// Provider lưu trữ từ khóa tìm kiếm tại màn hình A01
  A01SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'a01SearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$a01SearchQueryHash();

  @$internal
  @override
  A01SearchQuery create() => A01SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$a01SearchQueryHash() => r'd5d36d45cd15cc77b43261075fa661cb34f2919a';

/// Provider lưu trữ từ khóa tìm kiếm tại màn hình A01

abstract class _$A01SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider truy vấn danh sách cầu thủ ứng viên theo từ khóa tìm kiếm (bỏ dấu)

@ProviderFor(a01CandidatePlayers)
final a01CandidatePlayersProvider = A01CandidatePlayersProvider._();

/// Provider truy vấn danh sách cầu thủ ứng viên theo từ khóa tìm kiếm (bỏ dấu)

final class A01CandidatePlayersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Player>>,
          List<Player>,
          FutureOr<List<Player>>
        >
    with $FutureModifier<List<Player>>, $FutureProvider<List<Player>> {
  /// Provider truy vấn danh sách cầu thủ ứng viên theo từ khóa tìm kiếm (bỏ dấu)
  A01CandidatePlayersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'a01CandidatePlayersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$a01CandidatePlayersHash();

  @$internal
  @override
  $FutureProviderElement<List<Player>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Player>> create(Ref ref) {
    return a01CandidatePlayers(ref);
  }
}

String _$a01CandidatePlayersHash() =>
    r'33aad298ff2e260ec9af3fd6dd8ddab7dae9d72e';
