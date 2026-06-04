import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/help_repository.dart';
import '../domain/help_models.dart';

final helpRepositoryProvider = Provider<HelpRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return HelpRepository(client);
});

final helpPageProvider = FutureProvider.autoDispose<HelpPage>((ref) async {
  final repo = ref.watch(helpRepositoryProvider);
  if (repo == null) return const HelpPage(titleAr: 'المساعدة');
  return repo.fetchPage();
});

final helpItemsProvider = FutureProvider.autoDispose<List<HelpItem>>((ref) async {
  final repo = ref.watch(helpRepositoryProvider);
  if (repo == null) return [];
  return repo.fetchItems();
});
