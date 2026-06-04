import 'package:flutter/material.dart';

enum AppBreakpoint { compact, medium, expanded }

AppBreakpoint breakpointOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= 900) return AppBreakpoint.expanded;
  if (width >= 600) return AppBreakpoint.medium;
  return AppBreakpoint.compact;
}

bool isCompact(BuildContext context) =>
    breakpointOf(context) == AppBreakpoint.compact;
