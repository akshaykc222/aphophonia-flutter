import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/content_card.dart';
import '../../../shared/widgets/content_skeleton.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/responsive_center.dart';
import '../../content/presentation/content_providers.dart';
import '../../reference/presentation/reference_providers.dart';

class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryBySlugProvider(slug));

    return category.when(
      loading: () => const AppScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppScaffold(
        body: ErrorState(
          message: 'تعذر تحميل القسم',
          onRetry: () => ref.invalidate(categoryBySlugProvider(slug)),
        ),
      ),
      data: (cat) {
        if (cat == null) {
          return const AppScaffold(
            body: EmptyState(title: 'القسم غير موجود'),
          );
        }

        final feed = ref.watch(
          filteredFeedProvider((categoryId: cat.id, ministryId: null, tenderCategoryId: null, type: null)),
        );

        return AppScaffold(
          title: cat.nameAr,
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                filteredFeedProvider((categoryId: cat.id, ministryId: null, tenderCategoryId: null, type: null)),
              );
            },
            child: ResponsiveCenter(
              child: feed.when(
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: 5,
                  itemBuilder: (_, __) => const ContentCardSkeleton(),
                ),
                error: (e, _) => ErrorState(
                  message: 'تعذر تحميل المحتوى',
                  onRetry: () => ref.invalidate(
                    filteredFeedProvider((categoryId: cat.id, ministryId: null, tenderCategoryId: null, type: null)),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyState(title: 'لا يوجد محتوى في هذا القسم');
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: items.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: ContentCard(item: items[i], index: i),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
