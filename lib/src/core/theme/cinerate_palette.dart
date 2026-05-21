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
    required this.navBackground,
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
  final Color navBackground;
  final Color shadow;

  Color get primary => CinerateColors.primary;

  static const dark = CineratePalette(
    brightness: Brightness.dark,
    background: Color(0xFF2A2A2A),
    surface: Color(0xFF171717),
    surfaceAlt: Color(0xFF202020),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA0A0A0),
    tagBackground: Color(0xFF3A3A3A),
    inputBackground: Color(0xFF151515),
    navBackground: Color(0xEA000000),
    shadow: Color(0x66000000),
  );

  static const light = CineratePalette(
    brightness: Brightness.light,
    background: Color(0xFFF5F6F8),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFE9ECF1),
    textPrimary: Color(0xFF161A22),
    textSecondary: Color(0xFF68707D),
    tagBackground: Color(0xFFD8DDE5),
    inputBackground: Color(0xFFFFFFFF),
    navBackground: Color(0xF2FFFFFF),
    shadow: Color(0x2A334155),
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
