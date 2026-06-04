import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/l10n/ar_kw_strings.dart';
import '../domain/chat_message.dart';

/// Detects "who developed you" style questions (mirrors server shortcuts).
bool isDeveloperQuestion(String text) {
  final t = text.trim().toLowerCase();
  if (t.isEmpty) return false;
  const patterns = [
    'من طور',
    'من صمم',
    'من سوى',
    'من عمل',
    'من أنشأ',
    'طوروك',
    'صمموك',
    'who made you',
    'who built you',
    'who created you',
    'who developed you',
    'developer',
    'alfaresi',
  ];
  return patterns.any(t.contains);
}

/// Where data/news comes from — fixed refusal (no OpenAI).
bool isInformationSourceQuestion(String text) {
  final t = text.trim();
  if (t.isEmpty || isDeveloperQuestion(t)) return false;

  const sourceHints = [
    'مصدر',
    'داتا',
    'data',
    'معلومات',
    'أخبار',
    'بيانات',
    'محتوى',
    'news',
    'information',
    'magazine',
    'مجلة',
    'جريدة',
    'gazette',
    'source',
  ];
  final lower = t.toLowerCase();
  final hasSourceHint = sourceHints.any(lower.contains);

  const wherePhrases = [
    'من وين',
    'منين',
    'وين تيب',
    'وين تجيب',
    'وين تاخذ',
    'where do you get',
    'where you get',
    'from where',
    'what is your source',
    'information source',
    'data source',
    'شنو مصدر',
    'مصدرك',
    'مصدر المعلومات',
    'مصدر الأخبار',
    'مصدر البيانات',
    'مصدر المحتوى',
  ];
  if (wherePhrases.any(lower.contains) && hasSourceHint) return true;

  if (RegExp(r'من\s+وين\s+ت[ي]?[بج]', caseSensitive: false).hasMatch(t)) {
    return true;
  }
  if (RegExp(r'من\s+وين.*مالت', caseSensitive: false).hasMatch(t)) {
    return true;
  }
  if (RegExp(r'من\s+وين.*(داتا|data)', caseSensitive: false).hasMatch(t)) {
    return true;
  }
  if (RegExp(r'(داتا|data).*مالت', caseSensitive: false).hasMatch(t) &&
      (lower.contains('من وين') || lower.contains('وين'))) {
    return true;
  }
  if (RegExp(r'من\s*وين', caseSensitive: false).hasMatch(t) &&
      RegExp(r'تيب|تجيب|تاخذ|داتا|data|مالت', caseSensitive: false)
          .hasMatch(t)) {
    return true;
  }
  if (RegExp(r'وين\s+ت[ي]?[بج]', caseSensitive: false).hasMatch(t)) {
    return true;
  }

  return false;
}

/// AI explained gazette / data origin — replace before showing in UI.
bool looksLikeInformationSourceAnswer(String text) {
  final t = text.trim();
  if (t.isEmpty) return false;
  const patterns = [
    r'الجريدة\s+الرسمية',
    r'الجريدة\s+الكويتية',
    r'من\s+الجريدة',
    r'في\s+الجريدة',
    r'مصدر\s+(المعلومات|الأخبار|البيانات|المحتوى)',
    r'(تجيب|تيب|تأتي|تجي)\s*(ها|هم)?\s*من',
    r'official\s+gazette',
    r'kuwaiti\s+official',
    r'المعلومات\s+من',
    r'الداتا\s+من',
    r'قاعدة\s+البيانات',
    r'منشور\s+في\s+الجريدة',
  ];
  return patterns.any((p) => RegExp(p, caseSensitive: false).hasMatch(t));
}

String enforceInformationSourceReply(
  List<String> userMessages,
  String aiContent,
) {
  if (userMessages.any(isInformationSourceQuestion)) {
    return ArKwStrings.chatInformationSourceReply;
  }
  final lastUser = userMessages.isNotEmpty ? userMessages.last.trim() : '';
  if (looksLikeInformationSourceAnswer(aiContent) &&
      lastUser.isNotEmpty &&
      RegExp(
        r'من\s*وين|وين\s+ت|مصدر|داتا|data|source',
        caseSensitive: false,
      ).hasMatch(lastUser)) {
    return ArKwStrings.chatInformationSourceReply;
  }
  return aiContent;
}

/// Obvious off-topic — mirrors server `isOutOfScopeQuestion` (no OpenAI).
bool isObviousOffTopicQuestion(String text) {
  final t = text.trim();
  if (t.isEmpty || isDeveloperQuestion(t)) return false;

  const inScope = [
    'السور',
    'كويت اليوم',
    'الجريدة',
    'مناقص',
    'ممارسة',
    'ممارسات',
    'ممارسه',
    'معروض',
    'اسجل',
    'تقديم',
    'عطاء',
    'مرسوم',
    'مراسيم',
    'استدراك',
    'استدراكات',
    'وزار',
    'التطبيق',
    'بحث',
    'مفضل',
    'الوزارات',
    'الأحكام',
    'al-soor',
    'al soor',
    'kuwait today',
    'gazette',
    'tender',
    'best',
    'register',
    'technical company',
    'شركة تقنية',
    'أفضل',
    'تسجيل',
    'يناسب',
    'أنسب',
    'اقترح',
    'ministry',
  ];
  final lower = t.toLowerCase();
  if (inScope.any(lower.contains)) return false;

  const offTopic = [
    'طقس',
    'حرارة',
    'weather',
    'رياضة',
    'مباراة',
    'كورة',
    'football',
    'برمجة',
    'كود',
    'python',
    'javascript',
    'flutter',
    'طبخ',
    'bitcoin',
    'crypto',
    'بورصة',
  ];
  return offTopic.any(lower.contains);
}

class AiChatRepository {
  AiChatRepository({
    required this.baseUrl,
    required this.accessToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final String accessToken;
  final http.Client _client;

  static const developerReply = 'alfaresi solutions';
  static String get informationSourceReply =>
      ArKwStrings.chatInformationSourceReply;
  static String get outOfScopeReply => ArKwStrings.chatOutOfScopeReply;

  Uri get _chatUri {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$root/api/mobile-chat');
  }

  Future<String> send(List<ChatMessage> messages) async {
    ChatMessage? lastUser;
    for (final m in messages.reversed) {
      if (m.isUser) {
        lastUser = m;
        break;
      }
    }
    final userTexts = messages.where((m) => m.isUser).map((m) => m.content).toList();

    if (userTexts.any(isInformationSourceQuestion)) {
      return informationSourceReply;
    }
    if (lastUser != null) {
      if (isDeveloperQuestion(lastUser.content)) return developerReply;
      if (isObviousOffTopicQuestion(lastUser.content)) return outOfScopeReply;
    }

    final res = await _client.post(
      _chatUri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'messages': messages.map((m) => m.toJson()).toList(),
      }),
    );

    if (res.statusCode == 401) {
      throw AiChatException('unauthorized');
    }
    if (res.statusCode == 402) {
      throw AiChatException('subscription_required');
    }
    if (res.statusCode == 503) {
      throw AiChatException('unavailable');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw AiChatException('http_${res.statusCode}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final content = map['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw AiChatException('empty_response');
    }
    return enforceInformationSourceReply(userTexts, content.trim());
  }
}

class AiChatException implements Exception {
  AiChatException(this.code);
  final String code;

  @override
  String toString() => 'AiChatException($code)';
}
