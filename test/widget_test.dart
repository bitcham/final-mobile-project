import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movie_rating/src/core/theme/app_theme.dart';
import 'package:movie_rating/src/core/widgets/cinerate_logo.dart';

void main() {
  testWidgets('CinerateLogo renders the brand name in the brand color', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        theme: cinerateCupertinoTheme,
        home: const CupertinoPageScaffold(
          child: Center(child: CinerateLogo()),
        ),
      ),
    );

    expect(find.text('CINERATE'), findsOneWidget);
  });
}
