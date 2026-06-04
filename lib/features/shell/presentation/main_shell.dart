import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/env.dart';
import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../subscription/presentation/billing_providers.dart';
import '../../subscription/presentation/subscription_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _index(String location) {
    if (location.startsWith('/assistant')) return 1;
    if (location.startsWith('/tender')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _index(location);

    if (!Env.isBillingConfigured) {
      return _BillingConfigError(
        message: ArKwStrings.billingNotConfigured,
      );
    }

    final billingAsync = ref.watch(billingStatusProvider);

    if (billingAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (billingAsync.hasError) {
      return _BillingConfigError(
        message: ArKwStrings.billingStatusLoadFailed,
        onRetry: () => ref.invalidate(billingStatusProvider),
      );
    }

    if (billingAsync.hasValue && billingAsync.value!.active == false) {
      return const SubscriptionScreen(required: true);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
            child: Row(
              children: [
                _NavItem(
                  label: ArKwStrings.navHome,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  selected: index == 0,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  label: ArKwStrings.navAssistant,
                  icon: Icons.smart_toy_outlined,
                  selectedIcon: Icons.smart_toy,
                  selected: index == 1,
                  onTap: () => context.go('/assistant'),
                ),
                _NavItem(
                  label: ArKwStrings.navTenders,
                  icon: Icons.description_outlined,
                  selectedIcon: Icons.description,
                  selected: index == 2,
                  onTap: () => context.go('/tender'),
                ),
                _NavItem(
                  label: ArKwStrings.navProfile,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  selected: index == 3,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BillingConfigError extends StatelessWidget {
  const _BillingConfigError({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.muted),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTypography.body16.copyWith(color: AppColors.muted),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: onRetry,
                    child: Text(ArKwStrings.retry),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.link : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.navLabel.copyWith(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
