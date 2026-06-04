import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/billing_repository.dart';
import '../domain/billing_status.dart';
import '../domain/subscription_plan.dart';

final billingRepositoryProvider = Provider<BillingRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null || !Env.isBillingConfigured) return null;
  return BillingRepository(
    supabase: client,
    adminApiUrl: Env.adminApiUrl,
  );
});

final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlan>>((ref) async {
  if (!Env.isBillingConfigured) return [];
  final repo = ref.watch(billingRepositoryProvider);
  if (repo == null) return [];
  return repo.fetchPlans();
});

final billingStatusProvider = FutureProvider<BillingStatus>((ref) async {
  final session = ref.watch(authSessionProvider).valueOrNull;
  if (session == null) {
    return const BillingStatus(active: false);
  }
  final repo = ref.watch(billingRepositoryProvider);
  if (repo == null) {
    return const BillingStatus(active: false);
  }
  return repo.fetchMyStatus();
});

final hasActiveSubscriptionProvider = Provider<bool>((ref) {
  return ref.watch(billingStatusProvider).valueOrNull?.active ?? false;
});
