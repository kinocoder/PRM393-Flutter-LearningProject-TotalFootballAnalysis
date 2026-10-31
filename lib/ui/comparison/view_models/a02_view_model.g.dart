// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'a02_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel quản lý dữ liệu so sánh chỉ số cho màn hình A02

@ProviderFor(A02ViewModel)
final a02ViewModelProvider = A02ViewModelProvider._();

/// ViewModel quản lý dữ liệu so sánh chỉ số cho màn hình A02
final class A02ViewModelProvider
    extends $AsyncNotifierProvider<A02ViewModel, StatComparisonState> {
  /// ViewModel quản lý dữ liệu so sánh chỉ số cho màn hình A02
  A02ViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'a02ViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$a02ViewModelHash();

  @$internal
  @override
  A02ViewModel create() => A02ViewModel();
}

String _$a02ViewModelHash() => r'4791b457782848921f1b0ca4229f83171c3cd810';

/// ViewModel quản lý dữ liệu so sánh chỉ số cho màn hình A02

abstract class _$A02ViewModel extends $AsyncNotifier<StatComparisonState> {
  FutureOr<StatComparisonState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<StatComparisonState>, StatComparisonState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<StatComparisonState>, StatComparisonState>,
              AsyncValue<StatComparisonState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
