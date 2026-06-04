import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_providers.dart';
import '../router/route_auth.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/content/presentation/content_detail_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/ai_chat/presentation/ai_chat_screen.dart';
import '../../features/help/presentation/help_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/subscription/presentation/subscription_screen.dart';
import '../../features/tenders/presentation/tenders_screen.dart';
import '../../features/capt_tenders/presentation/capt_tender_detail_screen.dart';
import '../../features/capt_tenders/domain/capt_tender.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authRouterNotifierProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final session = authNotifier?.session;
      final path = state.matchedLocation;
      final isAuth = path.startsWith('/auth');

      if (session == null && routeRequiresAuth(path)) {
        final redirect = Uri.encodeComponent(path);
        return '/auth/sign-in?redirect=$redirect';
      }
      if (session != null && isAuth) {
        final redirect = state.uri.queryParameters['redirect'];
        if (redirect != null && redirect.isNotEmpty) {
          return redirect;
        }
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (c, s) => _page(s, const SplashScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (c, s) => _page(s, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/auth/sign-in',
        pageBuilder: (c, s) => _page(s, const SignInScreen()),
      ),
      GoRoute(
        path: '/auth/sign-up',
        pageBuilder: (c, s) => _page(s, const SignUpScreen()),
      ),
      GoRoute(
        path: '/auth/otp',
        pageBuilder: (c, s) => _page(
          s,
          OtpScreen(email: s.extra as String? ?? ''),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (c, s, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', pageBuilder: (c, s) => _page(s, const HomeScreen())),
          GoRoute(
            path: '/assistant',
            pageBuilder: (c, s) => _page(s, const AiChatScreen()),
          ),
          GoRoute(
            path: '/tender',
            pageBuilder: (c, s) => _page(s, const TendersScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (c, s) => _page(s, const ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (c, s) => _page(s, const SearchScreen()),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (c, s) => _page(s, const NotificationsScreen()),
      ),
      GoRoute(
        path: '/favorites',
        pageBuilder: (c, s) => _page(s, const FavoritesScreen()),
      ),
      GoRoute(
        path: '/subscription',
        pageBuilder: (c, s) => _page(s, const SubscriptionScreen()),
      ),
      GoRoute(
        path: '/help',
        pageBuilder: (c, s) => _page(s, const HelpScreen()),
      ),
      GoRoute(
        path: '/content/:slug',
        pageBuilder: (c, s) => _page(
          s,
          ContentDetailScreen(slug: s.pathParameters['slug']!),
        ),
      ),
      GoRoute(
        path: '/tender/:id',
        pageBuilder: (c, s) {
          final tender = s.extra as CaptTender;
          return _page(s, CaptTenderDetailScreen(tender: tender));
        },
      ),
    ],
  );
});

CustomTransitionPage<void> _page(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (c, a, s, child) {
      final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
