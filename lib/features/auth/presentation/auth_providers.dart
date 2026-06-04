import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/auth_router_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/providers.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return AuthRepository(
    client,
    beforeSignOut: () async {
      await ref.read(pushNotificationServiceProvider)?.unregister();
    },
  );
});

final authSessionProvider = StreamProvider<Session?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return Stream.value(null);

  return Stream.multi((controller) {
    controller.add(client.auth.currentSession);
    final sub = client.auth.onAuthStateChange.listen((event) {
      controller.add(event.session);
    });
    controller.onCancel = sub.cancel;
  });
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final session = ref.watch(authSessionProvider).valueOrNull;
  return session != null;
});

final authRouterNotifierProvider = Provider<AuthRouterNotifier?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  if (repo == null) return null;
  final notifier = AuthRouterNotifier(repo);
  ref.onDispose(notifier.dispose);
  return notifier;
});
