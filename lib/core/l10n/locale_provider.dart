import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_locale.dart';
import 'strings_binding.dart';

const _prefsKey = 'app_locale';

final localeProvider =
    StateNotifierProvider<LocaleNotifier, AppLocale>((ref) => LocaleNotifier());

class LocaleNotifier extends StateNotifier<AppLocale> {
  LocaleNotifier() : super(AppLocale.ar) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final locale = AppLocale.fromCode(prefs.getString(_prefsKey));
    state = locale;
    StringsBinding.setLocale(locale);
  }

  Future<void> setLocale(AppLocale locale) async {
    state = locale;
    StringsBinding.setLocale(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.code);
  }

  Future<void> toggle() async {
    await setLocale(state == AppLocale.ar ? AppLocale.en : AppLocale.ar);
  }
}
