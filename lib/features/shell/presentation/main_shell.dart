import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/presentation/auth_providers.dart';

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

    final session = ref.watch(authSessionProvider).valueOrNull;

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
                  onTap: () {
                    if (session == null) {
                      context.push('/auth/sign-in?redirect=${Uri.encodeComponent('/assistant')}');
                    } else {
                      context.go('/assistant');
                    }
                  },
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
