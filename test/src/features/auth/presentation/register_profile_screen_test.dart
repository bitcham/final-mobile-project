import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_rating/src/core/router/app_routes.dart';
import 'package:movie_rating/src/features/auth/presentation/register_profile_screen.dart';

void main() {
  testWidgets('keeps the finish button reachable on short browser heights', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 428);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: RegisterProfileScreen(
            pending: PendingRegistration(
              email: 'short-view@example.test',
              password: 'password1',
            ),
          ),
        ),
      ),
    );

    final finishRect = tester.getRect(find.text('FINISH'));
    expect(finishRect.bottom, lessThanOrEqualTo(428));
  });

  testWidgets('shows all profile picture choices within the browser viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1067, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: RegisterProfileScreen(
            pending: PendingRegistration(
              email: 'picture-view@example.test',
              password: 'password1',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add a profile picture (optional)'));
    await tester.pumpAndSettle();

    for (final label in ['Take photo', 'Choose from gallery', 'Cancel']) {
      final rect = tester.getRect(find.text(label));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(600));
    }
  });
}
