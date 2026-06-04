import 'package:supabase_flutter/supabase_flutter.dart';

/// Resolves public `assets` bucket paths to full URLs.
class StorageUrls {
  StorageUrls(this._client);

  final SupabaseClient _client;

  String resolveLogoUrl(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) return '';
    if (pathOrUrl.startsWith('http')) return pathOrUrl;
    return _client.storage.from('assets').getPublicUrl(pathOrUrl);
  }
}
