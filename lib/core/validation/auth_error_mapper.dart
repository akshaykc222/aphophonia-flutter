import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps Supabase auth errors to Kuwait Arabic messages.
String mapAuthError(Object error) {
  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid api key')) {
      return 'مفتاح الاتصال غير صالح. تحقق من إعدادات التطبيق.';
    }
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (msg.contains('email not confirmed')) {
      return 'يرجى تأكيد بريدك الإلكتروني أولاً';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'هذا البريد مسجّل مسبقاً. جرّب تسجيل الدخول';
    }
    if (msg.contains('password') && msg.contains('weak')) {
      return 'كلمة المرور ضعيفة. استخدم 8 أحرف على الأقل';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'محاولات كثيرة. انتظر قليلاً ثم حاول مجدداً';
    }
    if (msg.contains('otp') || msg.contains('token')) {
      if (msg.contains('expired')) {
        return 'انتهت صلاحية الرمز. اطلب رمزاً جديداً';
      }
      return 'رمز التحقق غير صحيح';
    }
    if (msg.contains('network') || msg.contains('socket')) {
      return 'تحقق من اتصال الإنترنت وحاول مجدداً';
    }
    return error.message;
  }
  final text = error.toString();
  if (text.contains('SocketException') || text.contains('Failed host lookup')) {
    return 'تحقق من اتصال الإنترنت وإعدادات الخادم';
  }
  return 'حدث خطأ غير متوقع. حاول مجدداً';
}
