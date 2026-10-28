import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({required FirebaseAuth auth}) : _auth = auth;

  //Quên mật khẩu
  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  //đăng ký
  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //Đăng nhập
  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  //Gửi mail
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Không tìm thấy người dùng đang đăng nhập');
    }

    if (user.emailVerified) {
      return;
    }

    await user.sendEmailVerification();
  }

  Stream<User?> userChanges() => _auth.userChanges();

  Future<void> signOut() => _auth.signOut();

  String? get currentUserEmail => _auth.currentUser?.email;

  Future<bool> reloadAndCheckEmailVerified() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Không tìm thấy người dùng đang đăng nhập');
    }

    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }
}
