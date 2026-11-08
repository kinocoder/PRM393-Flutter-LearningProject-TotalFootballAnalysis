import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories/current_user_provider.dart';
import 'routing/app_router.dart';
import 'ui/authentication/view_models/auth_session_view_model.dart';

class FootballApp extends ConsumerWidget {
  const FootballApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    ref.watch(currentUidProvider);
    ref.listen(authSessionProvider, (_, next) {
      next.whenData((authSession) {
        ref.read(currentUidProvider.notifier).setUid(authSession?.uid ?? '');
      });
    });
    final router = AppRouter(
      session,
      onRetry: () => ref.invalidate(authSessionProvider),
    );
    return MaterialApp(
      key: router.navigationKey,
      initialRoute: '/',
      onGenerateRoute: router.onGenerateRoute,
    );
  }
}
