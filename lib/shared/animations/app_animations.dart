import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension AppListAnimate on Widget {
  Widget listItemAnimate(int index, {int maxStagger = 8}) {
    final delay = Duration(milliseconds: 50 * (index.clamp(0, maxStagger)));
    return animate(delay: delay)
        .fadeIn(duration: 280.ms, curve: Curves.easeOut)
        .slideY(begin: 0.08, end: 0, duration: 280.ms, curve: Curves.easeOut);
  }
}
