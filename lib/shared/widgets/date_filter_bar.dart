import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/filters/date_filter.dart';
import '../../core/l10n/ar_kw_strings.dart';
import '../../core/providers/date_filter_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/capt_tenders/presentation/capt_tenders_providers.dart';
import '../../features/content/presentation/content_providers.dart';

class DateFilterBar extends ConsumerWidget {
  const DateFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(contentDateFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          InkWell(
            onTap: () => _openSheet(context, ref, filter),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: filter != null
                    ? AppColors.link.withValues(alpha: 0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: filter != null
                      ? AppColors.link.withValues(alpha: 0.4)
                      : AppColors.borderSubtle,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: filter != null ? AppColors.link : AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter?.label() ?? ArKwStrings.dateFilterAll,
                    style: AppTypography.body16.copyWith(
                      fontSize: 13,
                      color: filter != null
                          ? AppColors.link
                          : AppColors.muted,
                      fontWeight:
                          filter != null ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (filter != null) ...[
            const SizedBox(width: 8),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              tooltip: ArKwStrings.dateFilterClear,
              onPressed: () {
                ref.read(contentDateFilterProvider.notifier).state = null;
                invalidateDateFilteredFeeds(ref);
              },
              icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openSheet(
    BuildContext context,
    WidgetRef ref,
    DateFilter? current,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => _DateFilterSheet(
        initial: current,
        onApply: (filter) {
          ref.read(contentDateFilterProvider.notifier).state = filter;
          invalidateDateFilteredFeeds(ref);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _DateFilterSheet extends StatefulWidget {
  const _DateFilterSheet({
    required this.onApply,
    this.initial,
  });

  final DateFilter? initial;
  final void Function(DateFilter? filter) onApply;

  @override
  State<_DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<_DateFilterSheet> {
  _SheetMode _mode = _SheetMode.all;
  DateTime? _singleDay;
  DateTime? _fromDay;
  DateTime? _toDay;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial == null) {
      _mode = _SheetMode.all;
    } else if (initial.mode == DateFilterMode.singleDay ||
        initial.endDay == null) {
      _mode = _SheetMode.singleDay;
      _singleDay = initial.startDay;
    } else {
      _mode = _SheetMode.range;
      _fromDay = initial.startDay;
      _toDay = initial.endDay;
    }
  }

  Future<DateTime?> _pickDate(DateTime? initial) async {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(2010),
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('ar', 'KW'),
    );
  }

  void _apply() {
    switch (_mode) {
      case _SheetMode.all:
        widget.onApply(null);
      case _SheetMode.singleDay:
        if (_singleDay == null) return;
        widget.onApply(DateFilter.singleDay(_singleDay!));
      case _SheetMode.range:
        if (_fromDay == null || _toDay == null) return;
        widget.onApply(DateFilter.range(_fromDay!, _toDay!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              ArKwStrings.dateFilterTitle,
              style: AppTypography.body16Semi,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            RadioListTile<_SheetMode>(
              title: Text(ArKwStrings.dateFilterAll),
              value: _SheetMode.all,
              groupValue: _mode,
              onChanged: (v) => setState(() => _mode = v!),
            ),
            RadioListTile<_SheetMode>(
              title: Text(ArKwStrings.dateFilterSingleDay),
              value: _SheetMode.singleDay,
              groupValue: _mode,
              onChanged: (v) => setState(() => _mode = v!),
            ),
            if (_mode == _SheetMode.singleDay)
              ListTile(
                leading: const Icon(Icons.event, color: AppColors.link),
                title: Text(
                  _singleDay != null
                      ? DateFilter.singleDay(_singleDay!).label()
                      : ArKwStrings.dateFilterPickDay,
                  style: AppTypography.body16.copyWith(fontSize: 14),
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () async {
                  final d = await _pickDate(_singleDay);
                  if (d != null) setState(() => _singleDay = d);
                },
              ),
            RadioListTile<_SheetMode>(
              title: Text(ArKwStrings.dateFilterRange),
              value: _SheetMode.range,
              groupValue: _mode,
              onChanged: (v) => setState(() => _mode = v!),
            ),
            if (_mode == _SheetMode.range) ...[
              ListTile(
                leading: const Icon(Icons.date_range, color: AppColors.link),
                title: Text(
                  _fromDay != null
                      ? '${ArKwStrings.dateFilterFrom}: ${DateFilter.singleDay(_fromDay!).label()}'
                      : ArKwStrings.dateFilterFrom,
                  style: AppTypography.body16.copyWith(fontSize: 14),
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () async {
                  final d = await _pickDate(_fromDay ?? _toDay);
                  if (d != null) setState(() => _fromDay = d);
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_available, color: AppColors.link),
                title: Text(
                  _toDay != null
                      ? '${ArKwStrings.dateFilterTo}: ${DateFilter.singleDay(_toDay!).label()}'
                      : ArKwStrings.dateFilterTo,
                  style: AppTypography.body16.copyWith(fontSize: 14),
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () async {
                  final d = await _pickDate(_toDay ?? _fromDay);
                  if (d != null) setState(() => _toDay = d);
                },
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _apply,
              child: Text(ArKwStrings.dateFilterApply),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SheetMode { all, singleDay, range }

void invalidateDateFilteredFeeds(WidgetRef ref) {
  ref.invalidate(homeFeedProvider);
  ref.invalidate(filteredFeedProvider);
  ref.invalidate(latestCaptTendersProvider);
}
