# Flutter app integration (Apophenia / كويت اليوم)

Guide for the **read-only mobile app** that consumes published gazette content from the [apophenia](https://github.com/akshaykc222/apophenia) Supabase backend.

## Overview

| Component | Mobile app uses? | Notes |
|-----------|------------------|--------|
| **Supabase Postgres** | Yes | Primary API via `supabase_flutter` |
| **Supabase Storage** (`assets`) | Yes | Public logos |
| **Supabase Storage** (`gazettes`) | No | Admin-only PDFs |
| **Vercel admin** | Yes | `ADMIN_API_URL` — billing (MyFatoorah) + mobile chat |
| **Firebase Cloud Messaging** | Yes | Device tokens + topic `kuwait_today_all` |

The admin panel uploads PDFs, runs extraction, and writes **`content_items`** with `is_published = true`. The Flutter app reads published data **only with an active subscription** (RLS + paywall).

See also: [billing-myfatoorah.md](https://github.com/akshaykc222/apophenia/blob/main/docs/billing-myfatoorah.md) (admin repo)

## Credentials

Same Supabase project as the admin panel. In this repo:

```bash
cp .env.example .env
```

```env
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=your_publishable_or_anon_key
ADMIN_API_URL=https://apophenia-five.vercel.app
```

Or `--dart-define=SUPABASE_URL=...` / `SUPABASE_ANON_KEY=...` / `ADMIN_API_URL=...` (see `lib/core/config/env.dart`).

| Key | Ship in app? |
|-----|----------------|
| Anon / publishable key | Yes |
| Service role | **Never** |

`Env.isBillingConfigured` and `Env.isChatConfigured` both require `ADMIN_API_URL`.

## Row Level Security (RLS)

| Table | Authenticated read |
|-------|-------------------|
| `categories`, `ministries`, `tender_categories` | All rows |
| `content_items` | `is_published = true` **and** `has_active_subscription()` |
| `pdf_issues`, drafts, `admin_users`, `audit_log` | Denied |

Always add `.eq('is_published', true)` on content queries (defense in depth).

Run migrations **`001`–`013`** on the shared Supabase project (`012_billing`, `013_billing_lifetime`).

## Subscriptions (MyFatoorah)

Payment runs on Vercel — **not** in the Flutter app directly.

| Endpoint | Auth | Purpose |
|----------|------|---------|
| `GET /api/billing/plans` | Public | Plan list |
| `GET /api/billing/me` | Bearer JWT | Active subscription status |
| `POST /api/billing/checkout` | Bearer JWT | `{ "plan_id": "uuid" }` → `paymentUrl` |

### Flow

1. User signs in (Supabase Auth).
2. `MainShell` loads `billingStatusProvider` → `GET /api/billing/me`.
3. If not active → full-screen paywall (`SubscriptionScreen(required: true)`).
4. User picks plan → `POST /checkout` → `launchUrl(paymentUrl)` (MyFatoorah in browser).
5. Webhook activates `user_subscriptions` on Vercel.
6. App polls `/me` (and refreshes on app resume + manual **«تحقق من الدفع»**).
7. When `active: true` → main app unlocks.

### Implementation

| File | Role |
|------|------|
| `lib/features/subscription/data/billing_repository.dart` | Plans, status, checkout, poll |
| `lib/features/subscription/presentation/billing_providers.dart` | Riverpod; status tied to auth session |
| `lib/features/subscription/presentation/subscription_screen.dart` | Paywall + optional manage screen |
| `lib/features/shell/presentation/main_shell.dart` | Paywall gate before bottom nav |

Profile → **الاشتراك** opens `/subscription` (manage / renew).

### AI chat gating

`/api/mobile-chat` returns **402** `{ "code": "subscription_required" }` without subscription. Flutter maps this to `ArKwStrings.subscriptionRequired` and invalidates billing status.

## Push notifications (FCM)

On sign-in, the app registers FCM tokens in `device_tokens` and subscribes to **`kuwait_today_all`**.

See Firebase env vars in `.env.example`. Native: `google-services.json` (Android), `GoogleService-Info.plist` (iOS).

| File | Role |
|------|------|
| `lib/core/firebase/push_notification_service.dart` | Firebase init, register/unregister |
| `lib/core/providers/push_notifications_listener.dart` | Listens to `authSessionProvider` |

## Home category tabs

Loaded from `categories` ordered by `sort_order`:

| `slug` | Arabic |
|--------|--------|
| `ministries` | الوزارات (default tab) |
| `addendums` | الاستدراكات |
| `decrees` | الأحكام والمراسيم |

Implementation: `lib/features/home/presentation/home_screen.dart` + `homeFeedProvider(categoryId)`.

## Bottom shell

**Home** | **Ai tender** (`/assistant`) | **Tenders** | **Profile**

## Key files

| Concern | Path |
|---------|------|
| Content API | `lib/features/content/data/content_repository.dart` |
| Models | `lib/features/content/domain/content_item.dart` |
| Storage URLs | `lib/core/supabase/storage_urls.dart` |
| AI chat | `lib/features/ai_chat/` |
| Billing | `lib/features/subscription/` |
| Search | `search()` on repository, limit 30 |

## Content type labels

| `content_type` | Arabic |
|----------------|--------|
| `article` | خبر |
| `tender` | مناقصة |
| `decree` | مرسوم |
| `addendum` | استدراك |

## In-app help (FAQ)

**Profile → المساعدة** (`/help`) — reads `app_help_page` + `app_help_items` (migration `010`).

## Auth (email, required)

Unauthenticated users → `/auth/sign-in`. Configure Email provider in Supabase Dashboard.

## Release build

```bash
flutter build apk --release --dart-define-from-file=.env
```

Must include `ADMIN_API_URL` for billing and AI chat.

## Checklist

- [ ] Migrations `001`–`013` on shared Supabase project
- [ ] MyFatoorah keys + webhook on Vercel; plans in admin `/subscriptions/plans`
- [ ] `ADMIN_API_URL` in `.env` / release build
- [ ] Sign in → paywall if no subscription → checkout → unlock
- [ ] Home feed + tenders load for subscribed users
- [ ] Profile → الاشتراك shows active plan
- [ ] AI chat works when subscribed
- [ ] FCM token saved after sign-in
- [ ] iOS + Android smoke test

## Related

- Admin: https://apophenia-five.vercel.app
- Mobile chat API: [mobile-chat-api.md](./mobile-chat-api.md)
- Figma copy: [figma-inventory.md](figma-inventory.md)
