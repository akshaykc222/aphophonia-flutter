import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/news_card.dart';
import '../../content/presentation/content_providers.dart';
import 'package:lottie/lottie.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _runSearch(String value) {
    final q = value.trim();
    ref.read(searchQueryProvider.notifier).state = q;
    if (q.isNotEmpty) {
      ref.read(searchHistoryServiceProvider).add(q);
      ref.invalidate(recentSearchesProvider);
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      ref.read(searchQueryProvider.notifier).state = '';
      setState(() {});
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _runSearch(value);
      setState(() {});
    });
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    setState(() {});
    _focusNode.requestFocus();
  }

  Future<void> _removeRecent(String q) async {
    await ref.read(searchHistoryServiceProvider).remove(q);
    ref.invalidate(recentSearchesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final apiQuery = ref.watch(searchQueryProvider);
    final recent = ref.watch(recentSearchesProvider);
    final hasQuery = apiQuery.trim().isNotEmpty;
    final results =
        hasQuery ? ref.watch(searchResultsProvider(apiQuery)) : null;

    return AppScaffold(
      title: ArKwStrings.searchHint,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: _onChanged,
                      onSubmitted: _runSearch,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(color: AppColors.foreground),
                      decoration: const InputDecoration(
                        hintText: ArKwStrings.searchArticles,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _clear,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: !hasQuery
                ? recent.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (items) {
                      if (items.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Lottie.asset(
                                  'assets/lottie/search.json',
                                  width: 200,
                                  height: 200,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'ابحث عن الأخبار والمناقصات والمراسيم',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Text(
                            ArKwStrings.recentSearch,
                            style: AppTypography.body16Semi,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ...items.map(
                            (q) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.history,
                                size: 20,
                                color: AppColors.muted,
                              ),
                              title: Text(q, style: AppTypography.body16),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => _removeRecent(q),
                              ),
                              onTap: () {
                                _controller.text = q;
                                _runSearch(q);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : results!.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => ErrorState(
                      message: ArKwStrings.searchFailed,
                      detail: kDebugMode ? '$e' : null,
                      onRetry: () =>
                          ref.invalidate(searchResultsProvider(apiQuery)),
                    ),
                    data: (items) {
                      if (items.isEmpty) {
                        return EmptyState(
                          title: ArKwStrings.noResults(apiQuery),
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
          ),
        ],
      ),
    );
  }
}
