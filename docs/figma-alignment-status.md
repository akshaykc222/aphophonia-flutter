# Figma ↔ Flutter alignment status

**Last checked:** 2026-05-24  
**Figma file:** `USyLppbnpc0puKz8YSakn2` — [Apophenia](https://www.figma.com/design/USyLppbnpc0puKz8YSakn2/Apophenia)

## MCP authentication

| Check | Status |
|-------|--------|
| Figma MCP connected | Yes |
| Authenticated as | `akshaykc222@gmail.com` (Akshay Kc) |
| Teams on account | Akshay Kc's team, Warmonks |

## File access (blocker)

| Tool | Result |
|------|--------|
| `get_metadata` | **Cannot access file** |
| `get_design_context` | **Cannot access file** |
| `use_figma` | **Cannot access file** |

The MCP user must be able to open the file in Figma with the same account. Until access is fixed, pixel-level alignment cannot be verified or updated.

### Fix file access

1. In Figma, open **Apophenia**.
2. Click **Share**.
3. Invite **`akshaykc222@gmail.com`** with at least **can view** (edit is fine too).
4. Confirm the file lives in a team/plan that account can access (not only a personal link to another org).
5. In Cursor Agent, ask again: *“Inventory Apophenia Figma and align Flutter.”*

Alternatively: **Duplicate** the file into **Warmonks** (a team on your MCP account) and send the new file URL.

## Flutter implementation (ready for audit)

Routes implemented in `lib/core/router/app_router.dart`:

| Route | Screen |
|-------|--------|
| `/splash` | Splash |
| `/onboarding` | Onboarding (3 slides) |
| `/` | Home (featured + feed) |
| `/categories` | Categories grid |
| `/categories/:slug` | Category feed |
| `/ministries` | Ministries list |
| `/ministries/:slug` | Ministry feed |
| `/tenders` | Tenders + category chips |
| `/search` | Search |
| `/content/:slug` | Content detail |
| `/saved` | Bookmarks |
| `/settings` | Settings |
| `/dev/components` | Design system (debug) |

Design tokens in code: `lib/core/theme/app_colors.dart` (black / zinc / amber — from admin `globals.css`, not yet verified against Figma variables).

## After file access works

1. List all Figma pages/frames → update `figma-inventory.md`.
2. `get_variable_defs` per screen → update `AppColors`, `AppSpacing`, `AppTheme`.
3. `get_design_context` + screenshots per frame → adjust widgets.
4. Re-run `flutter analyze` and manual simulator check.
