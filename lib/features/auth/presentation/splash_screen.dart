import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../onboarding/data/onboarding_prefs.dart';
/// Figma splash frame `23:905` — 375×812, fill `#171717`, logo 187×187 @ (94, 251).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const _designWidth = 375.0;
  static const _designHeight = 812.0;
  static const _logoSize = 187.0;
  static const _logoTop = 251.0;
  static const _logoLeft = 94.0;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final onboardingDone = await OnboardingPrefs.isComplete();
    if (!mounted) return;
    if (!onboardingDone) {
      context.go('/onboarding');
      return;
    }

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final scaleW = w / SplashScreen._designWidth;
            final scaleH = h / SplashScreen._designHeight;
            final logoSize = SplashScreen._logoSize * scaleW;
            final top = SplashScreen._logoTop * scaleH;
            final left = SplashScreen._logoLeft * scaleW;

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: left,
                  top: top,
                  width: logoSize,
                  height: logoSize,
                  child: Image.asset(
                    AppAssets.logo,
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.92, 0.92),
                        end: const Offset(1, 1),
                        duration: 700.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
