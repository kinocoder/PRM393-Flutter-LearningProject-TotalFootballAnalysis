// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logout_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LogoutViewModel)
final logoutViewModelProvider = LogoutViewModelProvider._();

final class LogoutViewModelProvider
    extends $NotifierProvider<LogoutViewModel, AsyncValue<void>> {
  LogoutViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logoutViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logoutViewModelHash();

  @$internal
  @override
  LogoutViewModel create() => LogoutViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$logoutViewModelHash() => r'56f6a9cea26b1e803e7c4b55395a657644c8f5e8';

abstract class _$LogoutViewModel extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
