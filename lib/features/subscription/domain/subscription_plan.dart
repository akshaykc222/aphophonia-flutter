class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.descriptionAr,
    required this.priceKwd,
    this.durationDays,
    this.isLifetime = false,
    required this.sortOrder,
    this.features = const [],
  });

  final String id;
  final String nameAr;
  final String? nameEn;
  final String? descriptionAr;
  final double priceKwd;
  final int? durationDays;
  final bool isLifetime;
  final int sortOrder;
  final List<String> features;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    final isLifetime = json['is_lifetime'] as bool? ?? false;
    return SubscriptionPlan(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      priceKwd: (json['price_kwd'] as num).toDouble(),
      durationDays: json['duration_days'] as int?,
      isLifetime: isLifetime,
      sortOrder: json['sort_order'] as int? ?? 0,
      features: rawFeatures is List
          ? rawFeatures.map((e) => e.toString()).toList()
          : const [],
    );
  }

  String get priceLabel => '${priceKwd.toStringAsFixed(3)} د.ك';

  String get durationLabel {
    if (isLifetime) return 'مدى الحياة';
    final days = durationDays;
    if (days == null) return '';
    if (days == 30) return '30 يوماً';
    if (days == 90) return '90 يوماً';
    if (days == 365) return 'سنة';
    return '$days يوماً';
  }
}
