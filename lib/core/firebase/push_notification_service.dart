import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../firebase_options.dart';
import '../config/env.dart';

/// FCM topic subscribed by every signed-in app user (broadcast from admin).
const fcmTopicAllUsers = 'kuwait_today_all';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await PushNotificationService.ensureFirebaseInitialized();
}

class PushNotificationService {
  PushNotificationService(this._client);

  final SupabaseClient _client;

  StreamSubscription<String>? _tokenRefreshSub;
  String? _activeUserId;

  /// True when env vars or [DefaultFirebaseOptions] / native config can be used.
  static bool get isAvailable =>
      Env.isFirebaseConfigured || !kIsWeb;

  /// Initializes Firebase if needed. Returns false when push cannot run.
  static Future<bool> ensureFirebaseInitialized() async {
    if (Firebase.apps.isNotEmpty) return true;

    try {
      final options = Env.isFirebaseConfigured
          ? _firebaseOptionsFromEnv()
          : DefaultFirebaseOptions.currentPlatform;

      await Firebase.initializeApp(options: options);
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );
      return true;
    } catch (e, st) {
      debugPrint('Firebase init failed — skip FCM: $e\n$st');
      return false;
    }
  }

  Future<FirebaseMessaging?> _messaging() async {
    if (!isAvailable) return null;
    final ok = await ensureFirebaseInitialized();
    if (!ok) return null;
    return FirebaseMessaging.instance;
  }

  Future<bool> registerForUser(String userId) async {
    if (!isAvailable) {
      debugPrint('Firebase not configured — skip FCM registration');
      return false;
    }

    if (_activeUserId == userId && _tokenRefreshSub != null) return true;

    final messaging = await _messaging();
    if (messaging == null) return false;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('FCM permission denied');
      return false;
    }

    final token = await _resolveFcmToken(messaging);
    if (token == null || token.isEmpty) {
      debugPrint('FCM token unavailable (APNS may not be ready yet on iOS)');
      return false;
    }

    _activeUserId = userId;
    await _saveToken(userId, token);
    await messaging.subscribeToTopic(fcmTopicAllUsers);

    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = messaging.onTokenRefresh.listen((newToken) async {
      final uid = _activeUserId;
      if (uid == null) return;
      await _saveToken(uid, newToken);
    });
    return true;
  }

  /// Call while the user is still signed in so RLS can delete their row.
  Future<void> unregister({String? userId}) async {
    final uid = userId ?? _activeUserId;
    _activeUserId = null;
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;

    if (!isAvailable) return;

    final messaging = await _messaging();
    if (messaging == null) return;

    try {
      await messaging.unsubscribeFromTopic(fcmTopicAllUsers);
      String? token;
      try {
        token = await _resolveFcmToken(messaging);
      } catch (_) {
        token = null;
      }
      if (token != null && uid != null) {
        await _client
            .from('device_tokens')
            .delete()
            .eq('user_id', uid)
            .eq('fcm_token', token);
      }
      await messaging.deleteToken();
    } catch (e) {
      debugPrint('FCM unregister: $e');
    }
  }

  Future<void> _saveToken(String userId, String token) async {
    final platform = Platform.isIOS
        ? 'ios'
        : Platform.isAndroid
            ? 'android'
            : 'web';

    await _client.from('device_tokens').upsert(
      {
        'user_id': userId,
        'fcm_token': token,
        'platform': platform,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,fcm_token',
    );
  }

  /// On iOS, FCM requires APNS token first. Retries briefly instead of throwing.
  Future<String?> _resolveFcmToken(FirebaseMessaging messaging) async {
    if (Platform.isIOS) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      for (var attempt = 0; attempt < 12; attempt++) {
        final apns = await messaging.getAPNSToken();
        if (apns != null && apns.isNotEmpty) break;
        await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1)));
      }
    }

    try {
      return await messaging.getToken();
    } catch (e) {
      debugPrint('FCM getToken failed: $e');
      return null;
    }
  }
}

FirebaseOptions _firebaseOptionsFromEnv() {
  return FirebaseOptions(
    apiKey: Env.firebaseApiKey,
    appId: Env.firebaseAppId,
    messagingSenderId: Env.firebaseMessagingSenderId,
    projectId: Env.firebaseProjectId,
    iosBundleId: Env.firebaseIosBundleId.isNotEmpty
        ? Env.firebaseIosBundleId
        : 'com.alfaresi.apophenia',
  );
}
