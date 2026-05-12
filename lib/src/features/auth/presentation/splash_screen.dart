import 'package:flutter/cupertino.dart';

import 'package:movie_rating/src/core/theme/app_theme.dart';
import 'package:movie_rating/src/core/widgets/cinerate_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      backgroundColor: CinerateColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CinerateLogo(fontSize: 32),
            SizedBox(height: 24),
            CupertinoActivityIndicator(color: CinerateColors.primary),
          ],
        ),
      ),
    );
  }
}
