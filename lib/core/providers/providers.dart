import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/bookmarks/data/bookmarks_service.dart';
import '../../features/search/data/search_history_service.dart';
import '../../features/content/data/likes_service.dart';
import '../../features/content/data/content_repository.dart';
import '../../features/reference/data/reference_repository.dart';
import '../config/env.dart';
import '../firebase/push_notification_service.dart';
import '../supabase/storage_urls.dart';

final supabaseConfiguredProvider = Provider<bool>((ref) => Env.isConfigured);

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!Env.isConfigured) return null;
  return Supabase.instance.client;
});

final pushNotificationServiceProvider =
    Provider<PushNotificationService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null || !PushNotificationService.isAvailable) return null;
  return PushNotificationService(client);
});

final contentRepositoryProvider = Provider<ContentRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return ContentRepository(client);
});

final referenceRepositoryProvider = Provider<ReferenceRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return ReferenceRepository(client);
});

final bookmarksServiceProvider = Provider<BookmarksService>((ref) {
  return BookmarksService();
});

final searchHistoryServiceProvider = Provider<SearchHistoryService>((ref) {
  return SearchHistoryService();
});

final likesServiceProvider = Provider<LikesService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return LikesService(client);
});

final storageUrlsProvider = Provider<StorageUrls?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return StorageUrls(client);
});
