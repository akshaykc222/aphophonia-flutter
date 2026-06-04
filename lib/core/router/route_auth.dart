/// Routes that require a signed-in user (account-based features).
bool routeRequiresAuth(String path) {
  if (path.startsWith('/auth')) return false;
  if (path == '/splash' || path == '/onboarding') return false;
  if (path.startsWith('/favorites')) return true;
  if (path.startsWith('/subscription')) return true;
  if (path.startsWith('/notifications')) return true;
  return false;
}
