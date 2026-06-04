import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/auth_providers.dart';
import '../../features/onboarding/data/onboarding_prefs.dart';
import '../../features/subscription/presentation/billing_providers.dart';

/// Resolves the next route after splash: auth → subscription → onboarding → home.
Future<String> resolveEntryRoute(WidgetRef ref) async {
  final session = ref.read(authSessionProvider).valueOrNull;
  if (session == null) return '/auth/sign-in';

  final repo = ref.read(billingRepositoryProvider);
  if (repo != null) {
    try {
      final status = await repo.fetchMyStatus();
      if (!status.active) return '/subscription';
    } catch (_) {
      return '/subscription';
    }
  } else {
    return '/subscription';
  }

  final onboardingDone = await OnboardingPrefs.isComplete();
  if (!onboardingDone) return '/onboarding';

  return '/';
}
