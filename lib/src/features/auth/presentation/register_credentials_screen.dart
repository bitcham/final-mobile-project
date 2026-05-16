import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_rating/src/core/router/app_routes.dart';
import 'package:movie_rating/src/core/theme/app_theme.dart';
import 'package:movie_rating/src/core/widgets/cinerate_logo.dart';

import '../data/auth_validators.dart';

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
    return CupertinoPageScaffold(
      backgroundColor: CinerateColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CinerateColors.background,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.go(AppRoutes.login),
          child: const Icon(
            CupertinoIcons.back,
            color: CinerateColors.textPrimary,
          ),
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: CinerateLogo(fontSize: 32)),
                        const SizedBox(height: 8),
                        const Text(
                          'CREATE ACCOUNT',
                          textAlign: TextAlign.center,
                          style: CinerateText.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Step 1 of 2 — credentials',
                          textAlign: TextAlign.center,
                          style: CinerateText.bodySmall,
                        ),
                        const SizedBox(height: 36),
                        CupertinoTextFormFieldRow(
                          controller: _emailController,
                          placeholder: 'email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enableSuggestions: false,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: CinerateColors.inputBackground,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: CinerateColors.tagBackground,
                              width: 2,
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: CinerateColors.textPrimary,
                          ),
                          validator: validateEmail,
                        ),
                        const SizedBox(height: 28),
                        CupertinoTextFormFieldRow(
                          controller: _passwordController,
                          placeholder: 'password (min 8, 1 digit)',
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: CinerateColors.inputBackground,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: CinerateColors.tagBackground,
                              width: 2,
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: CinerateColors.textPrimary,
                          ),
                          validator: validatePassword,
                        ),
                        const SizedBox(height: 28),
                        CupertinoTextFormFieldRow(
                          controller: _confirmController,
                          placeholder: 'confirm password',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: CinerateColors.inputBackground,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: CinerateColors.tagBackground,
                              width: 2,
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: CinerateColors.textPrimary,
                          ),
                          validator: (value) => validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                          onFieldSubmitted: (_) => _onNext(),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.black.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CupertinoButton.filled(
                            onPressed: _onNext,
                            child: const Text(
                              'NEXT',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: CinerateText.bodyMedium.copyWith(
                                color: CinerateColors.textSecondary,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => context.go(AppRoutes.login),
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  color: CinerateColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
