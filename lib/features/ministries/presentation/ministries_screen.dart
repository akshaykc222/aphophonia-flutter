import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/responsive_center.dart';
import '../../reference/presentation/reference_providers.dart';

class MinistriesScreen extends ConsumerWidget {
  const MinistriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ministries = ref.watch(ministriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الوزارات')),
      body: ResponsiveCenter(
        child: ministries.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(
            message: 'تعذر تحميل الوزارات',
            onRetry: () => ref.invalidate(ministriesProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(title: 'لا توجد وزارات');
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, i) {
                final m = items[i];
                return ListTile(
                  leading: m.logoUrl != null
                      ? CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(m.logoUrl!),
                        )
                      : CircleAvatar(
                          child: Text(
                            m.nameAr.isNotEmpty ? m.nameAr[0] : '?',
                          ),
                        ),
                  title: Text(m.nameAr),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => context.push('/ministries/${m.slug}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
