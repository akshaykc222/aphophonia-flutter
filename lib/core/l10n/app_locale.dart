enum AppLocale {
  ar,
  en;

  String get code => name;

  static AppLocale fromCode(String? code) {
    if (code == 'en') return AppLocale.en;
    return AppLocale.ar;
  }
}
