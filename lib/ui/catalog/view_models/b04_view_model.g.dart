// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'b04_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(B04ViewModel)
final b04ViewModelProvider = B04ViewModelFamily._();

final class B04ViewModelProvider
    extends $AsyncNotifierProvider<B04ViewModel, Player> {
  B04ViewModelProvider._({
    required B04ViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'b04ViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$b04ViewModelHash();

  @override
  String toString() {
    return r'b04ViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  B04ViewModel create() => B04ViewModel();

  @override
  bool operator ==(Object other) {
    return other is B04ViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$b04ViewModelHash() => r'd3001ba1445e9e8fa14d568e919309c258ded405';

final class B04ViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          B04ViewModel,
          AsyncValue<Player>,
          Player,
          FutureOr<Player>,
          String
        > {
  B04ViewModelFamily._()
    : super(
        retry: null,
        name: r'b04ViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  B04ViewModelProvider call(String playerId) =>
      B04ViewModelProvider._(argument: playerId, from: this);

  @override
  String toString() => r'b04ViewModelProvider';
}

abstract class _$B04ViewModel extends $AsyncNotifier<Player> {
  late final _$args = ref.$arg as String;
  String get playerId => _$args;

  FutureOr<Player> build(String playerId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Player>, Player>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Player>, Player>,
              AsyncValue<Player>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
