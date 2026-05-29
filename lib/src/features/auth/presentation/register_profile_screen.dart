import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:movie_rating/src/core/router/app_routes.dart';
import 'package:movie_rating/src/core/widgets/profile_avatar.dart';

import '../data/auth_providers.dart';
import '../data/auth_repository.dart';
import '../data/auth_validators.dart';
import 'auth_screen_chrome.dart';

enum _ProfileImageAction { camera, gallery, remove }

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

  Future<void> _openPicker() async {
    final action = await showCupertinoDialog<_ProfileImageAction>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Profile picture'),
          actions: [
            CupertinoDialogAction(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_ProfileImageAction.camera),
              child: const Text('Take photo'),
            ),
            CupertinoDialogAction(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_ProfileImageAction.gallery),
              child: const Text('Choose from gallery'),
            ),
            if (_profileImagePath != null)
              CupertinoDialogAction(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(_ProfileImageAction.remove),
                child: const Text('Use default picture'),
              ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _ProfileImageAction.camera:
        await _pickImage(ImageSource.camera);
        break;
      case _ProfileImageAction.gallery:
        await _pickImage(ImageSource.gallery);
        break;
      case _ProfileImageAction.remove:
        setState(() => _profileImagePath = null);
        break;
    }
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
    return CinematicAuthScaffold(
      onBack: () => context.go(AppRoutes.register),
      eyebrow: 'CREATE ACCOUNT',
      title: 'Your profile',
      subtitle: 'Step 2 of 2 - name & photo',
      builder: (context, compact) {
        final avatarSize = compact ? 72.0 : 116.0;
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthStepIndicator(step: 2),
              SizedBox(height: compact ? 12 : 24),
              Center(
                child: ProfileAvatar(
                  imagePath: _profileImagePath,
                  size: avatarSize,
                  onTap: _submitting ? null : _openPicker,
                  showEditBadge: true,
                ),
              ),
              SizedBox(height: compact ? 4 : 8),
              Center(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(36, 30),
                  onPressed: _submitting ? null : _openPicker,
                  child: Text(
                    _profileImagePath == null
                        ? 'Add a profile picture (optional)'
                        : 'Change profile picture',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF6B64),
                    ),
                  ),
                ),
              ),
              SizedBox(height: compact ? 8 : 18),
              CinerateAuthField(
                controller: _nameController,
                placeholder: 'username',
                icon: CupertinoIcons.person,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                validator: validateRealName,
                onFieldSubmitted: (_) => _submit(),
              ),
              SizedBox(height: compact ? 12 : 22),
              CinerateAuthButton(
                label: 'FINISH',
                loading: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}
