// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VerifyEmailViewModel)
final verifyEmailViewModelProvider = VerifyEmailViewModelProvider._();

final class VerifyEmailViewModelProvider
    extends $NotifierProvider<VerifyEmailViewModel, VerificationAction> {
  VerifyEmailViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifyEmailViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verifyEmailViewModelHash();

  @$internal
  @override
  VerifyEmailViewModel create() => VerifyEmailViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerificationAction value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerificationAction>(value),
    );
  }
}

String _$verifyEmailViewModelHash() =>
    r'7978ed343a1cc564b5b2abe0d5cb0af1086b22a8';

abstract class _$VerifyEmailViewModel extends $Notifier<VerificationAction> {
  VerificationAction build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VerificationAction, VerificationAction>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VerificationAction, VerificationAction>,
              VerificationAction,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
