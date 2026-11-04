// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

part of 'collection_view_models.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(MyCollection)
final myCollectionProvider = MyCollectionProvider._();

final class MyCollectionProvider
    extends $AsyncNotifierProvider<MyCollection, List<CollectionEntry>> {
  MyCollectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCollectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => r'my-collection';

  @$internal
  @override
  MyCollection create() => MyCollection();
}

abstract class _$MyCollection extends $AsyncNotifier<List<CollectionEntry>> {
  FutureOr<List<CollectionEntry>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<CollectionEntry>>, List<CollectionEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<CollectionEntry>>,
                List<CollectionEntry>
              >,
              AsyncValue<List<CollectionEntry>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(collectionCandidates)
final collectionCandidatesProvider = CollectionCandidatesProvider._();

final class CollectionCandidatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Player>>,
          List<Player>,
          FutureOr<List<Player>>
        >
    with $FutureModifier<List<Player>>, $FutureProvider<List<Player>> {
  CollectionCandidatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionCandidatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => r'collection-candidates';

  @$internal
  @override
  $FutureProviderElement<List<Player>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Player>> create(Ref ref) => collectionCandidates(ref);
}

@ProviderFor(FavoritePlayerIds)
final favoritePlayerIdsProvider = FavoritePlayerIdsProvider._();

final class FavoritePlayerIdsProvider
    extends $AsyncNotifierProvider<FavoritePlayerIds, Set<String>> {
  FavoritePlayerIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritePlayerIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => r'favorite-player-ids';

  @$internal
  @override
  FavoritePlayerIds create() => FavoritePlayerIds();
}

abstract class _$FavoritePlayerIds extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(CollectionComparisonHistory)
final collectionComparisonHistoryProvider =
    CollectionComparisonHistoryProvider._();

final class CollectionComparisonHistoryProvider
    extends
        $AsyncNotifierProvider<
          CollectionComparisonHistory,
          List<ComparisonRecord>
        > {
  CollectionComparisonHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionComparisonHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => r'collection-comparison-history';

  @$internal
  @override
  CollectionComparisonHistory create() => CollectionComparisonHistory();
}

abstract class _$CollectionComparisonHistory
    extends $AsyncNotifier<List<ComparisonRecord>> {
  FutureOr<List<ComparisonRecord>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ComparisonRecord>>, List<ComparisonRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ComparisonRecord>>,
                List<ComparisonRecord>
              >,
              AsyncValue<List<ComparisonRecord>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
