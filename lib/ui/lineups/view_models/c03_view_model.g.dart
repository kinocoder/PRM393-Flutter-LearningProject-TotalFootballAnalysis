// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'c03_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// C03 — Chọn cầu thủ cho một vị trí.
///
/// Ứng viên là cầu thủ người dùng sở hữu: lấy ID từ bộ sưu tập của mảng E,
/// rồi lấy thông tin từ PlayerRepository của mảng B.

@ProviderFor(C03ViewModel)
final c03ViewModelProvider = C03ViewModelProvider._();

/// C03 — Chọn cầu thủ cho một vị trí.
///
/// Ứng viên là cầu thủ người dùng sở hữu: lấy ID từ bộ sưu tập của mảng E,
/// rồi lấy thông tin từ PlayerRepository của mảng B.
final class C03ViewModelProvider
    extends $AsyncNotifierProvider<C03ViewModel, List<Player>> {
  /// C03 — Chọn cầu thủ cho một vị trí.
  ///
  /// Ứng viên là cầu thủ người dùng sở hữu: lấy ID từ bộ sưu tập của mảng E,
  /// rồi lấy thông tin từ PlayerRepository của mảng B.
  C03ViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'c03ViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$c03ViewModelHash();

  @$internal
  @override
  C03ViewModel create() => C03ViewModel();
}

String _$c03ViewModelHash() => r'353681002b81eeaa58df83a486657fa71a85c0cb';

/// C03 — Chọn cầu thủ cho một vị trí.
///
/// Ứng viên là cầu thủ người dùng sở hữu: lấy ID từ bộ sưu tập của mảng E,
/// rồi lấy thông tin từ PlayerRepository của mảng B.

abstract class _$C03ViewModel extends $AsyncNotifier<List<Player>> {
  FutureOr<List<Player>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Player>>, List<Player>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Player>>, List<Player>>,
              AsyncValue<List<Player>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
