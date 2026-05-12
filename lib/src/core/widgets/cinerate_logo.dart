import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';

class CinerateLogo extends StatelessWidget {
  const CinerateLogo({
    super.key,
    this.fontSize = 26,
    this.fontWeight = FontWeight.w900,
  });

  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      'CINERATE',
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: CinerateColors.primary,
        letterSpacing: 4,
      ),
    );
  }
}
