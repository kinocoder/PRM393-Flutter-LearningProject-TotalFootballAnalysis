// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'a04_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider quản lý cấu hình tiêu chí đánh giá cho màn hình A04

@ProviderFor(A04Config)
final a04ConfigProvider = A04ConfigProvider._();

/// Provider quản lý cấu hình tiêu chí đánh giá cho màn hình A04
final class A04ConfigProvider
    extends $NotifierProvider<A04Config, ScoringConfig> {
  /// Provider quản lý cấu hình tiêu chí đánh giá cho màn hình A04
  A04ConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'a04ConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$a04ConfigHash();

  @$internal
  @override
  A04Config create() => A04Config();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScoringConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScoringConfig>(value),
    );
  }
}

String _$a04ConfigHash() => r'26bbc2e4b15faa2b0c3705b3fe252e1bbaa77054';

/// Provider quản lý cấu hình tiêu chí đánh giá cho màn hình A04

abstract class _$A04Config extends $Notifier<ScoringConfig> {
  ScoringConfig build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ScoringConfig, ScoringConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScoringConfig, ScoringConfig>,
              ScoringConfig,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider tính toán điểm đánh giá và xếp hạng cầu thủ theo cấu hình trọng số A04

@ProviderFor(a04ScoreResults)
final a04ScoreResultsProvider = A04ScoreResultsProvider._();

/// Provider tính toán điểm đánh giá và xếp hạng cầu thủ theo cấu hình trọng số A04

final class A04ScoreResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlayerScoreResult>>,
          List<PlayerScoreResult>,
          FutureOr<List<PlayerScoreResult>>
        >
    with
        $FutureModifier<List<PlayerScoreResult>>,
        $FutureProvider<List<PlayerScoreResult>> {
  /// Provider tính toán điểm đánh giá và xếp hạng cầu thủ theo cấu hình trọng số A04
  A04ScoreResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'a04ScoreResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$a04ScoreResultsHash();

  @$internal
  @override
  $FutureProviderElement<List<PlayerScoreResult>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlayerScoreResult>> create(Ref ref) {
    return a04ScoreResults(ref);
  }
}

String _$a04ScoreResultsHash() => r'af3d09db61cb52a9bcc161c8cdf17a1bde3027e6';

/// Provider thực hiện thao tác lưu kết quả so sánh vào lịch sử (BR-05, BR-10)

@ProviderFor(saveComparisonResult)
final saveComparisonResultProvider = SaveComparisonResultProvider._();

/// Provider thực hiện thao tác lưu kết quả so sánh vào lịch sử (BR-05, BR-10)

final class SaveComparisonResultProvider
    extends
        $FunctionalProvider<
          Future<void> Function(),
          Future<void> Function(),
          Future<void> Function()
        >
    with $Provider<Future<void> Function()> {
  /// Provider thực hiện thao tác lưu kết quả so sánh vào lịch sử (BR-05, BR-10)
  SaveComparisonResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveComparisonResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveComparisonResultHash();

  @$internal
  @override
  $ProviderElement<Future<void> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<void> Function() create(Ref ref) {
    return saveComparisonResult(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<void> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<void> Function()>(value),
    );
  }
}

String _$saveComparisonResultHash() =>
    r'9b98131b49eec5c6fa469010625d17c86abca660';
