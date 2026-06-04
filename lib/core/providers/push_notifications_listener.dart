import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/auth_providers.dart';
import 'providers.dart';

/// Registers FCM when the user signs in; clears on sign-out.
class PushNotificationsListener extends ConsumerStatefulWidget {
  const PushNotificationsListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<PushNotificationsListener> createState() =>
      _PushNotificationsListenerState();
}

class _PushNotificationsListenerState
    extends ConsumerState<PushNotificationsListener> {
  String? _registeredUserId;
  Timer? _iosRetryTimer;
  int _iosRetryCount = 0;

  static const _maxIosRetries = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFromSession());
  }

  @override
  void dispose() {
    _iosRetryTimer?.cancel();
    super.dispose();
  }

  Future<void> _syncFromSession() async {
    final session = ref.read(authSessionProvider).valueOrNull;
    await _handleSession(session?.user.id);
  }

  void _scheduleIosRetry(String userId) {
    if (!Platform.isIOS || _iosRetryCount >= _maxIosRetries) return;
    _iosRetryTimer?.cancel();
    _iosRetryCount++;
    _iosRetryTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      if (ref.read(authSessionProvider).valueOrNull?.user.id != userId) return;
      _handleSession(userId, isRetry: true);
    });
  }

  Future<void> _handleSession(String? userId, {bool isRetry = false}) async {
    try {
      final push = ref.read(pushNotificationServiceProvider);
      if (push == null) return;

      if (userId == null) {
        _iosRetryTimer?.cancel();
        _iosRetryCount = 0;
        if (_registeredUserId != null) {
          await push.unregister(userId: _registeredUserId);
          _registeredUserId = null;
        }
        return;
      }

      if (_registeredUserId == userId) return;

      final ok = await push.registerForUser(userId);
      if (ok) {
        _registeredUserId = userId;
        _iosRetryCount = 0;
        _iosRetryTimer?.cancel();
        return;
      }

      if (!isRetry) {
        debugPrint(
          'PushNotificationsListener: registration pending, will retry on iOS',
        );
      }
      _scheduleIosRetry(userId);
    } catch (e, st) {
      debugPrint('PushNotificationsListener: $e\n$st');
      if (userId != null) _scheduleIosRetry(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authSessionProvider, (prev, next) {
      if (next.isLoading) return;
      final userId = next.valueOrNull?.user.id;
      final prevUserId = prev?.valueOrNull?.user.id;
      if (userId == prevUserId) return;
      _handleSession(userId);
    });

    return widget.child;
  }
}
