import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/breakpoints.dart';

class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bp = breakpointOf(context);
    final maxWidth = switch (bp) {
      AppBreakpoint.compact => double.infinity,
      AppBreakpoint.medium => AppSpacing.maxContentWidth,
      AppBreakpoint.expanded => AppSpacing.maxContentWidth,
    };

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
