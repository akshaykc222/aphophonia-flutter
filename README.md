# apophenia_flutter

Mobile consumer app for **كويت اليوم** (Kuwait Today) — read-only client for published gazette content from Supabase (same project as the [apophenia](https://github.com/akshaykc222/apophenia) admin panel).

**Integration guide:** [docs/flutter-integration.md](docs/flutter-integration.md)

## Features

- RTL Arabic UI aligned with [Apophenia (Copy) Figma](https://www.figma.com/design/uQaHH9vqWuCsaRNIz9wI6l/Apophenia--Copy-)
- Auth: splash → sign in / sign up → OTP (phone)
- 4-tab shell: Home, Assistant, Tenders, Profile
- Home feed, search, AI assistant tab, notifications, favorites, subscription
- Supabase-backed content + local bookmarks
- Responsive layouts and screen transitions

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install).
2. Copy environment file:

   ```bash
   cp .env.example .env
   ```

3. Add your Supabase URL and anon/publishable key (same as the admin app):

   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ADMIN_API_URL=https://your-apophenia.vercel.app
   ```

4. Install dependencies and run:

   ```bash
   flutter pub get
   cp .env.example .env   # then fill in Supabase URL + anon key
   flutter run --dart-define-from-file=.env
   ```

   **Cursor / VS Code:** use **Run → Start Debugging** (F5) — `.vscode/launch.json` passes `--dart-define-from-file=.env` automatically.

## Figma

Design file (accessible copy): [Apophenia (Copy)](https://www.figma.com/design/uQaHH9vqWuCsaRNIz9wI6l/Apophenia--Copy-?node-id=0-1)

Original (share with MCP account if needed): [Apophenia](https://www.figma.com/design/USyLppbnpc0puKz8YSakn2/Apophenia)

Screen inventory + node IDs: [docs/figma-inventory.md](docs/figma-inventory.md)

Figma MCP: **Settings → MCP** → enable Figma → authenticate in chat.

## Project structure

```
lib/
  core/          # theme, router, config, providers
  features/      # home, content, categories, search, …
  shared/        # widgets, animations
```

## Data

Reads `content_items` where `is_published = true`, plus public reference tables (`categories`, `ministries`, `tender_categories`).
