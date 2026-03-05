part of 'styles.dart';

class AppWidgetStyles {
  const AppWidgetStyles._();

  static OutlinedButtonThemeData outlinedButton(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        side: BorderSide(
          color: colorScheme.onSurface.withOpacity(0.18),
          width: 1.0,
        ),
      ),
    );
  }

  static TextButtonThemeData textButton(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  static FilledButtonThemeData filledButton(ColorScheme colorScheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        overlayColor: Colors.transparent,
        disabledBackgroundColor: colorScheme.primary.withOpacity(0.38),
        disabledForegroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  static RadioThemeData radio(ColorScheme colorScheme) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0xAAE8E8E8);
        }
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return const Color(0xFFE8E8E8);
      }),
    );
  }

  static AppBarTheme appBar({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required TextColorTheme textColorTheme,
    required bool isDark,
  }) {
    return AppBarTheme(
      centerTitle: true,
      surfaceTintColor: colorScheme.surface,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      titleTextStyle: textTheme.titleMedium,
      iconTheme: IconThemeData(
        color: textColorTheme.textColorTertiary,
      ),
      systemOverlayStyle: AppStyles._immersiveSystemUiOverlayStyle(isDark),
    );
  }

  static DividerThemeData divider(ColorScheme colorScheme, bool isDark) {
    return isDark
        ? DividerThemeData(
            thickness: 0.5,
            space: 0.5,
            color: colorScheme.outlineVariant,
          )
        : const DividerThemeData(
            color: Color(0xffE9EDF0),
            thickness: 0.5,
            space: 0.5,
          );
  }

  static TabBarThemeData tabBar(
      ColorScheme colorScheme, TextColorTheme textColorTheme) {
    return TabBarThemeData(
      dividerColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      indicator: UnderlineTabIndicator(
        borderRadius: BorderRadius.circular(3),
        borderSide: BorderSide(width: 3.0, color: colorScheme.primary),
      ),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelColor: textColorTheme.textColorSecondary,
      labelColor: textColorTheme.textColorPrimary,
    );
  }
}
