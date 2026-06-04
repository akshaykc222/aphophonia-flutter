# Apophenia Figma inventory

**File:** [Apophenia (Copy)](https://www.figma.com/design/uQaHH9vqWuCsaRNIz9wI6l/Apophenia--Copy-) (`uQaHH9vqWuCsaRNIz9wI6l`)

## Design tokens (from Figma)

| Token | Value |
|-------|-------|
| background | `#171717` |
| surface / cards | `#262626` |
| foreground | `#FFFFFF` |
| muted text | `rgba(255,255,255,0.5)` |
| body muted | `#8C8C8C` |
| primary button | white on `#0F0F10` text |
| link / accent | `#2F54EB` |
| typography | Plus Jakarta Sans + Noto Sans Arabic |
| radius (inputs, cards) | 12–16px |
| auth sheet radius | 30px top |

## Screens → Flutter routes

| Figma frame | Node ID | Route |
|-------------|---------|-------|
| Splash (logo) | `23:905` | `/splash` |
| Sign in | `49:2941` | `/auth/sign-in` |
| Create your account | `49:3238` | `/auth/sign-up` |
| OTP (5-digit) | `65:3314` | `/auth/otp` |
| Home | `1:440` | `/` |
| Tender (tab) | `2:251` | `/tender` |
| Profile | `41:2878` | `/profile` |
| Detail | `41:2178` | `/content/:slug` |
| Search | `41:2345` | `/search` |
| Notification | `41:2565` | `/notifications` |
| Favorites | `45:1873` | `/favorites` |
| Subscription | (see file) | `/subscription` |

## Bottom navigation (Figma)

3 tabs only: **Home**, **Tender**, **Profile** (not 5-tab layout).

## Auth flow

1. Splash → logo on `#171717`
2. Sign in (email + password) or Sign up (email + phone + terms)
3. OTP after phone signup (5 boxes)
4. Main app when Supabase session exists
