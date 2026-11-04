// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'a03_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel quản lý dữ liệu so sánh kỹ thuật đặc biệt cho màn hình A03

@ProviderFor(A03ViewModel)
final a03ViewModelProvider = A03ViewModelProvider._();

/// ViewModel quản lý dữ liệu so sánh kỹ thuật đặc biệt cho màn hình A03
final class A03ViewModelProvider
    extends $AsyncNotifierProvider<A03ViewModel, A03ComparisonState> {
  /// ViewModel quản lý dữ liệu so sánh kỹ thuật đặc biệt cho màn hình A03
  A03ViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'a03ViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$a03ViewModelHash();

  @$internal
  @override
  A03ViewModel create() => A03ViewModel();
}

String _$a03ViewModelHash() => r'636d2a76a1e7eb82aa773e4dea8ac1fc9cbc9650';

/// ViewModel quản lý dữ liệu so sánh kỹ thuật đặc biệt cho màn hình A03

abstract class _$A03ViewModel extends $AsyncNotifier<A03ComparisonState> {
  FutureOr<A03ComparisonState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<A03ComparisonState>, A03ComparisonState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<A03ComparisonState>, A03ComparisonState>,
              AsyncValue<A03ComparisonState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
