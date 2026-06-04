import '../../../core/utils/json_parse.dart';

class TenderCategory {
  const TenderCategory({
    required this.id,
    required this.nameAr,
    required this.slug,
    this.nameEn,
    this.sortOrder = 0,
  });

  factory TenderCategory.fromJson(Map<String, dynamic> json) {
    return TenderCategory(
      id: JsonParse.reqString(json, 'id'),
      nameAr: JsonParse.reqString(json, 'name_ar'),
      nameEn: JsonParse.str(json, 'name_en'),
      slug: JsonParse.reqString(json, 'slug'),
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  final String id;
  final String nameAr;
  final String? nameEn;
  final String slug;
  final int sortOrder;
}
