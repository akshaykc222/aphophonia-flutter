/// Public routes (no session required).
bool routeIsPublic(String path) {
  if (path == '/splash') return true;
  if (path.startsWith('/auth')) return true;
  return false;
}

/// Onboarding only after auth + subscription (splash routes here).
bool routeIsOnboarding(String path) => path == '/onboarding';
