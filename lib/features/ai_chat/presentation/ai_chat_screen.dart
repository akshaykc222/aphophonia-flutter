import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/ar_kw_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/chat_message.dart';
import 'ai_chat_providers.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text;
    _controller.clear();
    await ref.read(aiChatProvider.notifier).send(text);
    _scrollToBottom();
  }

  String? _errorMessage(String? code) {
    switch (code) {
      case 'chat_not_configured':
        return ArKwStrings.chatNotConfigured;
      case 'not_signed_in':
        return ArKwStrings.chatNotSignedIn;
      case 'session_loading':
        return ArKwStrings.chatSessionLoading;
      case 'unauthorized':
        return ArKwStrings.chatUnauthorized;
      case 'unavailable':
        return ArKwStrings.chatUnavailable;
      case 'subscription_required':
        return ArKwStrings.subscriptionRequired;
      default:
        return code == null ? null : ArKwStrings.chatFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(aiChatProvider);
    final canSend = ref.watch(aiChatCanSendProvider);
    final sessionLoading = ref.watch(authSessionProvider).isLoading;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    ref.listen(aiChatProvider, (prev, next) {
      if (next.messages.length != (prev?.messages.length ?? 0) ||
          next.sending != (prev?.sending ?? false)) {
        _scrollToBottom();
      }
    });

    return AppScaffold(
      title: ArKwStrings.chatTitle,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: chat.messages.length + (chat.sending ? 1 : 0),
                itemBuilder: (_, i) {
                  if (chat.sending && i == chat.messages.length) {
                    return const _ChatLoadingBubble();
                  }
                  return _ChatBubble(message: chat.messages[i]);
                },
              ),
            ),
            if (chat.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      _errorMessage(chat.error)!,
                      style: AppTypography.body16.copyWith(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (chat.error == 'subscription_required') ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.push('/subscription'),
                        child: Text(ArKwStrings.subscription),
                      ),
                    ],
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !chat.sending && (canSend || sessionLoading),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      style: const TextStyle(color: AppColors.foreground),
                      decoration: InputDecoration(
                        hintText: ArKwStrings.chatHint,
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderSubtle),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: chat.sending || !canSend ? null : _send,
                    icon: const Icon(Icons.send_rounded, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.foreground,
                      foregroundColor: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatLoadingBubble extends StatelessWidget {
  const _ChatLoadingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: SpinKitRotatingCircle(
          color: AppColors.muted,
          size: 22,
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.surfaceHigh : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 4 : 14),
            bottomRight: Radius.circular(isUser ? 14 : 4),
          ),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Text(
          message.content,
          style: AppTypography.body16.copyWith(
            fontSize: 15,
            color: AppColors.foreground,
          ),
        ),
      ),
    );
  }
}
