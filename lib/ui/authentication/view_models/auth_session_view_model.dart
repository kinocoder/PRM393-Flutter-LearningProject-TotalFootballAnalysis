import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/model/auth_session.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_session_view_model.g.dart';

// AsyncLoading: restoring, AsyncError: session failure,
// AsyncData(null): signed out, otherwise inspect emailVerified.
@Riverpod(keepAlive: true)
Stream<AuthSession?> authSession(Ref ref) {
  return ref.watch(authRepositoryProvider).sessionChanges();
}
