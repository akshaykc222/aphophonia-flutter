import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/auth_repository.dart';

/// Notifies [GoRouter] when Supabase auth changes so redirects re-run.
class AuthRouterNotifier extends ChangeNotifier {
  AuthRouterNotifier(this._repo) {
    _session = _repo.currentSession;
    _subscription = _repo.authStateChanges.listen((event) {
      _session = event.session;
      notifyListeners();
    });
  }

  final AuthRepository _repo;
  late final StreamSubscription<AuthState> _subscription;
  Session? _session;

  Session? get session => _session;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
