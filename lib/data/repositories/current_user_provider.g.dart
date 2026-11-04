// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider lưu trữ mã định danh UID của người dùng hiện tại (mặc định là "demo_user")
/// Giúp phân tách dữ liệu cá nhân theo UID như quy định trong SDS 2.4 & BR-05.

@ProviderFor(CurrentUid)
final currentUidProvider = CurrentUidProvider._();

/// Riverpod provider lưu trữ mã định danh UID của người dùng hiện tại (mặc định là "demo_user")
/// Giúp phân tách dữ liệu cá nhân theo UID như quy định trong SDS 2.4 & BR-05.
final class CurrentUidProvider extends $NotifierProvider<CurrentUid, String> {
  /// Riverpod provider lưu trữ mã định danh UID của người dùng hiện tại (mặc định là "demo_user")
  /// Giúp phân tách dữ liệu cá nhân theo UID như quy định trong SDS 2.4 & BR-05.
  CurrentUidProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUidProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUidHash();

  @$internal
  @override
  CurrentUid create() => CurrentUid();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$currentUidHash() => r'54812b560a560f4e4c274fb8b40d287fa5b9945e';

/// Riverpod provider lưu trữ mã định danh UID của người dùng hiện tại (mặc định là "demo_user")
/// Giúp phân tách dữ liệu cá nhân theo UID như quy định trong SDS 2.4 & BR-05.

abstract class _$CurrentUid extends $Notifier<String> {
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
