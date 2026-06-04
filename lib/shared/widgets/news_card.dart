import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/content/domain/content_item.dart';
import '../animations/app_animations.dart';

class NewsCard extends ConsumerWidget {
  const NewsCard({
    super.key,
    required this.item,
    this.index = 0,
    this.compact = false,
  });

  final ContentItem item;
  final int index;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageUrlsProvider);
    final logoPath = item.ministry?.logoUrl ?? item.sourceLogoUrl;
    final logoUrl = storage?.resolveLogoUrl(logoPath) ?? '';
    final subtitle = item.displayMinistryName ?? item.displaySourceName;
    final published = item.publishedAt != null
        ? DateFormat('d MMM yyyy', 'ar').format(item.publishedAt!)
        : null;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/content/${item.slug}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _Avatar(logoUrl: logoUrl, fallback: subtitle),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: AppTypography.caption12.copyWith(
                        color: AppColors.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                      item.typeLabelAr,
                      style: AppTypography.caption12.copyWith(fontSize: 10),
                    ),
                  ),
                  if (published != null) ...[
                    const SizedBox(width: 8),
                    Text(published, style: AppTypography.caption12),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.titleAr,
                style: AppTypography.body16Semi.copyWith(
                  fontWeight: compact ? FontWeight.w600 : FontWeight.w700,
                ),
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.summaryAr != null && item.summaryAr!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.summaryAr!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body16.copyWith(
                    fontSize: 14,
                    color: compact ? AppColors.bodyMuted : AppColors.muted,
                    height: 20 / 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).listItemAnimate(index);
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.logoUrl, required this.fallback});

  final String logoUrl;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    if (logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          width: 20,
          height: 20,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _LetterAvatar(fallback),
        ),
      );
    }
    return _LetterAvatar(fallback);
  }
}

class _LetterAvatar extends StatelessWidget {
  const _LetterAvatar(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
        color: AppColors.background,
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0] : 'ك',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class FeaturedNewsCard extends StatelessWidget {
  const FeaturedNewsCard({super.key, required this.item, this.width = 319});

  final ContentItem item;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: NewsCard(item: item, compact: true),
    );
  }
}
