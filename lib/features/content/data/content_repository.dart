import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/filters/date_filter.dart';
import '../domain/content_item.dart';

class ContentRepository {
  ContentRepository(this._client);

  final SupabaseClient _client;
  bool _usePlainSelect = false;

  static const _itemSelect = '''
    *,
    category:categories(id, name_ar, slug, is_trending, badge_emoji),
    ministry:ministries(id, name_ar, slug, logo_url),
    tender_category:tender_categories(id, name_ar)
  ''';
  String get _select => _usePlainSelect ? '*' : _itemSelect;

  Future<List<ContentItem>> fetchFeed({
    String? categoryId,
    String? ministryId,
    String? tenderCategoryId,
    ContentType? type,
    DateFilter? dateFilter,
    int page = 0,
    int pageSize = 20,
  }) async {
    return _withFallback(() async {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      var query =
          _client.from('content_items').select(_select).eq('is_published', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (ministryId != null) {
        query = query.eq('ministry_id', ministryId);
      }
      if (tenderCategoryId != null) {
        query = query.eq('tender_category_id', tenderCategoryId);
      }
      if (type != null) {
        query = query.eq('content_type', type.name);
      }
      if (dateFilter != null) {
        query = query
            .gte('published_at', dateFilter.startIsoUtc)
            .lte('published_at', dateFilter.endIsoUtc);
      }

      final data = await query
          .order('published_at', ascending: false)
          .range(from, to);

      return _mapList(data);
    });
  }

  Future<List<ContentItem>> fetchFeatured({int limit = 10}) async {
    return _withFallback(() async {
      final data = await _client
          .from('content_items')
          .select(_select)
          .eq('is_published', true)
          .eq('is_featured', true)
          .order('published_at', ascending: false)
          .limit(limit);

      return _mapList(data);
    });
  }

  Future<ContentItem?> getBySlug(String slug) async {
    return _withFallback(() async {
      final data = await _client
          .from('content_items')
          .select(_select)
          .eq('is_published', true)
          .eq('slug', slug)
          .maybeSingle();

      if (data == null) return null;
      return ContentItem.fromJson(data);
    });
  }

  Future<ContentItem?> getById(String id) async {
    return _withFallback(() async {
      final data = await _client
          .from('content_items')
          .select(_select)
          .eq('is_published', true)
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;
      return ContentItem.fromJson(data);
    });
  }

  Future<List<ContentItem>> search(String query, {int limit = 30}) async {
    final q = _sanitizeSearchQuery(query);
    if (q.isEmpty) return [];

    return _withFallback(() async {
      // Quote pattern so spaces/Arabic survive PostgREST `.or()` parsing.
      final pattern = '"%${_escapeLike(q)}%"';
      final data = await _client
          .from('content_items')
          .select(_select)
          .eq('is_published', true)
          .or(
            'title_ar.ilike.$pattern,'
            'summary_ar.ilike.$pattern,'
            'body_ar.ilike.$pattern,'
            'search_text.ilike.$pattern',
          )
          .order('published_at', ascending: false)
          .limit(limit);

      return _mapList(data);
    });
  }

  /// PostgREST `.or()` breaks on commas/parens in the query string.
  static String _sanitizeSearchQuery(String raw) {
    return raw
        .trim()
        .replaceAll(RegExp(r'[,()]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('%', '')
        .replaceAll('_', ' ');
  }

  static String _escapeLike(String q) {
    return q.replaceAll('"', '');
  }

  Future<T> _withFallback<T>(Future<T> Function() run) async {
    if (_usePlainSelect) return run();
    try {
      return await run();
    } on PostgrestException catch (e) {
      debugPrint('ContentRepository: retrying with plain select — ${e.message}');
      _usePlainSelect = true;
      return run();
    }
  }

  List<ContentItem> _mapList(dynamic data) {
    final items = <ContentItem>[];
    for (final row in data as List) {
      try {
        final map = Map<String, dynamic>.from(row as Map);
        items.add(ContentItem.fromJson(map));
      } catch (e, st) {
        debugPrint('ContentRepository: skip row — $e\n$st');
      }
    }
    return items;
  }
}
