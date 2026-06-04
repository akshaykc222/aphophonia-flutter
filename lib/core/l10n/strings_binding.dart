import 'app_locale.dart';
import 'app_strings.dart';

/// Global strings used by [ArKwStrings] static accessors.
abstract final class StringsBinding {
  static AppStrings current = AppStrings(AppLocale.ar);

  static void setLocale(AppLocale locale) {
    current = AppStrings(locale);
  }
}
