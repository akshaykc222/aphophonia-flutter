import '../../../core/utils/json_parse.dart';

class Ministry {
  const Ministry({
    required this.id,
    required this.nameAr,
    this.slug = '',
    this.nameEn,
    this.logoUrl,
  });

  factory Ministry.fromJson(Map<String, dynamic> json) {
    return Ministry(
      id: JsonParse.reqString(json, 'id'),
      nameAr: JsonParse.reqString(json, 'name_ar'),
      nameEn: JsonParse.str(json, 'name_en'),
      slug: JsonParse.reqString(json, 'slug'),
      logoUrl: JsonParse.str(json, 'logo_url'),
    );
  }

  final String id;
  final String nameAr;
  final String slug;
  final String? nameEn;
  final String? logoUrl;
}
