import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/providers/providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../subscription/presentation/billing_providers.dart';
import '../data/ai_chat_repository.dart';
import '../domain/chat_message.dart';

String? _chatAccessToken(Ref ref) {
  final fromStream = ref.watch(authSessionProvider).valueOrNull?.accessToken;
  if (fromStream != null && fromStream.isNotEmpty) return fromStream;
  return ref.watch(supabaseClientProvider)?.auth.currentSession?.accessToken;
}

final aiChatRepositoryProvider = Provider<AiChatRepository?>((ref) {
  if (!Env.isChatConfigured) return null;
  final token = _chatAccessToken(ref);
  if (token == null || token.isEmpty) return null;
  return AiChatRepository(baseUrl: Env.adminApiUrl, accessToken: token);
});

final aiChatCanSendProvider = Provider<bool>((ref) {
  if (!Env.isChatConfigured) return false;
  final sessionAsync = ref.watch(authSessionProvider);
  if (sessionAsync.isLoading) return false;
  return _chatAccessToken(ref) != null;
});

class AiChatState {
  const AiChatState({
    this.messages = const [],
    this.sending = false,
    this.error,
  });

  final List<ChatMessage> messages;
  final bool sending;
  final String? error;

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? sending,
    String? error,
    bool clearError = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final aiChatProvider =
    NotifierProvider<AiChatNotifier, AiChatState>(AiChatNotifier.new);

class AiChatNotifier extends Notifier<AiChatState> {
  @override
  AiChatState build() {
    return AiChatState(
      messages: [
        ChatMessage(role: 'assistant', content: _welcomeMessage()),
      ],
    );
  }

  String _welcomeMessage() => ArKwStrings.chatWelcome;

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return;

    if (!Env.isChatConfigured) {
      state = state.copyWith(error: 'chat_not_configured');
      return;
    }

    final sessionAsync = ref.read(authSessionProvider);
    if (sessionAsync.isLoading) {
      state = state.copyWith(error: 'session_loading');
      return;
    }

    final repo = ref.read(aiChatRepositoryProvider);
    if (repo == null) {
      state = state.copyWith(
        error: Env.isChatConfigured ? 'not_signed_in' : 'chat_not_configured',
      );
      return;
    }

    final updated = [
      ...state.messages,
      ChatMessage(role: 'user', content: trimmed),
    ];
    state = state.copyWith(messages: updated, sending: true, clearError: true);

    try {
      final reply = await repo.send(updated);
      state = state.copyWith(
        messages: [
          ...updated,
          ChatMessage(role: 'assistant', content: reply),
        ],
        sending: false,
      );
    } on AiChatException catch (e) {
      if (e.code == 'subscription_required') {
        ref.invalidate(billingStatusProvider);
      }
      state = state.copyWith(sending: false, error: e.code);
    } catch (_) {
      state = state.copyWith(sending: false, error: 'unknown');
    }
  }

  void reset() {
    state = AiChatState(
      messages: [
        ChatMessage(role: 'assistant', content: _welcomeMessage()),
      ],
    );
  }
}
