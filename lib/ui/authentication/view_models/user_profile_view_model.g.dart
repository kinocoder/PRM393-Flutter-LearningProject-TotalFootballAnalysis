// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserProfileViewModel)
final userProfileViewModelProvider = UserProfileViewModelProvider._();

final class UserProfileViewModelProvider
    extends $AsyncNotifierProvider<UserProfileViewModel, UserProfile> {
  UserProfileViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileViewModelHash();

  @$internal
  @override
  UserProfileViewModel create() => UserProfileViewModel();
}

String _$userProfileViewModelHash() =>
    r'310d3644a9b2f85492e930aa28633d8fef97986e';

abstract class _$UserProfileViewModel extends $AsyncNotifier<UserProfile> {
  FutureOr<UserProfile> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserProfile>, UserProfile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfile>, UserProfile>,
              AsyncValue<UserProfile>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
