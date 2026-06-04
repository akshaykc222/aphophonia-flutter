import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/billing_status.dart';
import '../domain/subscription_plan.dart';

void _billingLog(String message) {
  if (kDebugMode) {
    debugPrint('[Billing] $message');
  }
}

String _truncateBody(String body, {int max = 500}) {
  if (body.length <= max) return body;
  return '${body.substring(0, max)}…';
}

class BillingRepository {
  BillingRepository({
    required SupabaseClient supabase,
    required this.adminApiUrl,
  }) : _supabase = supabase;

  final SupabaseClient _supabase;
  final String adminApiUrl;

  Uri _apiUri(String path) {
    final base = adminApiUrl.endsWith('/')
        ? adminApiUrl.substring(0, adminApiUrl.length - 1)
        : adminApiUrl;
    return Uri.parse('$base$path');
  }

  Future<Map<String, String>> _authHeaders() async {
    final session = _supabase.auth.currentSession;
    final token = session?.accessToken;
    if (token == null || token.isEmpty) {
      _billingLog('auth: no session token');
      throw BillingException('unauthorized');
    }
    _billingLog('auth: token present (${token.length} chars)');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Public endpoint — no Bearer required.
  Future<List<SubscriptionPlan>> fetchPlans() async {
    final uri = _apiUri('/api/billing/plans');
    _billingLog('GET $uri');
    final res = await http.get(
      uri,
      headers: const {'Content-Type': 'application/json'},
    );
    _billingLog('GET /plans → ${res.statusCode} ${_truncateBody(res.body)}');
    if (res.statusCode >= 400) {
      if (res.statusCode == 503) {
        throw BillingException('billing_not_migrated');
      }
      throw BillingException('plans_${res.statusCode}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final list = map['plans'] as List<dynamic>? ?? [];
    _billingLog('plans loaded: ${list.length}');
    return list
        .map((e) => SubscriptionPlan.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<BillingStatus> fetchMyStatus() async {
    final uri = _apiUri('/api/billing/me');
    _billingLog('GET $uri');
    final res = await http.get(
      uri,
      headers: await _authHeaders(),
    );
    _billingLog('GET /me → ${res.statusCode} ${_truncateBody(res.body)}');
    if (res.statusCode == 401) throw BillingException('unauthorized');
    if (res.statusCode >= 400) {
      throw BillingException('me_${res.statusCode}');
    }
    final status = BillingStatus.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
    _billingLog(
      'status: active=${status.active} lifetime=${status.isLifetime} '
      'daysRemaining=${status.daysRemaining}',
    );
    return status;
  }

  Future<CheckoutSession> startCheckout(String planId, {bool nativeSdk = false}) async {
    final uri = _apiUri('/api/billing/checkout');
    final user = _supabase.auth.currentUser;
    final payload = <String, dynamic>{
      'plan_id': planId,
      'native_sdk': nativeSdk,
    };
    payload.addAll(_customerFieldsFromUser(user));
    final body = jsonEncode(payload);
    _billingLog('POST $uri plan_id=$planId native_sdk=$nativeSdk customer_name=${payload['customer_name']}');
    final res = await http.post(
      uri,
      headers: await _authHeaders(),
      body: body,
    );
    _billingLog('POST /checkout → ${res.statusCode} ${_truncateBody(res.body)}');
    if (res.statusCode == 401) throw BillingException('unauthorized');
    if (res.statusCode == 503) {
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final err = map['error']?.toString() ?? '';
      _billingLog('checkout 503: $err');
      if (err.toLowerCase().contains('payment gateway')) {
        throw BillingException('gateway_unavailable');
      }
      throw BillingException('checkout_503');
    }
    if (res.statusCode >= 400) {
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final err = map['error']?.toString() ?? 'checkout_${res.statusCode}';
      _billingLog('checkout failed: $err');
      if (_isGatewayCredentialError(err)) {
        throw BillingException('gateway_unavailable');
      }
      throw BillingException(err);
    }
    final session = CheckoutSession.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
    _billingLog(
      'checkout ok: transactionId=${session.transactionId} '
      'paymentUrl=${session.paymentUrl?.length ?? 0} chars',
    );
    return session;
  }

  Future<bool> registerNativePayment({
    required String transactionId,
    required String invoiceId,
    required String status,
  }) async {
    final uri = _apiUri(
      '/api/billing/callback?transactionId=$transactionId&invoiceId=$invoiceId&status=$status',
    );
    _billingLog('GET $uri');
    try {
      final res = await http.get(
        uri,
        headers: await _authHeaders(),
      );
      _billingLog('GET /callback → ${res.statusCode} ${_truncateBody(res.body)}');
      return res.statusCode == 200 || res.statusCode == 302;
    } catch (e) {
      _billingLog('registerNativePayment error: $e');
      return false;
    }
  }

  Future<BillingStatus> pollUntilActive({
    int maxAttempts = 20,
    Duration interval = const Duration(seconds: 2),
  }) async {
    _billingLog('pollUntilActive: maxAttempts=$maxAttempts interval=${interval.inSeconds}s');
    for (var i = 0; i < maxAttempts; i++) {
      _billingLog('poll attempt ${i + 1}/$maxAttempts');
      final status = await fetchMyStatus();
      if (status.active) {
        _billingLog('poll: subscription active');
        return status;
      }
      await Future<void>.delayed(interval);
    }
    _billingLog('poll: timed out, fetching final status');
    return fetchMyStatus();
  }
}

bool _isGatewayCredentialError(String message) {
  final lower = message.toLowerCase();
  return lower.contains('payment gateway not configured') ||
      lower.contains('token is not valid') ||
      lower.contains('myfatoorah') && lower.contains('expired');
}

Map<String, String> _customerFieldsFromUser(User? user) {
  if (user == null) return {};

  final meta = user.userMetadata;
  String? name;
  for (final key in ['display_name', 'full_name', 'name']) {
    final value = meta?[key];
    if (value is String && value.trim().isNotEmpty) {
      name = value.trim();
      break;
    }
  }

  final fields = <String, String>{};
  if (name != null) fields['customer_name'] = name;

  final email = user.email?.trim();
  if (email != null && email.isNotEmpty) {
    fields['customer_email'] = email;
  }

  final phone = user.phone?.trim();
  if (phone != null && phone.isNotEmpty) {
    fields['customer_mobile'] = phone;
  } else {
    for (final key in ['phone', 'mobile', 'phone_number']) {
      final value = meta?[key];
      if (value is String && value.trim().isNotEmpty) {
        fields['customer_mobile'] = value.trim();
        break;
      }
    }
  }

  return fields;
}

class BillingException implements Exception {
  BillingException(this.code);
  final String code;

  @override
  String toString() => 'BillingException($code)';
}
