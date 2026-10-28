/// Immutable application data, independent of the Firebase SDK.
class AuthSession {
  const AuthSession({
    required this.uid,
    required this.emailVerified,
    this.email,
    this.name,
    this.avatarUrl,
  });

  final String uid;
  final bool emailVerified;
  final String? email;
  final String? name;
  final String? avatarUrl;
}
