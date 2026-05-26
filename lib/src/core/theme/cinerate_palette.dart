import 'package:flutter/cupertino.dart';

import 'app_theme.dart';

/// Resolved colour set for one brightness, shared by every main-tab surface.
class CineratePalette {
  const CineratePalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.tagBackground,
    required this.inputBackground,
    required this.shadow,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color textSecondary;
  final Color tagBackground;
  final Color inputBackground;
  final Color shadow;

  Color get primary => CinerateColors.primary;

  static const dark = CineratePalette(
    brightness: Brightness.dark,
    background: Color(0xFF0B0B0F),
    surface: Color(0xFF1C1C1E),
    surfaceAlt: Color(0xFF2C2C2E),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFAEAEB2),
    tagBackground: Color(0xFF3A3A3C),
    inputBackground: Color(0xFF1C1C1E),
    shadow: Color(0x7A000000),
  );

  static const light = CineratePalette(
    brightness: Brightness.light,
    background: Color(0xFFF5F5F7),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFE5E5EA),
    textPrimary: Color(0xFF111113),
    textSecondary: Color(0xFF6E6E73),
    tagBackground: Color(0xFFD1D1D6),
    inputBackground: Color(0xFFF2F2F7),
    shadow: Color(0x243C3C43),
  );
}

/// Exposes the active [CineratePalette] to the widget subtree.
class CinerateThemeScope extends InheritedWidget {
  const CinerateThemeScope({
    super.key,
    required this.palette,
    required super.child,
  });

  final CineratePalette palette;

  static CineratePalette of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<CinerateThemeScope>();
    return scope?.palette ?? CineratePalette.dark;
  }

  @override
  bool updateShouldNotify(CinerateThemeScope oldWidget) {
    return palette != oldWidget.palette;
  }
}

extension CineratePaletteContext on BuildContext {
  CineratePalette get cineratePalette => CinerateThemeScope.of(this);
}
