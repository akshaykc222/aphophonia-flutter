/// Form validators with Kuwait Arabic error messages.
abstract final class FormValidators {
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < minLength) {
      return 'كلمة المرور يجب أن تكون $minLength أحرف على الأقل';
    }
    return null;
  }

  static String? passwordSignUp(String? value) {
    final base = password(value, minLength: 8);
    if (base != null) return base;
    if (!RegExp(r'[A-Za-z]').hasMatch(value!) ||
        !RegExp(r'[0-9]').hasMatch(value)) {
      return 'استخدم أحرفاً وأرقاماً في كلمة المرور';
    }
    return null;
  }

  static String? required(String? value, {required String fieldLabel}) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldLabel';
    }
    return null;
  }

  static String? otpCode(String code) {
    if (code.length != 6) {
      return 'أدخل الرمز المكوّن من 6 أرقام';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return 'الرمز يجب أن يكون أرقاماً فقط';
    }
    return null;
  }

  static String? termsAccepted(bool agreed) {
    if (!agreed) {
      return 'يرجى الموافقة على الشروط والأحكام';
    }
    return null;
  }
}
