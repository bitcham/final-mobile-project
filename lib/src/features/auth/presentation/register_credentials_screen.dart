import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_rating/src/core/router/app_routes.dart';
import 'package:movie_rating/src/core/theme/app_theme.dart';

import '../data/auth_validators.dart';
import 'auth_screen_chrome.dart';

class RegisterCredentialsScreen extends StatefulWidget {
  const RegisterCredentialsScreen({super.key});

  @override
  State<RegisterCredentialsScreen> createState() =>
      _RegisterCredentialsScreenState();
}

class _RegisterCredentialsScreenState extends State<RegisterCredentialsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final pending = PendingRegistration(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    context.go(AppRoutes.registerProfile, extra: pending);
  }

  @override
  Widget build(BuildContext context) {
    return CinematicAuthScaffold(
      onBack: () => context.go(AppRoutes.login),
      eyebrow: 'CREATE ACCOUNT',
      title: 'Build your profile',
      subtitle: 'A sharper sign-up flow for ratings and watchlists.',
      builder: (context, compact) => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthStepIndicator(step: 1),
            SizedBox(height: compact ? 14 : 22),
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
              placeholder: 'password (min 8, 1 digit)',
              icon: CupertinoIcons.lock,
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: validatePassword,
            ),
            SizedBox(height: compact ? 12 : 16),
            CinerateAuthField(
              controller: _confirmController,
              placeholder: 'confirm password',
              icon: CupertinoIcons.checkmark_shield,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (value) =>
                  validateConfirmPassword(value, _passwordController.text),
              onFieldSubmitted: (_) => _onNext(),
            ),
            SizedBox(height: compact ? 16 : 22),
            CinerateAuthButton(label: 'NEXT', onPressed: _onNext),
            SizedBox(height: compact ? 10 : 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: CinerateText.bodyMedium.copyWith(
                    color: const Color(0xFFAEB6C3),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text(
                    'Log in',
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
