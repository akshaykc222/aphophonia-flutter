import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';

import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../onboarding/data/onboarding_prefs.dart';
import '../../auth/presentation/widgets/auth_primary_button.dart';
import '../data/billing_repository.dart';
import '../domain/billing_status.dart';
import '../domain/subscription_plan.dart';
import 'billing_providers.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key, this.required = false});

  /// When true, hide back button (paywall mode).
  final bool required;

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen>
    with WidgetsBindingObserver {
  String? _loadingPlanId;
  String? _error;
  bool _polling = false;
  bool _awaitingPayment = false;
  bool _paymentSuccess = false;
  bool _paymentFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingPayment) {
      _refreshPaymentStatus();
    }
  }

  Future<void> _refreshPaymentStatus() async {
    final repo = ref.read(billingRepositoryProvider);
    if (repo == null) return;

    setState(() {
      _polling = true;
      _error = null;
    });

    try {
      final status = await repo.fetchMyStatus();
      ref.invalidate(billingStatusProvider);

      if (!mounted) return;
      if (status.active) {
        setState(() {
          _awaitingPayment = false;
          _paymentSuccess = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = ArKwStrings.billingStatusLoadFailed);
      }
    } finally {
      if (mounted) setState(() => _polling = false);
    }
  }

  String _checkoutErrorMessage(Object e) {
    if (e is BillingException) {
      switch (e.code) {
        case 'gateway_unavailable':
        case 'checkout_503':
        case 'gateway_credentials':
          return ArKwStrings.billingGatewayUnavailable;
        case 'unauthorized':
          return ArKwStrings.chatUnauthorized;
        default:
          return ArKwStrings.billingCheckoutFailed;
      }
    }
    return ArKwStrings.billingCheckoutFailed;
  }

  Future<MFPaymentMethod?> _showPaymentMethodSelector(
    BuildContext context,
    List<MFPaymentMethod> methods,
    double amount,
  ) {
    return showModalBottomSheet<MFPaymentMethod>(
      context: context,
      backgroundColor: AppColors.surface,
      elevation: 5,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'طريقة الدفع', // Payment Method
                  style: AppTypography.h4Bold.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'المبلغ المطلوب: ${amount.toStringAsFixed(3)} د.ك',
                  style: AppTypography.body16.copyWith(
                    color: AppColors.muted,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.borderSubtle),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: methods.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final method = methods[index];
                      final name =
                          method.paymentMethodAr ??
                          method.paymentMethodEn ??
                          '';
                      return InkWell(
                        onTap: () => Navigator.of(context).pop(method),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderSubtle),
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.background.withValues(alpha: 0.2),
                          ),
                          child: Row(
                            children: [
                              if (method.imageUrl != null &&
                                  method.imageUrl!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: CachedNetworkImage(
                                    imageUrl: method.imageUrl!,
                                    width: 45,
                                    height: 30,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) =>
                                        const SizedBox(
                                          width: 45,
                                          height: 30,
                                          child: Center(
                                            child: SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.link),
                                              ),
                                            ),
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                          Icons.payment,
                                          size: 24,
                                          color: AppColors.muted,
                                        ),
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.payment,
                                  size: 24,
                                  color: AppColors.muted,
                                ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  name,
                                  style: AppTypography.body16Semi,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.muted,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _subscribe(SubscriptionPlan plan) async {
    final repo = ref.read(billingRepositoryProvider);
    if (repo == null) {
      if (kDebugMode) {
        debugPrint('[Billing] subscribe blocked: billing repo not configured');
      }
      setState(() => _error = ArKwStrings.billingNotConfigured);
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '[Billing] subscribe tapped: plan=${plan.id} name=${plan.nameAr} '
        'price=${plan.priceLabel}',
      );
    }

    setState(() {
      _loadingPlanId = plan.id;
      _error = null;
      _paymentSuccess = false;
      _paymentFailed = false;
    });

    try {
      final session = await repo.startCheckout(plan.id, nativeSdk: true);

      if (!mounted) return;

      final initiateRequest = MFInitiatePaymentRequest(
        invoiceAmount: plan.priceKwd,
        currencyIso: 'KWD',
      );
      final initiateResponse = await MFSDK.initiatePayment(
        initiateRequest,
        'ar',
      );
      final methods = initiateResponse.paymentMethods ?? [];

      if (methods.isEmpty) {
        throw BillingException('gateway_unavailable');
      }

      if (!mounted) return;
      final selectedMethod = await _showPaymentMethodSelector(
        context,
        methods,
        plan.priceKwd,
      );
      if (selectedMethod == null) {
        setState(() {
          _loadingPlanId = null;
        });
        return;
      }

      setState(() {
        _loadingPlanId = plan.id;
      });

      final user = ref.read(supabaseClientProvider)?.auth.currentUser;
      final meta = user?.userMetadata;
      String? customerName;
      for (final key in ['display_name', 'full_name', 'name']) {
        final value = meta?[key];
        if (value is String && value.trim().isNotEmpty) {
          customerName = value.trim();
          break;
        }
      }
      final email = user?.email?.trim();
      final phone = user?.phone?.trim();

      String? createdInvoiceId;
      final executeRequest = MFExecutePaymentRequest(
        paymentMethodId: selectedMethod.paymentMethodId,
        invoiceValue: plan.priceKwd,
      );
      executeRequest.displayCurrencyIso = 'KWD';
      executeRequest.customerReference = session.transactionId;
      executeRequest.userDefinedField = session.transactionId;
      if (customerName != null) executeRequest.customerName = customerName;
      if (email != null) executeRequest.customerEmail = email;
      if (phone != null) executeRequest.customerMobile = phone;

      final response = await MFSDK.executePayment(executeRequest, 'ar', (
        String invoiceId,
      ) {
        createdInvoiceId = invoiceId;
      });

      final invoiceId = response.invoiceId?.toString() ?? createdInvoiceId;
      if (invoiceId == null) {
        throw BillingException('missing_invoice_id');
      }

      final isPaid = response.invoiceStatus == 'Paid';
      if (!isPaid) {
        throw BillingException('payment_failed');
      }

      final regSuccess = await repo.registerNativePayment(
        transactionId: session.transactionId,
        invoiceId: invoiceId,
        status: 'success',
      );
      if (!regSuccess) {
        throw BillingException('register_failed');
      }

      setState(() {
        _polling = true;
      });
      final status = await repo.pollUntilActive();

      if (!mounted) return;
      setState(() {
        _polling = false;
      });

      if (status.active) {
        setState(() {
          _paymentSuccess = true;
        });
      } else {
        setState(() {
          _error = ArKwStrings.billingPendingConfirmation;
          _paymentFailed = true;
        });
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[Billing] subscribe error: $e');
        debugPrint('[Billing] $st');
      }
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('cancel') ||
          errStr.contains('user') ||
          errStr.contains('close')) {
        setState(() {
          _error = ArKwStrings.paymentCancelled;
        });
      } else {
        final detail = kDebugMode ? ' (${e.toString()})' : '';
        setState(() {
          _error = '${_checkoutErrorMessage(e)}$detail';
          _paymentFailed = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingPlanId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final statusAsync = ref.watch(billingStatusProvider);

    return AppScaffold(
      title: ArKwStrings.subscriptionTitle,
      leading: widget.required || _paymentSuccess || _paymentFailed
          ? const SizedBox.shrink()
          : IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => context.pop(),
            ),
      actions: widget.required && !_paymentSuccess && !_paymentFailed
          ? [
              TextButton(
                onPressed: () async {
                  await ref.read(authRepositoryProvider)?.signOut();
                },
                child: Text(
                  ArKwStrings.signOut,
                  style: AppTypography.body16.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ]
          : null,
      body: _paymentSuccess
          ? _SuccessView(
              required: widget.required,
              onContinue: () async {
                ref.invalidate(billingStatusProvider);
                if (widget.required) {
                  final onboardingDone = await OnboardingPrefs.isComplete();
                  if (!context.mounted) return;
                  context.go(onboardingDone ? '/' : '/onboarding');
                } else {
                  context.pop(true);
                }
              },
            )
          : (_paymentFailed
                ? _FailureView(
                    error: _error,
                    onRetry: () {
                      setState(() {
                        _paymentFailed = false;
                        _error = null;
                      });
                    },
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        widget.required
                            ? ArKwStrings.subscriptionPaywallIntro
                            : ArKwStrings.subscriptionIntro,
                        style: AppTypography.body16.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      if (statusAsync.valueOrNull?.active == true) ...[
                        const SizedBox(height: AppSpacing.md),
                        _ActiveSubscriptionCard(status: statusAsync.value!),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                      if (_polling) ...[
                        const SizedBox(height: AppSpacing.lg),
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            ArKwStrings.billingConfirmingPayment,
                            style: AppTypography.body16.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                      if (_awaitingPayment && !_polling) ...[
                        const SizedBox(height: AppSpacing.lg),
                        AuthPrimaryButton(
                          label: ArKwStrings.billingCheckPayment,
                          onPressed: _refreshPaymentStatus,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      plansAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => Text(
                          ArKwStrings.billingPlansLoadFailed,
                          style: AppTypography.body16.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        data: (plans) {
                          if (plans.isEmpty) {
                            return Text(
                              ArKwStrings.billingNoPlans,
                              style: AppTypography.body16.copyWith(
                                color: AppColors.muted,
                              ),
                            );
                          }
                          return Column(
                            children: [
                              for (var i = 0; i < plans.length; i++) ...[
                                if (i > 0)
                                  const SizedBox(height: AppSpacing.md),
                                _PricingCard(
                                  plan: plans[i],
                                  highlighted:
                                      i == plans.length - 1 && plans.length > 1,
                                  badge:
                                      i == plans.length - 1 && plans.length > 1
                                      ? ArKwStrings.bestValue
                                      : null,
                                  loading: _loadingPlanId == plans[i].id,
                                  isCurrent:
                                      statusAsync.valueOrNull?.planId ==
                                      plans[i].id,
                                  onSubscribe: () => _subscribe(plans[i]),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  )),
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.plan,
    required this.onSubscribe,
    this.badge,
    this.highlighted = false,
    this.loading = false,
    this.isCurrent = false,
  });

  final SubscriptionPlan plan;
  final VoidCallback onSubscribe;
  final String? badge;
  final bool highlighted;
  final bool loading;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final border = isCurrent
        ? Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 1.5,
          )
        : (highlighted
              ? Border.all(color: AppColors.link.withValues(alpha: 0.5))
              : null);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(plan.nameAr, style: AppTypography.body16Semi),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ArKwStrings.currentPlan,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.link.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(fontSize: 12, color: AppColors.link),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.priceLabel,
            style: AppTypography.h4Bold.copyWith(fontSize: 28),
          ),
          if (plan.durationLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              plan.durationLabel,
              style: AppTypography.body16.copyWith(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ],
          if (plan.descriptionAr != null && plan.descriptionAr!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              plan.descriptionAr!,
              style: AppTypography.body16.copyWith(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ],
          if (plan.features.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final feature in plan.features)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, size: 18, color: AppColors.link),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: AppTypography.body16.copyWith(
                          fontSize: 14,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AuthPrimaryButton(
            label: isCurrent ? ArKwStrings.currentPlan : ArKwStrings.subscribe,
            loading: loading,
            onPressed: isCurrent ? null : onSubscribe,
          ),
        ],
      ),
    );
  }
}

class _ActiveSubscriptionCard extends StatelessWidget {
  const _ActiveSubscriptionCard({required this.status});

  final BillingStatus status;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'ar');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.link.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: AppColors.link,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ArKwStrings.currentSubscription,
                  style: AppTypography.body16Semi,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.link.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.link,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ArKwStrings.activeStatus,
                      style: AppTypography.caption12.copyWith(
                        color: AppColors.link,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 16),
          _buildDetailRow(
            label: ArKwStrings.subscriptionTitle,
            value: status.planNameAr ?? ArKwStrings.appName,
          ),
          if (status.planPriceKwd != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              label: ArKwStrings.subscriptionPrice,
              value: '${status.planPriceKwd!.toStringAsFixed(3)} د.ك',
            ),
          ],
          if (status.createdAt != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              label: ArKwStrings.purchaseDate,
              value: dateFormat.format(status.createdAt!),
            ),
          ],
          const SizedBox(height: 12),
          _buildDetailRow(
            label: ArKwStrings.expiryDate,
            value: status.isLifetime
                ? ArKwStrings.subscriptionActiveLifetime
                : (status.expiresAt != null
                      ? dateFormat.format(status.expiresAt!)
                      : '-'),
          ),
          if (!status.isLifetime && status.daysRemaining != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              label: ArKwStrings.daysRemainingLabel,
              value: '${status.daysRemaining} يوماً',
              valueColor: AppColors.link,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.body16.copyWith(
            fontSize: 14,
            color: AppColors.muted,
          ),
        ),
        Text(
          value,
          style: AppTypography.body16Semi.copyWith(
            fontSize: 14,
            color: valueColor ?? AppColors.foregroundSoft,
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatefulWidget {
  const _SuccessView({required this.required, required this.onContinue});

  final bool required;
  final VoidCallback onContinue;

  @override
  State<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<_SuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _controller.animateTo(0.95);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Lottie.asset(
                'assets/lottie/90ed30d6-1188-11ee-b87c-4bb1d187c461.json',
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
                  ArKwStrings.paymentSuccess,
                  style: AppTypography.h4Bold,
                  textAlign: TextAlign.center,
                )
                .animate()
                .slideY(
                  begin: 1.5,
                  end: 0.0,
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 800.ms),
            const SizedBox(height: AppSpacing.md),
            Text(
                  'استمتع بكافة المزايا والمحتوى الآن.',
                  style: AppTypography.body16.copyWith(color: AppColors.muted),
                  textAlign: TextAlign.center,
                )
                .animate()
                .slideY(
                  begin: 2.0,
                  end: 0.0,
                  duration: 900.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 900.ms),
            const SizedBox(height: AppSpacing.xl),
            AuthPrimaryButton(
                  label: ArKwStrings.continueBtn,
                  onPressed: widget.onContinue,
                )
                .animate()
                .slideY(
                  begin: 2.5,
                  end: 0.0,
                  duration: 1000.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 1000.ms),
          ],
        ),
      ),
    );
  }
}

class _FailureView extends StatefulWidget {
  const _FailureView({required this.error, required this.onRetry});

  final String? error;
  final VoidCallback onRetry;

  @override
  State<_FailureView> createState() => _FailureViewState();
}

class _FailureViewState extends State<_FailureView> {
  bool _playLottie = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _playLottie = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Lottie.asset(
                'assets/lottie/failure.json',
                repeat: false,
                animate: _playLottie,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
                  ArKwStrings.paymentFailed,
                  style: AppTypography.h4Bold,
                  textAlign: TextAlign.center,
                )
                .animate()
                .slideY(
                  begin: 1.5,
                  end: 0.0,
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 800.ms),
            const SizedBox(height: AppSpacing.md),
            Text(
                  'يرجى التحقق من بيانات الدفع أو المحاولة لاحقاً.',
                  style: AppTypography.body16.copyWith(color: AppColors.muted),
                  textAlign: TextAlign.center,
                )
                .animate()
                .slideY(
                  begin: 2.0,
                  end: 0.0,
                  duration: 900.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 900.ms),
            if (widget.error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                    widget.error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .slideY(
                    begin: 2.2,
                    end: 0.0,
                    duration: 950.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 950.ms),
            ],
            const SizedBox(height: AppSpacing.xl),
            AuthPrimaryButton(
                  label: ArKwStrings.retry,
                  onPressed: widget.onRetry,
                )
                .animate()
                .slideY(
                  begin: 2.5,
                  end: 0.0,
                  duration: 1000.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 1000.ms),
          ],
        ),
      ),
    );
  }
}
