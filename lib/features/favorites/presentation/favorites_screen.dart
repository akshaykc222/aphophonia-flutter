import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/ar_kw_strings.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/news_card.dart';
import '../../content/presentation/content_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(bookmarkedContentProvider);

    return AppScaffold(
      title: ArKwStrings.favorites,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: saved.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            EmptyState(title: ArKwStrings.loadFavoritesFailed),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              title: ArKwStrings.favoritesEmpty,
              icon: Icons.favorite_border,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: NewsCard(item: items[i], index: i),
            ),
          );
        },
      ),
    );
  }
}
