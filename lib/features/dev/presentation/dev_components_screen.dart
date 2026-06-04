import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../features/content/domain/content_item.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/content_card.dart';
import '../../../shared/widgets/empty_state.dart';

class DevComponentsScreen extends StatelessWidget {
  const DevComponentsScreen({super.key});

  static final _sample = ContentItem(
    id: 'sample',
    titleAr: 'عنوان تجريبي لمقال في الجريدة الرسمية',
    summaryAr: 'ملخص قصير يوضح محتوى المقال أو المناقصة.',
    slug: 'sample',
    contentType: ContentType.article,
    isFeatured: true,
    publishedAt: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مكوّنات الواجهة')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppButton(label: 'زر أساسي', onPressed: () {}),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'زر ثانوي',
            variant: AppButtonVariant.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          ContentCard(item: _sample, index: 0),
          const SizedBox(height: AppSpacing.lg),
          const EmptyState(title: 'حالة فارغة'),
        ],
      ),
    );
  }
}
