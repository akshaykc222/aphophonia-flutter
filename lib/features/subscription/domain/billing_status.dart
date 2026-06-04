class BillingStatus {
  const BillingStatus({
    required this.active,
    this.expiresAt,
    this.daysRemaining,
    this.isLifetime = false,
    this.planNameAr,
    this.planId,
    this.createdAt,
    this.planPriceKwd,
  });

  final bool active;
  final DateTime? expiresAt;
  final int? daysRemaining;
  final bool isLifetime;
  final String? planNameAr;
  final String? planId;
  final DateTime? createdAt;
  final double? planPriceKwd;

  factory BillingStatus.fromJson(Map<String, dynamic> json) {
    final sub = json['subscription'] as Map<String, dynamic>?;
    final plan = sub?['plan'] as Map<String, dynamic>?;
    final expiresRaw = sub?['expires_at'] as String?;
    final createdRaw = sub?['created_at'] as String? ?? sub?['started_at'] as String?;
    final isLifetime =
        json['is_lifetime'] as bool? ?? sub?['is_lifetime'] as bool? ?? false;
    final priceRaw = plan?['price_kwd'] as num?;

    return BillingStatus(
      active: json['active'] as bool? ?? false,
      expiresAt: expiresRaw != null ? DateTime.tryParse(expiresRaw) : null,
      daysRemaining: json['days_remaining'] as int?,
      isLifetime: isLifetime,
      planNameAr: plan?['name_ar'] as String?,
      planId: sub?['plan_id'] as String? ?? plan?['id'] as String?,
      createdAt: createdRaw != null ? DateTime.tryParse(createdRaw) : null,
      planPriceKwd: priceRaw?.toDouble(),
    );
  }
}

class CheckoutSession {
  const CheckoutSession({
    required this.transactionId,
    this.paymentUrl,
    this.sessionId,
    this.invoiceId,
  });

  final String transactionId;
  final String? paymentUrl;
  final String? sessionId;
  final int? invoiceId;

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      transactionId: json['transactionId'] as String,
      paymentUrl: json['paymentUrl'] as String?,
      sessionId: json['sessionId'] as String?,
      invoiceId: json['invoiceId'] as int?,
    );
  }
}
