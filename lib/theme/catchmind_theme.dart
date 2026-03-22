import 'package:flutter/material.dart';

/// 暖灰底 + 柔和青绿强调（降低视觉刺激，偏 ADHD 友好）
abstract final class CatchMindColors {
  static const Color canvas = Color(0xFFF5F4F2);
  static const Color navMint = Color(0xFFE8F3F1);
  static const Color accent = Color(0xFF5A9B91);
  static const Color accentDeep = Color(0xFF3D7A72);
  static const Color quadrantSurface = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFE5E3E0);
  static const Color textPrimary = Color(0xFF2C2C2E);
  static const Color textSecondary = Color(0xFF7A7A7E);
  static const Color dragStripIdle = Color(0xFFEBEAE8);
  static const Color dragStripActive = Color(0xFFC5E8E2);

  /// 四象限极浅区分
  static const Color qImportantUrgent = Color(0xFFFFF5F4);
  static const Color qImportantNotUrgent = Color(0xFFEEF6FF);
  static const Color qUrgentNotImportant = Color(0xFFFFF9E8);
  static const Color qNotImportantNotUrgent = Color(0xFFF2F8F4);
}

Color readableOnFill(Color background) {
  final l = background.computeLuminance();
  return l > 0.55 ? CatchMindColors.textPrimary : Colors.white;
}

Color readableSecondaryOnFill(Color background) {
  final l = background.computeLuminance();
  return l > 0.55
      ? CatchMindColors.textSecondary
      : Colors.white.withAlpha((0.88 * 255).round());
}

Color mutedTagFill(Color tagColor) {
  final hsl = HSLColor.fromColor(tagColor);
  return hsl
      .withSaturation((hsl.saturation * 0.28).clamp(0.0, 1.0))
      .withLightness(0.91)
      .toColor();
}

ThemeData buildCatchMindTheme() {
  const accent = CatchMindColors.accent;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: CatchMindColors.canvas,
    colorScheme: ColorScheme.light(
      primary: accent,
      onPrimary: Colors.white,
      primaryContainer: CatchMindColors.dragStripActive,
      onPrimaryContainer: CatchMindColors.accentDeep,
      surface: Colors.white,
      onSurface: CatchMindColors.textPrimary,
      outline: CatchMindColors.hairline,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: CatchMindColors.canvas,
      foregroundColor: CatchMindColors.textPrimary,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 78,
      backgroundColor: CatchMindColors.navMint,
      indicatorColor: accent.withAlpha((0.2 * 255).round()),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          letterSpacing: 0.2,
          color: selected ? accent : CatchMindColors.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? accent : CatchMindColors.textSecondary,
          size: 28,
        );
      }),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 3,
      highlightElevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    dialogTheme: DialogThemeData(
      elevation: 10,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      shadowColor: Colors.black26,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: accent,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: const DividerThemeData(
      color: CatchMindColors.hairline,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: CatchMindColors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: CatchMindColors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
    ),
  );
}
