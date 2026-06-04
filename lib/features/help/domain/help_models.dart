class HelpPage {
  const HelpPage({
    required this.titleAr,
    this.introAr,
    this.contactEmail,
    this.contactPhone,
  });

  final String titleAr;
  final String? introAr;
  final String? contactEmail;
  final String? contactPhone;

  factory HelpPage.fromJson(Map<String, dynamic> json) {
    return HelpPage(
      titleAr: json['title_ar'] as String? ?? 'المساعدة',
      introAr: json['intro_ar'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
    );
  }
}

class HelpItem {
  const HelpItem({
    required this.id,
    required this.titleAr,
    required this.bodyAr,
    required this.sortOrder,
  });

  final String id;
  final String titleAr;
  final String bodyAr;
  final int sortOrder;

  factory HelpItem.fromJson(Map<String, dynamic> json) {
    return HelpItem(
      id: json['id'] as String,
      titleAr: json['title_ar'] as String,
      bodyAr: json['body_ar'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
