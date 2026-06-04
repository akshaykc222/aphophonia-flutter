import '../../../core/utils/json_parse.dart';

class AppCategory {
  const AppCategory({
    required this.id,
    required this.nameAr,
    required this.slug,
    this.nameEn,
    this.badgeEmoji,
    this.isTrending = false,
    this.sortOrder = 0,
  });

  factory AppCategory.fromJson(Map<String, dynamic> json) {
    return AppCategory(
      id: JsonParse.reqString(json, 'id'),
      nameAr: JsonParse.reqString(json, 'name_ar'),
      nameEn: JsonParse.str(json, 'name_en'),
      slug: JsonParse.reqString(json, 'slug'),
      badgeEmoji: JsonParse.str(json, 'badge_emoji'),
      isTrending: json['is_trending'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  final String id;
  final String nameAr;
  final String? nameEn;
  final String slug;
  final String? badgeEmoji;
  final bool isTrending;
  final int sortOrder;

  String get tabLabel {
    if (badgeEmoji != null && badgeEmoji!.isNotEmpty) {
      return '$badgeEmoji $nameAr';
    }
    if (isTrending) return '🔥 $nameAr';
    return nameAr;
  }
}
