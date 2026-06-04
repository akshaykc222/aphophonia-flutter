import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/content_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/responsive_center.dart';
import '../../content/presentation/content_providers.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(bookmarkedContentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('محفوظ')),
      body: ResponsiveCenter(
        child: saved.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            title: 'تعذر تحميل المحفوظ',
            actionLabel: 'إعادة المحاولة',
            onAction: () => ref.invalidate(bookmarkedContentProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(
                title: 'لا يوجد محتوى محفوظ',
                message: 'اضغط على أيقونة الإشارة المرجعية في أي مقال لحفظه هنا.',
                icon: Icons.bookmark_outline,
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
  }
}
