/// Người dùng của phiên đăng nhập hiện tại.
///
/// Phần C chỉ cần `uid` để tách dữ liệu đội hình theo tài khoản. Nghiệp vụ
/// đăng nhập/đăng ký thuộc mảng D.
class AppUser {
  const AppUser({required this.uid, required this.email, this.displayName});

  final String uid;
  final String email;
  final String? displayName;

  @override
  bool operator ==(Object other) => other is AppUser && other.uid == uid;

  @override
  int get hashCode => uid.hashCode;
}
