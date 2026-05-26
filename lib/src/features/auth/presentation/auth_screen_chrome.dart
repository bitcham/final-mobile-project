import 'package:flutter/cupertino.dart';

import 'package:movie_rating/src/core/widgets/cinerate_logo.dart';

class CinematicAuthScaffold extends StatelessWidget {
  const CinematicAuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.builder,
    this.eyebrow,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final String? eyebrow;
  final VoidCallback? onBack;
  final Widget Function(BuildContext context, bool compact) builder;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0B0D10),
      child: Stack(
        children: [
          const Positioned.fill(child: _AuthBackdrop()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 560;
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 18 : 24,
                        compact ? 10 : 24,
                        compact ? 18 : 24,
                        compact ? 14 : 28,
                      ),
                      child: Column(
                        mainAxisAlignment: compact
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF14171D),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: CupertinoColors.white.withValues(
                                      alpha: 0.08,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: CupertinoColors.black.withValues(
                                        alpha: 0.24,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    compact ? 18 : 24,
                                    compact ? 18 : 24,
                                    compact ? 18 : 24,
                                    compact ? 18 : 24,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          if (onBack != null)
                                            CinerateAuthBackButton(
                                              onPressed: onBack!,
                                            )
                                          else
                                            const SizedBox(width: 40),
                                          const Expanded(
                                            child: Center(
                                              child: CinerateLogo(fontSize: 25),
                                            ),
                                          ),
                                          const SizedBox(width: 40),
                                        ],
                                      ),
                                      SizedBox(height: compact ? 16 : 24),
                                      if (eyebrow != null) ...[
                                        Text(
                                          eyebrow!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.4,
                                            color: Color(0xFFFF5B55),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      Text(
                                        title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: compact ? 24 : 28,
                                          height: 1.08,
                                          fontWeight: FontWeight.w800,
                                          color: CupertinoColors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        subtitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: compact ? 12 : 13,
                                          height: 1.45,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFAEB6C3),
                                        ),
                                      ),
                                      SizedBox(height: compact ? 18 : 26),
                                      builder(context, compact),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CinerateAuthField extends StatefulWidget {
  const CinerateAuthField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.obscureText = false,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool obscureText;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<CinerateAuthField> createState() => _CinerateAuthFieldState();
}

class _CinerateAuthFieldState extends State<CinerateAuthField> {
  late final bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      controller: widget.controller,
      placeholder: widget.placeholder,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      obscureText: _obscured,
      padding: EdgeInsets.zero,
      prefix: Padding(
        padding: const EdgeInsets.only(left: 14, right: 8),
        child: Icon(widget.icon, size: 17, color: const Color(0xFF9AA3B2)),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1218),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.10),
        ),
      ),
      placeholderStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        color: Color(0xFF7F8897),
      ),
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.white,
      ),
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}

class CinerateAuthButton extends StatelessWidget {
  const CinerateAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFE53B35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53B35).withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        borderRadius: BorderRadius.circular(8),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
            : Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: CupertinoColors.white,
                ),
              ),
      ),
    );
  }
}

class CinerateAuthBackButton extends StatelessWidget {
  const CinerateAuthBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(40, 40),
      borderRadius: BorderRadius.circular(20),
      color: CupertinoColors.white.withValues(alpha: 0.06),
      onPressed: onPressed,
      child: const Icon(
        CupertinoIcons.back,
        color: CupertinoColors.white,
        size: 20,
      ),
    );
  }
}

class AuthStepIndicator extends StatelessWidget {
  const AuthStepIndicator({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 1; index <= 2; index++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: index == step ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: index == step
                  ? const Color(0xFFE53B35)
                  : CupertinoColors.white.withValues(alpha: 0.18),
            ),
          ),
          if (index != 2) const SizedBox(width: 7),
        ],
      ],
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF11141A), Color(0xFF0B0D10)],
        ),
      ),
      child: CustomPaint(painter: _AuthBackdropPainter()),
    );
  }
}

class _AuthBackdropPainter extends CustomPainter {
  const _AuthBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = const Color(0xFFE53B35).withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 92);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.16), 120, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
