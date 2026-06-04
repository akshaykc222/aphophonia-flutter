import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../domain/capt_tender.dart';

/// Native detail screen for CAPT tenders — no WebView.
class CaptTenderDetailScreen extends StatelessWidget {
  const CaptTenderDetailScreen({
    super.key,
    required this.tender,
  });

  final CaptTender tender;


  @override
  Widget build(BuildContext context) {
    final deadline = tender.deadlineAt != null
        ? DateFormat('d MMMM yyyy', 'ar').format(tender.deadlineAt!)
        : null;
    final published = tender.publishedAt != null
        ? DateFormat('d MMMM yyyy', 'ar').format(tender.publishedAt!)
        : null;

    return AppScaffold(
      title: ArKwStrings.captSourceShort,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Type badge ──────────────────────────────────────────────────
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ArKwStrings.captSourceShort,
                      style: AppTypography.caption12.copyWith(
                        color: AppColors.foregroundSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (tender.tenderType != null &&
                      tender.tenderType!.trim().isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.link.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tender.tenderType!.trim(),
                        style: AppTypography.caption12.copyWith(
                          color: AppColors.link,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Title ───────────────────────────────────────────────────────
            Text(
              tender.titleAr,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
            ),
            if (tender.titleEn != null &&
                tender.titleEn!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                tender.titleEn!.trim(),
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.muted,
                      height: 1.4,
                    ),
              ),
            ],
            const SizedBox(height: 24),

            // ── Meta card ───────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  if (tender.ministryName != null &&
                      tender.ministryName!.trim().isNotEmpty)
                    _MetaRow(
                      icon: Icons.account_balance_outlined,
                      label: 'الجهة',
                      value: tender.ministryName!.trim(),
                    ),
                  if (published != null)
                    _MetaRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'تاريخ النشر',
                      value: published,
                    ),
                  if (deadline != null)
                    _MetaRow(
                      icon: Icons.schedule_outlined,
                      label: ArKwStrings.captDeadline,
                      value: deadline,
                      valueColor: AppColors.error,
                    ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.link),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption12
                      .copyWith(color: AppColors.muted),
                ),
                Text(
                  value,
                  style: AppTypography.body16.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
