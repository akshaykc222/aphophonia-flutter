import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/filters/date_filter.dart';
import '../domain/capt_tender.dart';

class CaptTendersRepository {
  CaptTendersRepository(this._client);

  final SupabaseClient _client;

  static const _select =
      'id, title_ar, title_en, ministry_name, tender_type, '
      'published_at, deadline_at, detail_url, is_latest, last_seen_at';

  dynamic _withDateFilter(dynamic query, DateFilter? dateFilter) {
    if (dateFilter == null) return query;
    return query
        .gte('published_at', dateFilter.startIsoUtc)
        .lte('published_at', dateFilter.endIsoUtc);
  }

  Future<List<CaptTender>> fetchLatest({DateFilter? dateFilter}) async {
    var query = _withDateFilter(
      _client
          .from('capt_tenders')
          .select(_select)
          .eq('status', 'open')
          .eq('is_latest', true),
      dateFilter,
    );

    var data = await query.order('deadline_at', ascending: true);
    var list = data as List;

    if (list.isEmpty) {
      query = _withDateFilter(
        _client.from('capt_tenders').select(_select).eq('status', 'open'),
        dateFilter,
      );
      data = await query
          .order('last_seen_at', ascending: false)
          .limit(50);
      list = data as List;
    }

    var tenders = list
        .map((e) => CaptTender.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    if (dateFilter != null) {
      tenders = tenders
          .where((t) {
            final d = t.publishedAt ?? t.deadlineAt;
            return d != null && dateFilter.contains(d);
          })
          .toList();
    }

    return tenders;
  }
}
