import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/env.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/responsive_center.dart';
import '../../onboarding/data/onboarding_prefs.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('السور'),
              subtitle: Text(
                Env.isConfigured
                    ? 'متصل بـ Supabase'
                    : 'غير متصل — أضف مفاتيح .env',
              ),
            ),
            const Divider(color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.replay),
              title: const Text('إعادة عرض التعريف'),
              onTap: () async {
                await OnboardingPrefs.reset();
                if (context.mounted) context.go('/onboarding');
              },
            ),
            if (kDebugMode) ...[
              const Divider(color: AppColors.border),
              ListTile(
                leading: const Icon(Icons.developer_mode),
                title: const Text('مكوّنات الواجهة (تطوير)'),
                onTap: () => context.push('/dev/components'),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              'الإصدار 1.0.0',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
