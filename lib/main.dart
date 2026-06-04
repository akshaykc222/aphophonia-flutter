import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/config/env_loader.dart';
import 'core/firebase/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await loadEnv();

  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

  if (Env.myfatoorahApiKey.isNotEmpty) {
    final env = Env.myfatoorahEnv.toUpperCase() == 'LIVE'
        ? MFEnvironment.LIVE
        : MFEnvironment.TEST;
    MFSDK.init(Env.myfatoorahApiKey, MFCountry.KUWAIT, env);
  }

  if (PushNotificationService.isAvailable) {
    await PushNotificationService.ensureFirebaseInitialized();
  }

  if (!Env.isConfigured) {
    debugPrint(
      'Supabase not configured. Add .env or run with '
      '--dart-define-from-file=.env',
    );
  }

  runApp(const ProviderScope(child: ApopheniaApp()));
}
