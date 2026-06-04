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

class MinistryDetailScreen extends ConsumerWidget {
  const MinistryDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ministry = ref.watch(ministryBySlugProvider(slug));

    return ministry.when(
      loading: () => const AppScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppScaffold(
        body: ErrorState(
          message: 'تعذر تحميل الوزارة',
          onRetry: () => ref.invalidate(ministryBySlugProvider(slug)),
        ),
      ),
      data: (m) {
        if (m == null) {
          return const AppScaffold(
            body: EmptyState(title: 'الوزارة غير موجودة'),
          );
        }

        final filter = (
          categoryId: null,
          ministryId: m.id,
          tenderCategoryId: null,
          type: null,
        );
        final feed = ref.watch(filteredFeedProvider(filter));

        return AppScaffold(
          title: m.nameAr,
          body: ResponsiveCenter(
            child: feed.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: 5,
                itemBuilder: (_, __) => const ContentCardSkeleton(),
              ),
              error: (e, _) => ErrorState(
                message: 'تعذر تحميل المحتوى',
                onRetry: () => ref.invalidate(filteredFeedProvider(filter)),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    title: 'لا يوجد محتوى لهذه الوزارة',
                  );
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
        );
      },
    );
  }
}
