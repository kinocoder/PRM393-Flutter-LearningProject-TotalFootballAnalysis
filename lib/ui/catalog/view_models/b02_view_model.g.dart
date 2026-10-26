// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'b02_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(B02ViewModel)
final b02ViewModelProvider = B02ViewModelProvider._();

final class B02ViewModelProvider
    extends $NotifierProvider<B02ViewModel, SearchState> {
  B02ViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'b02ViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$b02ViewModelHash();

  @$internal
  @override
  B02ViewModel create() => B02ViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$b02ViewModelHash() => r'd26f450e8a971950221eb74ed7039078ab85b8c3';

abstract class _$B02ViewModel extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
