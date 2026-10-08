import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/auth_service.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(authService: AuthService(auth: FirebaseAuth.instance));
}

class AuthRepository {
  final AuthService _authService;

  AuthRepository({required AuthService authService})
    : _authService = authService;

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _authService.register(email: email.trim(), password: password);
  }
}
