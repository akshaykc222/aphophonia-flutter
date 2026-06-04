import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/user_notification.dart';

class NotificationsRepository {
  NotificationsRepository(this._client);

  final SupabaseClient _client;

  Future<List<UserNotification>> fetchInbox({int limit = 50}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from('user_notifications')
        .select('id, title_ar, body_ar, read_at, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List)
        .map((e) => UserNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> markRead(String notificationId) async {
    await _client
        .from('user_notifications')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', notificationId);
  }
}
