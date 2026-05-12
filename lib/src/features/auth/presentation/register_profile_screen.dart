import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:movie_rating/src/core/router/app_routes.dart';
import 'package:movie_rating/src/core/theme/app_theme.dart';
import 'package:movie_rating/src/core/widgets/profile_avatar.dart';

import '../data/auth_providers.dart';
import '../data/auth_repository.dart';
import '../data/auth_validators.dart';

class RegisterProfileScreen extends ConsumerStatefulWidget {
  const RegisterProfileScreen({super.key, required this.pending});

  final PendingRegistration pending;

  @override
  ConsumerState<RegisterProfileScreen> createState() =>
      _RegisterProfileScreenState();
}

class _RegisterProfileScreenState extends ConsumerState<RegisterProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _profileImagePath;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final service = ref.read(profileImageServiceProvider);
    try {
      final path = await service.pickAndStoreProfileImage(source);
      if (path != null && mounted) {
        setState(() => _profileImagePath = path);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showAlert('Could not load image: $error');
    }
  }

  void _openPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(popupContext).pop();
                _pickImage(ImageSource.camera);
              },
              child: const Text('Take photo'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(popupContext).pop();
                _pickImage(ImageSource.gallery);
              },
              child: const Text('Choose from gallery'),
            ),
            if (_profileImagePath != null)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(popupContext).pop();
                  setState(() => _profileImagePath = null);
                },
                child: const Text('Use default picture'),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(popupContext).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  void _showAlert(String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _submitting = true);
    final controller = ref.read(authControllerProvider.notifier);
    try {
      await controller.register(
        email: widget.pending.email,
        password: widget.pending.password,
        realName: _nameController.text.trim(),
        profileImagePath: _profileImagePath,
      );
    } on EmailAlreadyRegisteredException {
      if (!mounted) {
        return;
      }
      setState(() => _submitting = false);
      _showAlert('email already registered');
      return;
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _submitting = false);
      _showAlert('Registration failed: $error');
      return;
    }
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
          onPressed: () => context.go(AppRoutes.register),
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
                        const Text(
                          'YOUR PROFILE',
                          textAlign: TextAlign.center,
                          style: CinerateText.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Step 2 of 2 — name & photo',
                          textAlign: TextAlign.center,
                          style: CinerateText.bodySmall,
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: ProfileAvatar(
                            imagePath: _profileImagePath,
                            size: 120,
                            onTap: _submitting ? null : _openPicker,
                            showEditBadge: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _submitting ? null : _openPicker,
                            child: Text(
                              _profileImagePath == null
                                  ? 'Add a profile picture (optional)'
                                  : 'Change profile picture',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                color: CinerateColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CupertinoTextFormFieldRow(
                          controller: _nameController,
                          placeholder: 'real name',
                          textCapitalization: TextCapitalization.words,
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
                          validator: validateRealName,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.black.withOpacity(0.15),
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
                                    'FINISH',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                          ),
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
