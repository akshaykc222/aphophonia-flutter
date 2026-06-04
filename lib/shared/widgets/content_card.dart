import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/content/domain/content_item.dart';
import '../animations/app_animations.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.item,
    this.index = 0,
    this.featured = false,
  });

  final ContentItem item;
  final int index;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final dateStr = item.publishedAt != null
        ? DateFormat('d MMM yyyy', 'ar').format(item.publishedAt!)
        : null;

    return Semantics(
      button: true,
      label: '${item.typeLabelAr}: ${item.titleAr}',
      child: Material(
      color: featured ? AppColors.surfaceHigh : AppColors.card,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => context.push('/content/${item.slug}'),
        child: Container(
            width: featured ? 300 : double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: featured ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        item.typeLabelAr,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    if (item.isFeatured) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.star, size: 14, color: AppColors.accent),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item.titleAr,
                  maxLines: featured ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                ),
                if (item.summaryAr != null && item.summaryAr!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.summaryAr!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                          height: 1.4,
                        ),
                  ),
                ],
                if (dateStr != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                ],
              ],
            ),
          ),
      ),
    ),
    ).listItemAnimate(index);
  }
}
