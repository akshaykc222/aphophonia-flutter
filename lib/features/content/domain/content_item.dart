import '../../../core/utils/json_parse.dart';
import '../../reference/domain/category.dart';
import '../../reference/domain/ministry.dart';

enum ContentType { article, tender, decree, addendum }

ContentType contentTypeFromString(String? value) {
  if (value == null || value.isEmpty) return ContentType.article;
  return ContentType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ContentType.article,
  );
}

class ContentItem {
  const ContentItem({
    required this.id,
    required this.titleAr,
    this.summaryAr,
    this.bodyAr,
    required this.slug,
    required this.contentType,
    this.categoryId,
    this.ministryId,
    this.tenderCategoryId,
    this.sourceName,
    this.sourceLogoUrl,
    this.isFeatured = false,
    this.publishedAt,
    this.deadlineAt,
    this.applicationUrl,
    this.tags = const [],
    this.ministry,
    this.category,
    this.likesCount = 0,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    final ministryMap = JsonParse.map(json['ministry']);
    final categoryMap = JsonParse.map(json['category']);

    return ContentItem(
      id: JsonParse.reqString(json, 'id'),
      titleAr: JsonParse.reqString(json, 'title_ar', fallback: 'بدون عنوان'),
      summaryAr: JsonParse.str(json, 'summary_ar'),
      bodyAr: JsonParse.str(json, 'body_ar'),
      slug: JsonParse.reqString(json, 'slug', fallback: json['id']?.toString() ?? ''),
      contentType: contentTypeFromString(JsonParse.str(json, 'content_type')),
      categoryId: JsonParse.str(json, 'category_id'),
      ministryId: JsonParse.str(json, 'ministry_id'),
      tenderCategoryId: JsonParse.str(json, 'tender_category_id'),
      sourceName: JsonParse.str(json, 'source_name'),
      sourceLogoUrl: JsonParse.str(json, 'source_logo_url'),
      isFeatured: json['is_featured'] as bool? ?? false,
      publishedAt: _parseDate(json['published_at']),
      deadlineAt: _parseDate(json['deadline_at']),
      applicationUrl: JsonParse.str(json, 'application_url'),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      ministry:
          ministryMap != null ? Ministry.fromJson(ministryMap) : null,
      category:
          categoryMap != null ? AppCategory.fromJson(categoryMap) : null,
      likesCount: json['likes_count'] as int? ?? 0,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  final String id;
  final String titleAr;
  final String? summaryAr;
  final String? bodyAr;
  final String slug;
  final ContentType contentType;
  final String? categoryId;
  final String? ministryId;
  final String? tenderCategoryId;
  final String? sourceName;
  final String? sourceLogoUrl;
  final bool isFeatured;
  final DateTime? publishedAt;
  final DateTime? deadlineAt;
  final String? applicationUrl;
  final List<String> tags;
  final Ministry? ministry;
  final AppCategory? category;
  final int likesCount;

  String get displaySourceName => sourceName ?? 'السور';

  String? get displayMinistryName => ministry?.nameAr;

  String get typeLabelAr {
    switch (contentType) {
      case ContentType.article:
        return 'خبر';
      case ContentType.tender:
        return 'مناقصة';
      case ContentType.decree:
        return 'مرسوم';
      case ContentType.addendum:
        return 'استدراك';
    }
  }
}
