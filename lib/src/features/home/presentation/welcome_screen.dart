import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_rating/src/features/auth/data/auth_providers.dart';
import 'package:movie_rating/src/features/auth/models/app_user.dart';
import 'package:movie_rating/src/features/main/presentation/main_tab_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const _fallbackUser = AppUser(
    id: 0,
    email: 'moviefan@example.com',
    passwordHash: '',
    passwordSalt: '',
    realName: 'Movie Fan',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = switch (authState.value) {
      Authenticated(:final user) => user,
      _ => _fallbackUser,
    };

    return MainTabScreen(
      user: user,
      onLogout: () => ref.read(authControllerProvider.notifier).logout(),
      onUpdateProfile: (realName) => ref
          .read(authControllerProvider.notifier)
          .updateProfile(realName: realName),
      onChangePassword: ({required currentPassword, required newPassword}) =>
          ref
              .read(authControllerProvider.notifier)
              .changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword,
              ),
    );
  }
}
