import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/date_filter_provider.dart';
import '../../../core/providers/providers.dart';
import '../domain/content_item.dart';

final featuredContentProvider = FutureProvider<List<ContentItem>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  if (repo == null) return [];
  return repo.fetchFeatured(limit: 10);
});

class HomeFeedState {
  const HomeFeedState({
    required this.items,
    this.hasMore = true,
    this.loadingMore = false,
  });

  final List<ContentItem> items;
  final bool hasMore;
  final bool loadingMore;

  HomeFeedState copyWith({
    List<ContentItem>? items,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return HomeFeedState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

final homeFeedProvider =
    AsyncNotifierProvider.family<HomeFeedNotifier, HomeFeedState, String>(
  HomeFeedNotifier.new,
);

class HomeFeedNotifier extends FamilyAsyncNotifier<HomeFeedState, String> {
  static const pageSize = 20;
  int _page = 0;

  @override
  Future<HomeFeedState> build(String categoryId) async {
    _page = 0;
    final dateFilter = ref.watch(contentDateFilterProvider);
    final repo = ref.read(contentRepositoryProvider);
    if (repo == null) {
      return const HomeFeedState(items: []);
    }
    final items = await repo.fetchFeed(
      categoryId: categoryId,
      dateFilter: dateFilter,
      page: 0,
      pageSize: pageSize,
    );
    return HomeFeedState(
      items: items,
      hasMore: items.length >= pageSize,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;
    final repo = ref.read(contentRepositoryProvider);
    if (repo == null) return;

    state = AsyncData(current.copyWith(loadingMore: true));

    try {
      _page++;
      final dateFilter = ref.read(contentDateFilterProvider);
      final batch = await repo.fetchFeed(
        categoryId: arg,
        dateFilter: dateFilter,
        page: _page,
        pageSize: pageSize,
      );
      state = AsyncData(
        HomeFeedState(
          items: [...current.items, ...batch],
          hasMore: batch.length >= pageSize,
        ),
      );
    } finally {
      final latest = state.valueOrNull;
      if (latest != null) {
        state = AsyncData(latest.copyWith(loadingMore: false));
      }
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final contentBySlugProvider =
    FutureProvider.family<ContentItem?, String>((ref, slug) async {
  final repo = ref.watch(contentRepositoryProvider);
  if (repo == null) return null;
  return repo.getBySlug(slug);
});

typedef FeedFilter = ({
  String? categoryId,
  String? ministryId,
  String? tenderCategoryId,
  ContentType? type,
});

final filteredFeedProvider =
    FutureProvider.family<List<ContentItem>, FeedFilter>((ref, filter) async {
  final dateFilter = ref.watch(contentDateFilterProvider);
  final repo = ref.watch(contentRepositoryProvider);
  if (repo == null) return [];
  return repo.fetchFeed(
    categoryId: filter.categoryId,
    ministryId: filter.ministryId,
    tenderCategoryId: filter.tenderCategoryId,
    type: filter.type,
    dateFilter: dateFilter,
    pageSize: 40,
  );
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider =
    FutureProvider.family<List<ContentItem>, String>((ref, query) async {
  final q = query.trim();
  if (q.isEmpty) return [];
  final repo = ref.watch(contentRepositoryProvider);
  if (repo == null) {
    throw StateError('Supabase not configured');
  }
  return repo.search(q);
});

final recentSearchesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(searchHistoryServiceProvider).getRecent();
});

final bookmarkedIdsProvider = FutureProvider<Set<String>>((ref) async {
  return ref.watch(bookmarksServiceProvider).getBookmarkedIds();
});

final bookmarkedContentProvider =
    FutureProvider<List<ContentItem>>((ref) async {
  final ids = await ref.watch(bookmarkedIdsProvider.future);
  if (ids.isEmpty) return [];
  final repo = ref.watch(contentRepositoryProvider);
  if (repo == null) return [];
  final items = <ContentItem>[];
  for (final id in ids) {
    final item = await repo.getById(id);
    if (item != null) items.add(item);
  }
  return items;
});
