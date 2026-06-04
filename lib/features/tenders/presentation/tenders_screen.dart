import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/date_filter_bar.dart';
import '../../../shared/widgets/content_skeleton.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/news_card.dart';
import '../../content/domain/content_item.dart';
import '../../content/presentation/content_providers.dart';
import '../../reference/domain/tender_category.dart';
import '../../reference/presentation/reference_providers.dart';

class TendersScreen extends ConsumerStatefulWidget {
  const TendersScreen({super.key});

  @override
  ConsumerState<TendersScreen> createState() => _TendersScreenState();
}

class _TendersScreenState extends ConsumerState<TendersScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(tenderCategoriesProvider);
    final filter = (
      categoryId: null,
      ministryId: null,
      tenderCategoryId: _selectedCategoryId,
      type: ContentType.tender,
    );
    final feed = ref.watch(filteredFeedProvider(filter));

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Blue header band (navy + SafeArea top) ──────────────────────
          Container(
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/search'),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.searchBarBg,
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
                                ArKwStrings.searchTenders,
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
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── White rounded body container ──────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── "مختارات لك" label ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(ArKwStrings.forYou, style: AppTypography.body16Semi),
                    ),
                    // ── Category chip bar ───────────────────────────────────────────
                    categories.when(
            loading: () => const SizedBox(
              height: 48,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (cats) => SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _Chip(
                    label: ArKwStrings.allCategories,
                    selected: _selectedCategoryId == null,
                    onTap: () => setState(() => _selectedCategoryId = null),
                  ),
                  ...cats.map(
                    (TenderCategory c) => _Chip(
                      label: c.nameAr,
                      selected: _selectedCategoryId == c.id,
                      onTap: () => setState(() => _selectedCategoryId = c.id),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const DateFilterBar(),
          // ── Feed list ───────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(filteredFeedProvider(filter));
              },
              child: feed.when(
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: 5,
                  itemBuilder: (_, __) => const ContentCardSkeleton(),
                ),
                error: (e, _) => ErrorState(
                  message: ArKwStrings.loadTendersFailed,
                  onRetry: () => ref.invalidate(filteredFeedProvider(filter)),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return EmptyState(title: ArKwStrings.noTenders);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: NewsCard(item: items[i], index: i),
                    ),
                  );
                },
              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.link,
        checkmarkColor: AppColors.onPrimary,
        labelStyle: TextStyle(
          color: selected ? AppColors.onPrimary : AppColors.muted,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
        side: BorderSide(
          color: selected ? AppColors.link : AppColors.borderSubtle,
        ),
      ),
    );
  }
}
