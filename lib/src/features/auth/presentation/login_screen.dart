import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_rating/src/core/router/app_routes.dart';
import 'package:movie_rating/src/core/theme/app_theme.dart';
import 'package:movie_rating/src/core/widgets/cinerate_logo.dart';

import '../data/auth_providers.dart';
import '../data/auth_validators.dart';

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
    return CupertinoPageScaffold(
      backgroundColor: CinerateColors.background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: CinerateLogo(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue',
                          textAlign: TextAlign.center,
                          style: CinerateText.bodyMedium.copyWith(
                            color: CinerateColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 40),
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
                          placeholder: 'password',
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
                          validator: validateLoginPassword,
                          onFieldSubmitted: (_) => _submit(),
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
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? const CupertinoActivityIndicator(
                                    color: CinerateColors.textPrimary,
                                  )
                                : const Text(
                                    'LOG IN',
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
                              'No account? ',
                              style: CinerateText.bodyMedium.copyWith(
                                color: CinerateColors.textSecondary,
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
