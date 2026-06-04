import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class Env {
  static bool get _dotenvReady {
    try {
      dotenv.env;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// `--dart-define-from-file=.env` wins over bundled dotenv (avoids stale keys).
  static String get supabaseUrl {
    const fromDefine = String.fromEnvironment('SUPABASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    if (_dotenvReady) {
      final v = dotenv.env['SUPABASE_URL'];
      if (v != null && v.isNotEmpty) return v;
    }
    return '';
  }

  static String get supabaseAnonKey {
    const fromDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    if (_dotenvReady) {
      final v = dotenv.env['SUPABASE_ANON_KEY'];
      if (v != null && v.isNotEmpty) return v;
    }
    return '';
  }

  static String get adminApiUrl {
    const fromDefine = String.fromEnvironment('ADMIN_API_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    if (_dotenvReady) {
      final v = dotenv.env['ADMIN_API_URL'];
      if (v != null && v.isNotEmpty) return v;
    }
    return '';
  }

  static String get myfatoorahApiKey {
    const fromDefine = String.fromEnvironment('MYFATOORAH_API_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    if (_dotenvReady) {
      final v = dotenv.env['MYFATOORAH_API_KEY'];
      if (v != null && v.isNotEmpty) return v;
    }
    return 'SK_KWT_vVZlnnAqu8jRByOWaRPNId4ShzEDNt256dvnjebuyzo52dXjAfRx2ixW5umjWSUx';
  }

  static String get myfatoorahEnv {
    const fromDefine = String.fromEnvironment('MYFATOORAH_ENV');
    if (fromDefine.isNotEmpty) return fromDefine;
    if (_dotenvReady) {
      final v = dotenv.env['MYFATOORAH_ENV'];
      if (v != null && v.isNotEmpty) return v;
    }
    return 'TEST';
  }

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get isChatConfigured => adminApiUrl.isNotEmpty;

  static bool get isBillingConfigured => adminApiUrl.isNotEmpty;

  static String get privacyPolicyUrl {
    if (adminApiUrl.isEmpty) return '';
    final base = adminApiUrl.endsWith('/')
        ? adminApiUrl.substring(0, adminApiUrl.length - 1)
        : adminApiUrl;
    return '$base/privacy';
  }

  static String get termsUrl {
    if (adminApiUrl.isEmpty) return '';
    final base = adminApiUrl.endsWith('/')
        ? adminApiUrl.substring(0, adminApiUrl.length - 1)
        : adminApiUrl;
    return '$base/terms';
  }

  static String _firebaseEnv(String key) {
    final envKey = 'FIREBASE_${key.toUpperCase()}';
    final fromDefine = String.fromEnvironment(envKey);
    if (fromDefine.isNotEmpty) return fromDefine;
    if (_dotenvReady) {
      final v = dotenv.env[envKey];
      if (v != null && v.isNotEmpty) return v;
    }
    return '';
  }

  static String get firebaseApiKey => _firebaseEnv('API_KEY');

  static String get firebaseAppId => _firebaseEnv('APP_ID');

  static String get firebaseMessagingSenderId =>
      _firebaseEnv('MESSAGING_SENDER_ID');

  static String get firebaseProjectId => _firebaseEnv('PROJECT_ID');

  static String get firebaseIosBundleId => _firebaseEnv('IOS_BUNDLE_ID');

  static bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseMessagingSenderId.isNotEmpty &&
      firebaseProjectId.isNotEmpty;
}
