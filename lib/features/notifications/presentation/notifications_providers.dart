import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/notifications_repository.dart';
import '../domain/user_notification.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return NotificationsRepository(client);
});

final userNotificationsProvider =
    FutureProvider.autoDispose<List<UserNotification>>((ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  if (repo == null) return [];
  return repo.fetchInbox();
});
