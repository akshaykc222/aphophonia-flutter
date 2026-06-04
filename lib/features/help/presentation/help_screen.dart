import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_scaffold.dart';
import 'help_providers.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(helpPageProvider);
    final itemsAsync = ref.watch(helpItemsProvider);

    final titleStr = pageAsync.when(
      data: (p) => p.titleAr,
      loading: () => 'المساعدة',
      error: (_, __) => 'المساعدة',
    );

    return AppScaffold(
      title: titleStr,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: pageAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _ErrorBody(
          onRetry: () {
            ref.invalidate(helpPageProvider);
            ref.invalidate(helpItemsProvider);
          },
        ),
        data: (page) {
          return itemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _ErrorBody(
              onRetry: () {
                ref.invalidate(helpPageProvider);
                ref.invalidate(helpItemsProvider);
              },
            ),
            data: (items) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (page.introAr != null && page.introAr!.trim().isNotEmpty) ...[
                    Text(
                      page.introAr!,
                      style: AppTypography.body16.copyWith(
                        color: AppColors.bodyMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (page.contactEmail != null || page.contactPhone != null) ...[
                    _ContactSection(
                      email: page.contactEmail,
                      phone: page.contactPhone,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (items.isNotEmpty) ...[
                    Text('أسئلة شائعة', style: AppTypography.body16Semi),
                    const SizedBox(height: 12),
                  ],
                  if (items.isEmpty)
                    Text(
                      'لا محتوى مساعدة متاح حالياً.',
                      style: AppTypography.body16.copyWith(
                        color: AppColors.bodyMuted,
                      ),
                    ),
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _HelpExpansionTile(
                        title: item.titleAr,
                        body: item.bodyAr,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({this.email, this.phone});

  final String? email;
  final String? phone;

  Future<void> _open(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تواصل معنا', style: AppTypography.body16Semi),
          if (email != null && email!.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _open(Uri(scheme: 'mailto', path: email)),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      email!,
                      style: AppTypography.body16.copyWith(
                        color: AppColors.link,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (phone != null && phone!.isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _open(Uri(scheme: 'tel', path: phone)),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      phone!,
                      style: AppTypography.body16.copyWith(
                        color: AppColors.link,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HelpExpansionTile extends StatelessWidget {
  const _HelpExpansionTile({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(title, style: AppTypography.body16Semi),
          iconColor: AppColors.foreground,
          collapsedIconColor: AppColors.muted,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                body,
                style: AppTypography.body16.copyWith(
                  color: AppColors.bodyMuted,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'تعذّر تحميل المساعدة',
            style: AppTypography.body16.copyWith(color: AppColors.bodyMuted),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
