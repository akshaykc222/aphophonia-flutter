import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../domain/category.dart';
import '../domain/ministry.dart';
import '../domain/tender_category.dart';

final categoriesProvider = FutureProvider<List<AppCategory>>((ref) async {
  final repo = ref.watch(referenceRepositoryProvider);
  if (repo == null) return [];
  return repo.fetchCategories();
});

final categoryBySlugProvider =
    FutureProvider.family<AppCategory?, String>((ref, slug) async {
  final repo = ref.watch(referenceRepositoryProvider);
  if (repo == null) return null;
  return repo.getCategoryBySlug(slug);
});

final ministriesProvider = FutureProvider<List<Ministry>>((ref) async {
  final repo = ref.watch(referenceRepositoryProvider);
  if (repo == null) return [];
  return repo.fetchMinistries();
});

final ministryBySlugProvider =
    FutureProvider.family<Ministry?, String>((ref, slug) async {
  final repo = ref.watch(referenceRepositoryProvider);
  if (repo == null) return null;
  return repo.getMinistryBySlug(slug);
});

final tenderCategoriesProvider =
    FutureProvider<List<TenderCategory>>((ref) async {
  final repo = ref.watch(referenceRepositoryProvider);
  if (repo == null) return [];
  return repo.fetchTenderCategories();
});
