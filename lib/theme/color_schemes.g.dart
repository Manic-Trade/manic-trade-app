import 'package:finality/theme/app_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';

// ----------------------------- Light Theme -----------------------------

const lightTextColorTheme = TextColorTheme(
  textColorPrimary: Color(0xFF212121), 
  textColorSecondary: Color(0x993C3C43),
  textColorTertiary: Color(0x4D3C3C43),
  textColorQuaternary: Color(0x4D3C3C43),
  textColorHelper: Color(0x4D3C3C43),
  textColorPrimaryInverse: Color(0xFFE3E2E6),
);

const lightAppColorTheme = AppColorTheme(
  bullish: Color(0xFF33BD65),
  bearish: Color(0xFFE84E74),
  dragHandleColor: Color(0xFFD8E2FF),
  bottomSheetTitle: Color(0xFF212121),
  bottomSheetSubtitle: Color(0x993C3C43),
);

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFFF9500),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD8E2FF),
  onPrimaryContainer: Color(0xFF001A41),
  secondary: Color(0xFF565E71),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xffF2F2F7),
  onSecondaryContainer: Color(0xFF141B2C),
  tertiary: Color(0xFF1660A5),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFD3E4FF),
  onTertiaryContainer: Color(0xFF001C38),
  error: Color(0xffba1a1a),
  onError: Color(0xffffffff),
  errorContainer: Color(0xffffdad6),
  onErrorContainer: Color(0xFFFF3B30),
  background: Color(0xFFFFFFFF),
  onBackground: Color(0xFF1B1B1F),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF212121),
  surfaceVariant: Color(0xFFF2F2F7),
  surfaceContainerHighest: Color(0xFFF2F2F7),
  surfaceContainerLow: Color(0xFFF5F6FA),
  onSurfaceVariant: Color(0xFF44474F),
  outline: Color(0xFF74777F),
  onInverseSurface: Color(0xFFF2F0F4),
  inverseSurface: Color(0xFF303033),
  inversePrimary: Color(0xFFADC6FF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF005BC1),
  outlineVariant: Color(0xFFC4C6D0),
  scrim: Color(0xFF000000),
);

// ----------------------------- Dark Theme -----------------------------

const darkTextColorTheme = TextColorTheme(
  textColorPrimary: Color(0xFFFFFFFF),
  textColorSecondary: Color(0xFFDADADA),
  textColorTertiary: Color(0xFF969696),
  textColorQuaternary: Color(0xFF555555),
  textColorHelper: Color(0xFF454545),
  textColorPrimaryInverse: Color(0xFF000000),
);

const darkAppColorTheme = AppColorTheme(
  bullish: Color(0xFF00D385),
  bearish: Color(0xFFFF412C),
  dragHandleColor: Color(0xFF27272A),
  bottomSheetTitle: Color(0xFFD1D1D6),
  bottomSheetSubtitle: Color(0xFF7C7C7C),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0XFFDB8300),
  onPrimary: Color(0xFF000000),
  primaryContainer: Color(0xFF004493),
  onPrimaryContainer: Color(0xFFD8E2FF),
  secondary: Color(0xFFBFC6DC),
  onSecondary: Color(0xFF293041),
  secondaryContainer: Color(0xFF3F4759),
  onSecondaryContainer: Color(0xFFDBE2F9),
  tertiary: Color(0xFFA3C9FF),
  onTertiary: Color(0xFF00315C),
  tertiaryContainer: Color(0xFF004882),
  onTertiaryContainer: Color(0xFFD3E4FF),
  error: Color(0xff740006),
  onError: Color(0xffffffff),
  errorContainer: Color.fromARGB(255, 99, 36, 34),
  onErrorContainer: Color.fromARGB(255, 218, 201, 201),

  surfaceDim: Color(0xFF000000),
  surface: Color(0xFF101010),

  onSurface: Color(0xFFFFFFFF),

  surfaceContainerLowest: Color(0xFF101010),
  surfaceContainerLow: Color(0xFF101010),
  surfaceContainer: Color(0xFF101010),

  surfaceContainerHigh: Color(0xFF161616),
  surfaceContainerHighest: Color(0xFF232323),

  onSurfaceVariant: Color(0xFF969696),

  outlineVariant: Color(0xFF1F1F1F),
  outline: Color(0xFF3B3B3B),

  onInverseSurface: Color(0xFF1B1B1F),
  inverseSurface: Color(0xFFE3E2E6),
  inversePrimary: Color(0xFF005BC1),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFADC6FF),
  scrim: Color(0xFF000000),
);
