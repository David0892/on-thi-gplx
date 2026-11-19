import 'package:flutter/material.dart';

import 'tokens.g.dart';

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness b) {
    final scheme = ColorScheme(
      brightness: b,
      primary: c.accent,
      onPrimary: c.onAccent,
      primaryContainer: c.accentSoft,
      onPrimaryContainer: c.text,
      secondary: c.accent,
      onSecondary: c.onAccent,
      error: c.danger,
      onError: c.onDanger,
      errorContainer: c.dangerSoft,
      onErrorContainer: c.text,
      surface: c.bg,
      onSurface: c.text,
      onSurfaceVariant: c.textMuted,
      surfaceContainerLowest: c.bg,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surface,
      surfaceContainerHighest: c.surface,
      outline: c.borderInput,
      outlineVariant: c.border,
    );
    const textTheme = TextTheme(
      displayLarge: AppType.display,
      headlineMedium: AppType.xl,
      titleLarge: AppType.lg,
      titleMedium: AppType.question,
      bodyLarge: AppType.base,
      bodyMedium: AppType.sm,
      labelLarge: AppType.base,
      labelMedium: AppType.sm,
      labelSmall: AppType.xs,
    );
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surface,
      fontFamily: AppFont.family,
      fontFamilyFallback: AppFont.fallback,
      textTheme: textTheme.apply(bodyColor: c.text, displayColor: c.text),
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: AppLayout.appBar,
        titleTextStyle: AppType.lg.copyWith(color: c.text),
        shape: Border(bottom: BorderSide(color: c.border)),
      ),
      dividerTheme: DividerThemeData(color: c.border, space: 1, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(AppLayout.tapTargetMin, 48),
          textStyle: AppType.base.copyWith(fontWeight: FontWeight.w600),
          shape: rounded,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(AppLayout.tapTargetMin, 48),
          foregroundColor: c.text,
          side: BorderSide(color: c.borderInput),
          textStyle: AppType.base.copyWith(fontWeight: FontWeight.w600),
          shape: rounded,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppLayout.tapTargetMin, 48),
          foregroundColor: c.accent,
          textStyle: AppType.base.copyWith(fontWeight: FontWeight.w600),
          shape: rounded,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        titleTextStyle: AppType.lg.copyWith(color: c.text),
        contentTextStyle: AppType.base.copyWith(color: c.textMuted),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.bg,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.text,
        contentTextStyle: AppType.sm.copyWith(color: c.bg),
        shape: rounded,
      ),
      focusColor: c.accent.withValues(alpha: 0.12),
    );
  }
}
