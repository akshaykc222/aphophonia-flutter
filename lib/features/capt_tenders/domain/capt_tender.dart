import '../../../core/utils/json_parse.dart';

class CaptTender {
  const CaptTender({
    required this.id,
    required this.titleAr,
    this.titleEn,
    this.ministryName,
    this.tenderType,
    this.publishedAt,
    this.deadlineAt,
    this.detailUrl,
    this.isLatest = false,
  });

  final String id;
  final String titleAr;
  final String? titleEn;
  final String? ministryName;
  final String? tenderType;
  final DateTime? publishedAt;
  final DateTime? deadlineAt;
  final String? detailUrl;
  final bool isLatest;

  factory CaptTender.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? s) =>
        s != null ? DateTime.tryParse(s) : null;

    return CaptTender(
      id: JsonParse.reqString(json, 'id'),
      titleAr: JsonParse.reqString(json, 'title_ar'),
      titleEn: JsonParse.str(json, 'title_en'),
      ministryName: JsonParse.str(json, 'ministry_name'),
      tenderType: JsonParse.str(json, 'tender_type'),
      publishedAt: parseDate(JsonParse.str(json, 'published_at')),
      deadlineAt: parseDate(JsonParse.str(json, 'deadline_at')),
      detailUrl: JsonParse.str(json, 'detail_url'),
      isLatest: json['is_latest'] as bool? ?? false,
    );
  }

  String get subtitle =>
      ministryName?.trim().isNotEmpty == true
          ? ministryName!.trim()
          : (tenderType?.trim().isNotEmpty == true ? tenderType!.trim() : '');
}
