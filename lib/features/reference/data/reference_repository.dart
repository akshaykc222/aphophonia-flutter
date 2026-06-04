import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/category.dart';
import '../domain/ministry.dart';
import '../domain/tender_category.dart';

class ReferenceRepository {
  ReferenceRepository(this._client);

  final SupabaseClient _client;

  Future<List<AppCategory>> fetchCategories() async {
    final data = await _client
        .from('categories')
        .select()
        .order('sort_order', ascending: true);

    return (data as List)
        .map((e) => AppCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppCategory?> getCategoryBySlug(String slug) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('slug', slug)
        .maybeSingle();

    if (data == null) return null;
    return AppCategory.fromJson(data);
  }

  Future<List<Ministry>> fetchMinistries() async {
    final data = await _client
        .from('ministries')
        .select()
        .order('name_ar', ascending: true);

    return (data as List)
        .map((e) => Ministry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Ministry?> getMinistryBySlug(String slug) async {
    final data = await _client
        .from('ministries')
        .select()
        .eq('slug', slug)
        .maybeSingle();

    if (data == null) return null;
    return Ministry.fromJson(data);
  }

  Future<List<TenderCategory>> fetchTenderCategories() async {
    final data = await _client
        .from('tender_categories')
        .select()
        .order('sort_order', ascending: true);

    return (data as List)
        .map((e) => TenderCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TenderCategory?> getTenderCategoryBySlug(String slug) async {
    final data = await _client
        .from('tender_categories')
        .select()
        .eq('slug', slug)
        .maybeSingle();

    if (data == null) return null;
    return TenderCategory.fromJson(data);
  }
}
