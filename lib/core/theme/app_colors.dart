import 'package:flutter/material.dart';

/// Tokens — Blue & White theme (matching reference screenshot)
abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const background    = Color(0xFFF3F4F6); // Light gray background for contrast
  static const surface       = Color(0xFFFFFFFF); // White cards / sheets
  static const sheet         = Color(0xFFFFFFFF);
  static const surfaceHigh   = Color(0xFFF5F7FA); // Very light blue-gray for alternating rows

  // ── Typography ───────────────────────────────────────────────────────────
  static const black         = Color(0xFF0D1B2A); // Near-black body text
  static const foreground    = Color(0xFF0D1B2A); // Primary text
  static const foregroundSoft= Color(0xFF2C3E5D); // Secondary / softer text
  static const muted         = Color(0xFF8A9BB5); // Hint / placeholder text
  static const bodyMuted     = Color(0xFFB0BEC5); // Light muted

  // ── Borders ──────────────────────────────────────────────────────────────
  static const borderSubtle  = Color(0xFFE3EAF4); // Light blue-tinted divider
  static const borderStrong  = Color(0xFFCFDAED); // Stronger blue-tinted border

  // ── Brand — Navy / Royal Blue ─────────────────────────────────────────────
  /// Deep navy used for AppBar header background (matches screenshot header)
  static const primary       = Color(0xFF17375E); // Dark navy header
  static const onPrimary     = Color(0xFFFFFFFF); // White text/icons on primary

  /// Royal blue used for the search bar background inside the header
  static const primaryVariant= Color(0xFF1A4F8A); // Royal blue (search bar bg)

  /// Lighter medium blue — active tab, icons, links
  static const link          = Color(0xFF2166BE); // Active blue accent

  // ── Utility ──────────────────────────────────────────────────────────────
  static const inputHint     = Color(0xFF8A9BB5);
  static const searchBarBg   = Color(0xFF1A4F8A); // Royal blue search bg
  static const chipSelectedBg= Color(0xFFE3EAF4); // Light blue chip bg
  static const error         = Color(0xFFE53935);

  // ── Legacy aliases ────────────────────────────────────────────────────────
  static const card   = surface;
  static const border = borderSubtle;
  static const accent = link;
}
