import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user_provider.g.dart';

/// Riverpod provider lưu trữ mã định danh UID của người dùng hiện tại (mặc định là "demo_user")
/// Giúp phân tách dữ liệu cá nhân theo UID như quy định trong SDS 2.4 & BR-05.
@riverpod
class CurrentUid extends _$CurrentUid {
  @override
  String build() => 'demo_user';

  void setUid(String uid) {
    state = uid;
  }
}
