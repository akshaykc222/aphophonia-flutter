import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';
import '../../../core/l10n/app_locale.dart';
import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../shared/widgets/legal_links.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/presentation/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).valueOrNull;
    final user = session?.user;
    final displayName = _displayName(user);
    final avatarLetter = (displayName ?? user?.email ?? '?')[0].toUpperCase();
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Blue header band (navy + SafeArea top) ──────────────────────
          Container(
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Page title
                    Text(
                      ArKwStrings.profile,
                      style: AppTypography.body16Semi.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Avatar + user info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              displayName ?? session?.user.email ?? '',
                              style: AppTypography.body16Semi.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayName != null
                                  ? (session?.user.email ?? ArKwStrings.manageAccount)
                                  : ArKwStrings.manageAccount,
                              style: AppTypography.body16.copyWith(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: session == null
                              ? null
                              : () => _editDisplayName(context, ref, displayName),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.searchBarBg,
                            child: Text(
                              avatarLetter,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── Menu list (white body) ───────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24, top: 16),
              children: [
                _sectionHeader(ArKwStrings.services),
                _tile(Icons.favorite_border, ArKwStrings.favorites,
                    () => context.push('/favorites')),
                _tile(Icons.notifications_none, ArKwStrings.notifications,
                    () => context.push('/notifications')),
                _tile(Icons.card_membership_outlined, ArKwStrings.subscription,
                    () => context.push('/subscription')),
                _sectionHeader(ArKwStrings.settings),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Row(
                    children: [
                      Icon(Icons.language, color: AppColors.foreground, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ArKwStrings.language,
                          style: AppTypography.body16.copyWith(fontSize: 16),
                        ),
                      ),
                      SegmentedButton<AppLocale>(
                        segments: [
                          ButtonSegment(
                            value: AppLocale.ar,
                            label: Text(ArKwStrings.languageArabic),
                          ),
                          ButtonSegment(
                            value: AppLocale.en,
                            label: Text(ArKwStrings.languageEnglish),
                          ),
                        ],
                        selected: {locale},
                        onSelectionChanged: (selected) {
                          ref
                              .read(localeProvider.notifier)
                              .setLocale(selected.first);
                        },
                      ),
                    ],
                  ),
                ),
                _tile(Icons.settings_outlined, ArKwStrings.settings, () {}),
                _tile(
                  Icons.privacy_tip_outlined,
                  ArKwStrings.privacyPolicy,
                  () => openLegalUrl(Env.privacyPolicyUrl),
                ),
                _tile(Icons.help_outline, ArKwStrings.help,
                    () => context.push('/help')),
                if (session == null)
                  _tile(
                    Icons.login,
                    ArKwStrings.signIn,
                    () => context.push('/auth/sign-in'),
                  )
                else
                  _tile(
                    Icons.logout,
                    ArKwStrings.signOut,
                    () async {
                      await ref.read(authRepositoryProvider)?.signOut();
                    },
                    destructive: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
  }

  String? _displayName(User? user) {
    if (user == null) return null;
    for (final key in ['display_name', 'full_name', 'name']) {
      final value = user.userMetadata?[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  Future<void> _editDisplayName(
    BuildContext context,
    WidgetRef ref,
    String? currentName,
  ) async {
    final controller = TextEditingController(text: currentName ?? '');
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ArKwStrings.fullName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: ArKwStrings.fullNameHint),
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ArKwStrings.continueBtn),
          ),
        ],
      ),
    );

    if (saved != true || !context.mounted) {
      controller.dispose();
      return;
    }

    final name = controller.text.trim();
    controller.dispose();
    if (name.isEmpty) return;

    try {
      await repo.updateDisplayName(name);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ الاسم')),
        );
      }
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title,
        style: AppTypography.body16.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
        ),
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool destructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: destructive ? AppColors.error : AppColors.link,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: destructive ? AppColors.error : AppColors.foreground,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.chevron_left, color: AppColors.muted),
      onTap: onTap,
    );
  }
}
