import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.imagePath,
    this.size = 96,
    this.onTap,
    this.showEditBadge = false,
  });

  final String? imagePath;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;

  static const String fallbackAsset =
      'assets/images/fallback_profile_picture.png';

  @override
  Widget build(BuildContext context) {
    final hasValidFile =
        imagePath != null &&
        imagePath!.isNotEmpty &&
        File(imagePath!).existsSync();
    final ImageProvider image = hasValidFile
        ? FileImage(File(imagePath!))
        : const AssetImage(fallbackAsset);

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CinerateColors.surface,
        border: Border.all(color: CinerateColors.tagBackground, width: 2),
        image: DecorationImage(image: image, fit: BoxFit.cover),
      ),
    );

    final stack = Stack(
      alignment: Alignment.bottomRight,
      children: [
        avatar,
        if (showEditBadge)
          Container(
            width: size * 0.32,
            height: size * 0.32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: CinerateColors.primary,
            ),
            child: const Icon(
              CupertinoIcons.pencil,
              size: 16,
              color: CinerateColors.textPrimary,
            ),
          ),
      ],
    );

    if (onTap == null) {
      return stack;
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: stack,
    );
  }
}
