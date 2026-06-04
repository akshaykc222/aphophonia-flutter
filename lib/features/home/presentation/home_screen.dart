import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/content_skeleton.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/news_card.dart';
import '../../capt_tenders/domain/capt_tender.dart';
import '../../capt_tenders/presentation/animated_new_badge.dart';
import '../../capt_tenders/presentation/capt_tender_card.dart';
import '../../capt_tenders/presentation/capt_tenders_providers.dart';
import '../../capt_tenders/presentation/home_capt_tab.dart';
import '../../../core/providers/date_filter_provider.dart';
import '../../../shared/widgets/date_filter_bar.dart';
import '../../content/domain/content_item.dart';
import '../../content/presentation/content_providers.dart';
import '../../reference/domain/category.dart';
import '../../reference/presentation/reference_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isCaptTab(String? id) => id == HomeCaptTab.id;

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_isCaptTab(_selectedCategoryId)) return;
    final categoryId = _selectedCategoryId;
    if (categoryId == null) return;
    final max = _scrollController.position.maxScrollExtent;
    if (_scrollController.offset < max - 320) return;
    ref.read(homeFeedProvider(categoryId).notifier).loadMore();
  }

  int _defaultCategoryIndex(List<AppCategory> categories) {
    final i = categories.indexWhere((c) => c.slug == 'ministries');
    return i >= 0 ? i : 0;
  }

  int _tabIndex(List<AppCategory> categories, String? selectedId) {
    if (_isCaptTab(selectedId)) return categories.length;
    if (selectedId == null) return _defaultCategoryIndex(categories);
    final i = categories.indexWhere((c) => c.id == selectedId);
    return i >= 0 ? i : _defaultCategoryIndex(categories);
  }

  void _selectTab(List<AppCategory> categories, int index) {
    if (index >= categories.length) {
      setState(() => _selectedCategoryId = HomeCaptTab.id);
      ref.invalidate(latestCaptTendersProvider);
      return;
    }
    final id = categories[index].id;
    setState(() => _selectedCategoryId = id);
    ref.invalidate(homeFeedProvider(id));
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final featured = ref.watch(featuredContentProvider);
    final captTendersAsync = ref.watch(latestCaptTendersProvider);
    final dateFilter = ref.watch(contentDateFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(
          message: ArKwStrings.loadCategoriesFailed,
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyState(title: ArKwStrings.noCategories);
          }

          final safeIndex = _tabIndex(categories, _selectedCategoryId);
          final isCaptTab = safeIndex == categories.length;

          if (!isCaptTab) {
            final category = categories[safeIndex];
            if (_selectedCategoryId != category.id) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _selectedCategoryId = category.id);
                }
              });
            }
          } else if (_selectedCategoryId != HomeCaptTab.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _selectedCategoryId = HomeCaptTab.id);
              }
            });
          }

          final categoryId = isCaptTab ? null : categories[safeIndex].id;
          final feed = categoryId != null
              ? ref.watch(homeFeedProvider(categoryId))
              : null;

          return Column(
            children: [
              _HomeHeader(
                onSearch: () => context.push('/search'),
              ),
              _CategoryBar(
                categories: categories,
                selectedIndex: safeIndex,
                onSelected: (i) => _selectTab(categories, i),
              ),
              const SizedBox(height: 8), // Small gap before the rounded corners
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      onRefresh: () async {
                        if (isCaptTab) {
                          ref.invalidate(latestCaptTendersProvider);
                          await ref.read(latestCaptTendersProvider.future);
                        } else {
                          ref.invalidate(featuredContentProvider);
                          await ref
                              .read(homeFeedProvider(categoryId!).notifier)
                              .refresh();
                        }
                      },
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          const SliverToBoxAdapter(child: DateFilterBar()),
                          if (!isCaptTab && feed != null && dateFilter == null)
                            SliverToBoxAdapter(
                              child: _FeaturedStrip(featured: featured, feed: feed),
                            ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                              child: Text(
                                isCaptTab
                                    ? ArKwStrings.latestTendersTab
                                    : ArKwStrings.latestNews,
                                style: AppTypography.body16Semi,
                              ),
                            ),
                          ),
                          if (isCaptTab)
                            _buildCaptSliver(captTendersAsync)
                          else if (feed != null)
                            _buildFeedSliver(feed, categoryId!),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCaptSliver(AsyncValue<List<CaptTender>> captTendersAsync) {
    return captTendersAsync.when(
      loading: () => SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ContentCardSkeleton(),
          ),
          childCount: 4,
        ),
      ),
      error: (e, st) => SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          message: ArKwStrings.loadCaptTendersFailed,
          detail: kDebugMode ? '$e' : null,
          onRetry: () => ref.invalidate(latestCaptTendersProvider),
        ),
      ),
      data: (tenders) {
        if (tenders.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(title: ArKwStrings.noCaptTenders),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CaptTenderCard(
                  tender: tenders[i],
                  index: i,
                ),
              ),
              childCount: tenders.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedSliver(
    AsyncValue<HomeFeedState> feed,
    String categoryId,
  ) {
    return feed.when(
      loading: () => SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ContentCardSkeleton(),
          ),
          childCount: 4,
        ),
      ),
      error: (e, st) => SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          message: ArKwStrings.loadContentFailed,
          detail: kDebugMode ? '$e' : null,
          onRetry: () => ref.invalidate(homeFeedProvider(categoryId)),
        ),
      ),
      data: (page) {
        if (page.items.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(title: ArKwStrings.noPublishedContent),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                if (i == page.items.length) {
                  if (!page.hasMore) return const SizedBox.shrink();
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NewsCard(item: page.items[i], index: i),
                );
              },
              childCount:
                  page.items.length + (page.hasMore || page.loadingMore ? 1 : 0),
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal hero carousel: global `is_featured` items, or top of tab feed.
class _FeaturedStrip extends StatelessWidget {
  const _FeaturedStrip({
    required this.featured,
    required this.feed,
  });

  static const _height = 184.0;
  static const _fallbackCount = 5;

  final AsyncValue<List<ContentItem>> featured;
  final AsyncValue<HomeFeedState> feed;

  List<ContentItem> _carouselItems() {
    final flagged = featured.valueOrNull;
    if (flagged != null && flagged.isNotEmpty) return flagged;

    final page = feed.valueOrNull;
    if (page != null && page.items.isNotEmpty) {
      return page.items.take(_fallbackCount).toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final items = _carouselItems();
    if (items.isNotEmpty) {
      return SizedBox(
        height: _height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => FeaturedNewsCard(item: items[i]),
        ),
      );
    }

    if (featured.isLoading && feed.isLoading) {
      return const SizedBox(
        height: _height,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return const SizedBox.shrink();
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary, // Navy blue — merges with the tab bar below
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onSearch,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.searchBarBg, // Royal blue (#1A4F8A)
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ArKwStrings.searchArticles,
                          style: AppTypography.body16.copyWith(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => context.push('/notifications'),
                icon: const Icon(
                  Icons.notifications_none,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AppCategory> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final tabCount = categories.length + 1;

    return Container(
      color: AppColors.primary, // Navy blue background — same as header
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: tabCount,
          separatorBuilder: (_, __) => const SizedBox(width: 20),
          itemBuilder: (context, i) {
            final isCaptTab = i == categories.length;
            final isSelected = i == selectedIndex;
            final label = isCaptTab
                ? ArKwStrings.latestTendersTab
                : categories[i].tabLabel;

            return GestureDetector(
              onTap: () => onSelected(i),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Tab label row
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: AppTypography.body16.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          if (isCaptTab) ...[
                            const SizedBox(width: 6),
                            const AnimatedNewBadge(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // White underline indicator for selected tab
                  if (isSelected)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
