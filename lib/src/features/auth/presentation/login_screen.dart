import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_rating/src/core/router/app_routes.dart';
import 'package:movie_rating/src/core/theme/app_theme.dart';

import '../data/auth_providers.dart';
import '../data/auth_validators.dart';
import 'auth_screen_chrome.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _submitting = true);
    final controller = ref.read(authControllerProvider.notifier);
    final ok = await controller.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    if (!ok) {
      showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          content: const Text('wrong email or password'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CinematicAuthScaffold(
      eyebrow: 'TONIGHT STARTS HERE',
      title: 'Welcome back',
      subtitle: 'Pick up your ratings, watchlist, and next movie night.',
      builder: (context, compact) => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CinerateAuthField(
              controller: _emailController,
              placeholder: 'email',
              icon: CupertinoIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
              validator: validateEmail,
            ),
            SizedBox(height: compact ? 12 : 16),
            CinerateAuthField(
              controller: _passwordController,
              placeholder: 'password',
              icon: CupertinoIcons.lock,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: validateLoginPassword,
              onFieldSubmitted: (_) => _submit(),
            ),
            SizedBox(height: compact ? 16 : 22),
            CinerateAuthButton(
              label: 'LOG IN',
              loading: _submitting,
              onPressed: _submit,
            ),
            SizedBox(height: compact ? 10 : 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No account? ',
                  style: CinerateText.bodyMedium.copyWith(
                    color: const Color(0xFFAEB6C3),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _submitting
                      ? null
                      : () => context.go(AppRoutes.register),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF6B64),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
