// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'c01_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// C01 — Danh sách đội hình.

@ProviderFor(C01ViewModel)
final c01ViewModelProvider = C01ViewModelProvider._();

/// C01 — Danh sách đội hình.
final class C01ViewModelProvider
    extends $AsyncNotifierProvider<C01ViewModel, List<Lineup>> {
  /// C01 — Danh sách đội hình.
  C01ViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'c01ViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$c01ViewModelHash();

  @$internal
  @override
  C01ViewModel create() => C01ViewModel();
}

String _$c01ViewModelHash() => r'f6957a1b1cd5c89cb37acbaf1c92a8d506848c98';

/// C01 — Danh sách đội hình.

abstract class _$C01ViewModel extends $AsyncNotifier<List<Lineup>> {
  FutureOr<List<Lineup>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Lineup>>, List<Lineup>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Lineup>>, List<Lineup>>,
              AsyncValue<List<Lineup>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
