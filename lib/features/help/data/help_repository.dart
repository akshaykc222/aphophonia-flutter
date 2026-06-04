import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/help_models.dart';

class HelpRepository {
  HelpRepository(this._client);

  final SupabaseClient _client;

  Future<HelpPage> fetchPage() async {
    final data = await _client
        .from('app_help_page')
        .select('title_ar, intro_ar, contact_email, contact_phone')
        .eq('id', 1)
        .maybeSingle();

    if (data == null) {
      return const HelpPage(titleAr: 'المساعدة');
    }
    return HelpPage.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<HelpItem>> fetchItems() async {
    final data = await _client
        .from('app_help_items')
        .select('id, title_ar, body_ar, sort_order')
        .eq('is_published', true)
        .order('sort_order')
        .order('created_at');

    return (data as List)
        .map((e) => HelpItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
