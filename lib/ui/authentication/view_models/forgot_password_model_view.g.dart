// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_model_view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ForgotPasswordModelView)
final forgotPasswordModelViewProvider = ForgotPasswordModelViewProvider._();

final class ForgotPasswordModelViewProvider
    extends $AsyncNotifierProvider<ForgotPasswordModelView, void> {
  ForgotPasswordModelViewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgotPasswordModelViewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgotPasswordModelViewHash();

  @$internal
  @override
  ForgotPasswordModelView create() => ForgotPasswordModelView();
}

String _$forgotPasswordModelViewHash() =>
    r'af2142205ce66e89b3031889ef216301a69886c4';

abstract class _$ForgotPasswordModelView extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
