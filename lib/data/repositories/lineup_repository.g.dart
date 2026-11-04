// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lineup_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lineupRepository)
final lineupRepositoryProvider = LineupRepositoryProvider._();

final class LineupRepositoryProvider
    extends
        $FunctionalProvider<
          LineupRepository,
          LineupRepository,
          LineupRepository
        >
    with $Provider<LineupRepository> {
  LineupRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lineupRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lineupRepositoryHash();

  @$internal
  @override
  $ProviderElement<LineupRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LineupRepository create(Ref ref) {
    return lineupRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LineupRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LineupRepository>(value),
    );
  }
}

String _$lineupRepositoryHash() => r'40f8689b086fd7cdfd1b2def391bbe51728fe030';
