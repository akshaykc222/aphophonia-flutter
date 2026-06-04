import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads Supabase credentials from the bundled `.env` asset when the app
/// is not started with `--dart-define-from-file=.env`.
Future<void> loadEnv() async {
  if (_hasDotenvValues) return;

  try {
    await dotenv.load(fileName: '.env');
    if (_hasDotenvValues) return;
  } catch (e) {
    debugPrint('Env: could not load .env asset — $e');
  }
}

bool get _hasDotenvValues {
  try {
    final url = dotenv.env['SUPABASE_URL'];
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    return url != null &&
        url.isNotEmpty &&
        key != null &&
        key.isNotEmpty;
  } catch (_) {
    return false;
  }
}
