import 'package:flutter/cupertino.dart';

class CinerateColors {
  const CinerateColors._();

  static const Color background = Color(0xFF2A2A2A);
  static const Color surface = Color(0xFF000000);
  static const Color primary = Color(0xFFDC2626);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color tagBackground = Color(0xFF3A3A3A);
  static const Color inputBackground = Color(0xFF1A1A1A);
}

class CinerateText {
  const CinerateText._();

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: CinerateColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: CinerateColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: CinerateColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    color: CinerateColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    color: CinerateColors.textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: CinerateColors.textPrimary,
  );
}

final CupertinoThemeData cinerateCupertinoTheme = const CupertinoThemeData(
  brightness: Brightness.dark,
  primaryColor: CinerateColors.primary,
  primaryContrastingColor: CinerateColors.textPrimary,
  scaffoldBackgroundColor: CinerateColors.background,
  barBackgroundColor: CinerateColors.background,
  textTheme: CupertinoTextThemeData(
    primaryColor: CinerateColors.primary,
    textStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      color: CinerateColors.textPrimary,
    ),
    navTitleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: CinerateColors.textPrimary,
    ),
    actionTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: CinerateColors.primary,
    ),
  ),
);
