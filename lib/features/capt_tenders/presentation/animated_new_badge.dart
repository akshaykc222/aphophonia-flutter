import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/theme/app_colors.dart';

/// Pulsing «جديد» chip for CAPT tab and tender cards.
class AnimatedNewBadge extends StatelessWidget {
  const AnimatedNewBadge({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 3);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.link.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.link.withValues(alpha: 0.45)),
      ),
      child: Text(
        ArKwStrings.newBadge,
        style: TextStyle(
          fontSize: compact ? 9 : 10,
          fontWeight: FontWeight.w700,
          color: AppColors.link,
          height: 1.1,
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.05, 1.05),
          duration: 900.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .shimmer(
          duration: 1400.ms,
          color: AppColors.link.withValues(alpha: 0.35),
        );
  }
}
