// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserProfileViewModel)
final userProfileViewModelProvider = UserProfileViewModelFamily._();

final class UserProfileViewModelProvider
    extends $AsyncNotifierProvider<UserProfileViewModel, UserProfile> {
  UserProfileViewModelProvider._({
    required UserProfileViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userProfileViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userProfileViewModelHash();

  @override
  String toString() {
    return r'userProfileViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserProfileViewModel create() => UserProfileViewModel();

  @override
  bool operator ==(Object other) {
    return other is UserProfileViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileViewModelHash() =>
    r'76371cda2a0403091a59bdc9150a1691e583490e';

final class UserProfileViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          UserProfileViewModel,
          AsyncValue<UserProfile>,
          UserProfile,
          FutureOr<UserProfile>,
          String
        > {
  UserProfileViewModelFamily._()
    : super(
        retry: null,
        name: r'userProfileViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserProfileViewModelProvider call(String uid) =>
      UserProfileViewModelProvider._(argument: uid, from: this);

  @override
  String toString() => r'userProfileViewModelProvider';
}

abstract class _$UserProfileViewModel extends $AsyncNotifier<UserProfile> {
  late final _$args = ref.$arg as String;
  String get uid => _$args;

  FutureOr<UserProfile> build(String uid);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}
