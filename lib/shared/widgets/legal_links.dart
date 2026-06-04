import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/env.dart';
import '../../core/l10n/ar_kw_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

Future<void> openLegalUrl(String url) async {
  if (url.isEmpty) return;
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Sign-up terms row with tappable privacy & terms links.
class SignUpLegalText extends StatelessWidget {
  const SignUpLegalText({super.key});

  @override
  Widget build(BuildContext context) {
    final privacy = Env.privacyPolicyUrl;
    final terms = Env.termsUrl;
    final baseStyle = AppTypography.body16.copyWith(
      fontSize: 13,
      color: AppColors.muted,
      height: 1.4,
    );
    final linkStyle = baseStyle.copyWith(
      color: AppColors.link,
      decoration: TextDecoration.underline,
    );

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: 'بالمتابعة، أنت توافق على '),
          TextSpan(
            text: ArKwStrings.termsOfUse,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => openLegalUrl(terms),
          ),
          const TextSpan(text: ' و'),
          TextSpan(
            text: ArKwStrings.privacyPolicy,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => openLegalUrl(privacy),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
