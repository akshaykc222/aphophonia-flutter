import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/breakpoints.dart';
import '../../auth/presentation/widgets/auth_primary_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/responsive_center.dart';
import '../domain/content_item.dart';
import 'content_providers.dart';

class ContentDetailScreen extends ConsumerStatefulWidget {
  const ContentDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<ContentDetailScreen> createState() =>
      _ContentDetailScreenState();
}

class _ContentDetailScreenState extends ConsumerState<ContentDetailScreen> {
  bool _bookmarked = false;
  bool _bookmarkLoading = false;
  bool _liked = false;
  int _likeCount = 125;

  @override
  void initState() {
    super.initState();
    _loadBookmark();
    _loadLikes();
  }

  Future<void> _loadBookmark() async {
    final item = await ref.read(contentBySlugProvider(widget.slug).future);
    if (item == null || !mounted) return;
    final saved = await ref
        .read(bookmarksServiceProvider)
        .isBookmarked(item.id);
    if (mounted) setState(() => _bookmarked = saved);
  }

  Future<void> _toggleBookmark(String id) async {
    setState(() => _bookmarkLoading = true);
    await ref.read(bookmarksServiceProvider).toggle(id);
    ref.invalidate(bookmarkedIdsProvider);
    ref.invalidate(bookmarkedContentProvider);
    if (mounted) {
      setState(() {
        _bookmarked = !_bookmarked;
        _bookmarkLoading = false;
      });
    }
  }

  Future<void> _loadLikes() async {
    final item = await ref.read(contentBySlugProvider(widget.slug).future);
    if (item == null || !mounted) return;

    final likesSvc = ref.read(likesServiceProvider);
    final liked = await likesSvc.isLiked(item.id);

    if (mounted) {
      setState(() {
        _likeCount = item.likesCount;
        _liked = liked;
      });
    }
  }

  Future<void> _toggleLike(String id) async {
    final likesSvc = ref.read(likesServiceProvider);

    // Optimistic UI update
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });

    await likesSvc.toggle(id);
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentBySlugProvider(widget.slug));
    final bp = breakpointOf(context);

    return content.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(
          message: ArKwStrings.loadContentFailed,
          onRetry: () => ref.invalidate(contentBySlugProvider(widget.slug)),
        ),
      ),
      data: (item) {
        if (item == null) {
          return AppScaffold(
            body: EmptyState(title: ArKwStrings.contentNotFound),
          );
        }

        final body = _DetailBody(item: item);

        return AppScaffold(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              onPressed: _bookmarkLoading
                  ? null
                  : () => _toggleBookmark(item.id),
              icon: Icon(
                _bookmarked ? Icons.bookmark : Icons.bookmark_outline,
                color: _bookmarked ? AppColors.link : Colors.white,
              ),
            ),
          ],
          body: bp == AppBreakpoint.medium || bp == AppBreakpoint.expanded
              ? ResponsiveCenter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: SingleChildScrollView(child: body),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: _MetaPanel(item: item)),
                    ],
                  ),
                )
              : SingleChildScrollView(child: body),
          bottomNavigationBar: _DetailToolbar(
            liked: _liked,
            likeCount: _likeCount,
            onLike: () => _toggleLike(item.id),
            onShare: () {
              final domain = ref.read(supabaseConfiguredProvider)
                  ? 'https://apophenia-five.vercel.app'
                  : 'https://kuwaittoday.com';
              Share.share('$domain/content/${item.slug}');
            },
          ),
        );
      },
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageUrlsProvider);
    final logoUrl =
        storage?.resolveLogoUrl(item.ministry?.logoUrl ?? item.sourceLogoUrl) ??
        '';
    final published = item.publishedAt != null
        ? DateFormat('d MMMM yyyy', 'ar').format(item.publishedAt!)
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                item.typeLabelAr,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
          if (published != null) ...[
            const SizedBox(height: 12),
            Text(
              'نُشر في $published',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.bodyMuted),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            item.titleAr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ).animate().fadeIn().slideY(begin: 0.05, end: 0),
          if (item.summaryAr != null && item.summaryAr!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              item.summaryAr!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ],
          if (item.contentType == ContentType.tender) ...[
            const SizedBox(height: AppSpacing.lg),
            _TenderMeta(item: item),
          ],
          const SizedBox(height: 24),
          if (item.bodyAr != null && item.bodyAr!.isNotEmpty)
            Text(
              item.bodyAr!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.7,
                color: AppColors.foregroundSoft,
              ),
            )
          else
            Text(
              ArKwStrings.noFullText,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          const SizedBox(height: 32),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: 16),
          Row(
            children: [
              if (logoUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: logoUrl,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                )
              else
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surface,
                  child: Text(
                    item.displaySourceName[0],
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displaySourceName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (item.displayMinistryName != null)
                      Text(
                        item.displayMinistryName!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailToolbar extends StatelessWidget {
  const _DetailToolbar({
    required this.liked,
    required this.likeCount,
    required this.onLike,
    required this.onShare,
  });

  final bool liked;
  final int likeCount;
  final VoidCallback onLike;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: onLike,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: liked ? AppColors.error : AppColors.foreground,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$likeCount',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: onShare,
                icon: const Icon(Icons.ios_share_outlined, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaPanel extends StatelessWidget {
  const _MetaPanel({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: _TenderMeta(item: item),
    );
  }
}

class _TenderMeta extends StatelessWidget {
  const _TenderMeta({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    if (item.contentType != ContentType.tender &&
        item.applicationUrl == null &&
        item.deadlineAt == null) {
      return const SizedBox.shrink();
    }

    final deadline = item.deadlineAt != null
        ? DateFormat('d MMMM yyyy', 'ar').format(item.deadlineAt!)
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (deadline != null) ...[
            Text(
              ArKwStrings.deadline,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.muted),
            ),
            Text(deadline, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
          ],
          if (item.applicationUrl != null)
            AuthPrimaryButton(
              label: ArKwStrings.applyLink,
              onPressed: () async {
                final uri = Uri.tryParse(item.applicationUrl!);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
    );
  }
}
