import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LikesService {
  LikesService(this._client);
  final SupabaseClient? _client;

  static const _key = 'liked_content_ids';

  Future<Set<String>> getLikedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  Future<bool> isLiked(String id) async {
    final ids = await getLikedIds();
    return ids.contains(id);
  }

  Future<void> toggle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getLikedIds();
    final isLiking = !ids.contains(id);
    
    if (isLiking) {
      ids.add(id);
      if (_client != null) {
        try {
          await _client.rpc('increment_like', params: {'content_id': id});
        } catch (e) {
          // Ignore RPC errors for resilience
        }
      }
    } else {
      ids.remove(id);
      if (_client != null) {
        try {
          await _client.rpc('decrement_like', params: {'content_id': id});
        } catch (e) {
          // Ignore RPC errors
        }
      }
    }
    await prefs.setStringList(_key, ids.toList());
  }
}
