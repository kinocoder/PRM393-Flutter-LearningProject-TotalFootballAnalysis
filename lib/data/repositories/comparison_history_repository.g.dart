// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comparison_history_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider cấp phát đối tượng ComparisonHistoryRepository cho toàn ứng dụng

@ProviderFor(comparisonHistoryRepository)
final comparisonHistoryRepositoryProvider =
    ComparisonHistoryRepositoryProvider._();

/// Provider cấp phát đối tượng ComparisonHistoryRepository cho toàn ứng dụng

final class ComparisonHistoryRepositoryProvider
    extends
        $FunctionalProvider<
          ComparisonHistoryRepository,
          ComparisonHistoryRepository,
          ComparisonHistoryRepository
        >
    with $Provider<ComparisonHistoryRepository> {
  /// Provider cấp phát đối tượng ComparisonHistoryRepository cho toàn ứng dụng
  ComparisonHistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'comparisonHistoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$comparisonHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ComparisonHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ComparisonHistoryRepository create(Ref ref) {
    return comparisonHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ComparisonHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ComparisonHistoryRepository>(value),
    );
  }
}

String _$comparisonHistoryRepositoryHash() =>
    r'ef2993982031ec5fadcc808de7c48ea59d374d3d';
