/// Safe JSON helpers for Supabase rows (nullable DB columns).
abstract final class JsonParse {
  static String reqString(Map<String, dynamic> json, String key,
      {String fallback = ''}) {
    final v = json[key];
    if (v == null) return fallback;
    return v.toString();
  }

  static String? str(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  static Map<String, dynamic>? map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
