// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'b01_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(B01ViewModel)
final b01ViewModelProvider = B01ViewModelProvider._();

final class B01ViewModelProvider
    extends $AsyncNotifierProvider<B01ViewModel, List<Player>> {
  B01ViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'b01ViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$b01ViewModelHash();

  @$internal
  @override
  B01ViewModel create() => B01ViewModel();
}

String _$b01ViewModelHash() => r'f53ff8b2c0b555fba2ec033de84936e58501c9b1';

abstract class _$B01ViewModel extends $AsyncNotifier<List<Player>> {
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
