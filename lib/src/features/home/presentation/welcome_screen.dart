import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_rating/src/core/theme/app_theme.dart';
import 'package:movie_rating/src/core/widgets/cinerate_logo.dart';
import 'package:movie_rating/src/core/widgets/profile_avatar.dart';
import 'package:movie_rating/src/features/auth/data/auth_providers.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = switch (authState.value) {
      Authenticated(:final user) => user,
      _ => null,
    };

    return CupertinoPageScaffold(
      backgroundColor: CinerateColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: CinerateLogo(fontSize: 28)),
              const Spacer(),
              Center(
                child: ProfileAvatar(
                  imagePath: user?.profileImagePath,
                  size: 120,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                user == null
                    ? 'Welcome back.'
                    : 'Welcome back, ${user.realName}.',
                textAlign: TextAlign.center,
                style: CinerateText.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'You are logged in your favorite movie app.',
                textAlign: TextAlign.center,
                style: CinerateText.bodyLarge.copyWith(
                  color: CinerateColors.textSecondary,
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: CinerateColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
