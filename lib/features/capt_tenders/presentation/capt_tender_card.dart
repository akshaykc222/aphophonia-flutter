import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/animations/app_animations.dart';
import '../domain/capt_tender.dart';
import 'animated_new_badge.dart';

class CaptTenderCard extends StatelessWidget {
  const CaptTenderCard({
    super.key,
    required this.tender,
    this.index = 0,
  });

  final CaptTender tender;
  final int index;

  void _openDetail(BuildContext context) {
    context.push('/tender/${tender.id}', extra: tender);
  }

  @override
  Widget build(BuildContext context) {
    final deadline = tender.deadlineAt != null
        ? DateFormat('d MMM yyyy', 'ar').format(tender.deadlineAt!)
        : null;
    final published = tender.publishedAt != null
        ? DateFormat('d MMM yyyy', 'ar').format(tender.publishedAt!)
        : null;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tender.subtitle.isNotEmpty
                          ? tender.subtitle
                          : ArKwStrings.captSource,
                      style: AppTypography.caption12.copyWith(
                        color: AppColors.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (tender.isLatest) ...[
                    const SizedBox(width: 6),
                    const AnimatedNewBadge(compact: true),
                  ],
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      ArKwStrings.captSourceShort,
                      style: AppTypography.caption12.copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tender.titleAr,
                style: AppTypography.body16Semi.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (deadline != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppColors.muted.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ArKwStrings.captDeadline}: $deadline',
                      style: AppTypography.caption12.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ] else if (published != null)
                    Text(
                      published,
                      style: AppTypography.caption12.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_left,
                    size: 18,
                    color: AppColors.muted.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).listItemAnimate(index);
  }
}
