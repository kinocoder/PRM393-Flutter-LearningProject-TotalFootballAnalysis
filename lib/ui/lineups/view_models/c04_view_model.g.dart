// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'c04_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Thông tin cầu thủ để hiện trên sân. Lấy cả danh mục, vì cầu thủ đã xếp
/// có thể đã bị gỡ khỏi bộ sưu tập nhưng vẫn cần hiện đúng tên.

@ProviderFor(c04Players)
final c04PlayersProvider = C04PlayersProvider._();

/// Thông tin cầu thủ để hiện trên sân. Lấy cả danh mục, vì cầu thủ đã xếp
/// có thể đã bị gỡ khỏi bộ sưu tập nhưng vẫn cần hiện đúng tên.

final class C04PlayersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Player>>,
          List<Player>,
          FutureOr<List<Player>>
        >
    with $FutureModifier<List<Player>>, $FutureProvider<List<Player>> {
  /// Thông tin cầu thủ để hiện trên sân. Lấy cả danh mục, vì cầu thủ đã xếp
  /// có thể đã bị gỡ khỏi bộ sưu tập nhưng vẫn cần hiện đúng tên.
  C04PlayersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'c04PlayersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$c04PlayersHash();

  @$internal
  @override
  $FutureProviderElement<List<Player>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Player>> create(Ref ref) {
    return c04Players(ref);
  }
}

String _$c04PlayersHash() => r'8ef03923366caeaaf7d62a748b17f3f87a614adb';

/// C04 — Đội hình đang sửa trên sân.
///
/// C02 (đổi sơ đồ) và C03 (chọn cầu thủ) cũng sửa vào đây.
/// Mọi thay đổi chỉ nằm trong bộ nhớ; bấm "Lưu" mới ghi vào repository.

@ProviderFor(C04ViewModel)
final c04ViewModelProvider = C04ViewModelFamily._();

/// C04 — Đội hình đang sửa trên sân.
///
/// C02 (đổi sơ đồ) và C03 (chọn cầu thủ) cũng sửa vào đây.
/// Mọi thay đổi chỉ nằm trong bộ nhớ; bấm "Lưu" mới ghi vào repository.
final class C04ViewModelProvider
    extends $AsyncNotifierProvider<C04ViewModel, Lineup> {
  /// C04 — Đội hình đang sửa trên sân.
  ///
  /// C02 (đổi sơ đồ) và C03 (chọn cầu thủ) cũng sửa vào đây.
  /// Mọi thay đổi chỉ nằm trong bộ nhớ; bấm "Lưu" mới ghi vào repository.
  C04ViewModelProvider._({
    required C04ViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'c04ViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$c04ViewModelHash();

  @override
  String toString() {
    return r'c04ViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  C04ViewModel create() => C04ViewModel();

  @override
  bool operator ==(Object other) {
    return other is C04ViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$c04ViewModelHash() => r'b0dd51173e50b9fe6170f159f42f37f3c910718e';

/// C04 — Đội hình đang sửa trên sân.
///
/// C02 (đổi sơ đồ) và C03 (chọn cầu thủ) cũng sửa vào đây.
/// Mọi thay đổi chỉ nằm trong bộ nhớ; bấm "Lưu" mới ghi vào repository.

final class C04ViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          C04ViewModel,
          AsyncValue<Lineup>,
          Lineup,
          FutureOr<Lineup>,
          String
        > {
  C04ViewModelFamily._()
    : super(
        retry: null,
        name: r'c04ViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// C04 — Đội hình đang sửa trên sân.
  ///
  /// C02 (đổi sơ đồ) và C03 (chọn cầu thủ) cũng sửa vào đây.
  /// Mọi thay đổi chỉ nằm trong bộ nhớ; bấm "Lưu" mới ghi vào repository.

  C04ViewModelProvider call(String lineupId) =>
      C04ViewModelProvider._(argument: lineupId, from: this);

  @override
  String toString() => r'c04ViewModelProvider';
}

/// C04 — Đội hình đang sửa trên sân.
///
/// C02 (đổi sơ đồ) và C03 (chọn cầu thủ) cũng sửa vào đây.
/// Mọi thay đổi chỉ nằm trong bộ nhớ; bấm "Lưu" mới ghi vào repository.

abstract class _$C04ViewModel extends $AsyncNotifier<Lineup> {
  late final _$args = ref.$arg as String;
  String get lineupId => _$args;

  FutureOr<Lineup> build(String lineupId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Lineup>, Lineup>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Lineup>, Lineup>,
              AsyncValue<Lineup>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
