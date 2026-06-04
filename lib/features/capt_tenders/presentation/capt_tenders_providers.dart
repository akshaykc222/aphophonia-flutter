import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/date_filter_provider.dart';
import '../../../core/providers/providers.dart';
import '../data/capt_tenders_repository.dart';
import '../domain/capt_tender.dart';

final captTendersRepositoryProvider = Provider<CaptTendersRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return CaptTendersRepository(client);
});

final latestCaptTendersProvider = FutureProvider<List<CaptTender>>((ref) async {
  final dateFilter = ref.watch(contentDateFilterProvider);
  final repo = ref.watch(captTendersRepositoryProvider);
  if (repo == null) return [];
  return repo.fetchLatest(dateFilter: dateFilter);
});
