import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/content_skeleton.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/responsive_center.dart';
import '../../reference/presentation/reference_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return AppScaffold(
      title: 'الأقسام',
      body: ResponsiveCenter(
        child: categories.when(
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 6,
            itemBuilder: (_, __) => const ContentCardSkeleton(),
          ),
          error: (e, _) => ErrorState(
            message: 'تعذر تحميل الأقسام',
            onRetry: () => ref.invalidate(categoriesProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(title: 'لا توجد أقسام');
            }
            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.5,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final cat = items[i];
                return Card(
                  child: InkWell(
                    onTap: () => context.push('/categories/${cat.slug}'),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cat.badgeEmoji ?? '📰',
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            cat.nameAr,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
