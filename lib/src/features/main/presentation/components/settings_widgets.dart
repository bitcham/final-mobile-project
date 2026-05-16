part of '../main_tab_screen.dart';

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.user,
    required this.bio,
    required this.onEditBio,
    this.compact = false,
  });

  final AppUser user;
  final String bio;
  final VoidCallback onEditBio;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final handle = _profileHandleFromEmail(user.email);
    final palette = context.cineratePalette;
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: palette.surface,
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileAvatar(
                imagePath: user.profileImagePath,
                size: compact ? 46 : 58,
              ),
              SizedBox(width: compact ? 10 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          user.realName,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: compact ? 25 : 32,
                            fontWeight: FontWeight.w800,
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      handle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CinerateText.bodyMedium.copyWith(
                        color: palette.textSecondary,
                        fontSize: compact ? 13 : 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  '"$bio"',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CinerateText.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: compact ? 12 : 14,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              CupertinoButton(
                key: const ValueKey('edit-bio-button'),
                padding: EdgeInsets.zero,
                minimumSize: const Size(32, 32),
                onPressed: onEditBio,
                child: Icon(
                  CupertinoIcons.square_pencil,
                  color: palette.textSecondary,
                  size: 25,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _profileHandleFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    final safeHandle = localPart
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '')
        .replaceAll(RegExp(r'_+'), '_');
    return '@${safeHandle.isEmpty ? 'cinefan' : safeHandle}';
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    this.compact = false,
    this.icon,
    this.destructive = false,
    this.onPressed,
  });

  final String label;
  final bool compact;
  final IconData? icon;
  final bool destructive;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    final color = destructive ? CupertinoColors.systemRed : palette.textPrimary;
    final row = SizedBox(
      height: compact ? 42 : 54,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: compact ? 16 : 18,
                color: color,
              ),
            ),
          ),
          Icon(icon ?? CupertinoIcons.chevron_right, color: color, size: 20),
        ],
      ),
    );

    if (onPressed == null) {
      return row;
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: row,
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return SizedBox(
      height: compact ? 42 : 56,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: compact ? 16 : 18,
                color: palette.textPrimary,
              ),
            ),
          ),
          Transform.scale(
            scale: compact ? 0.68 : 0.8,
            child: CupertinoSwitch(
              value: value,
              activeTrackColor: palette.primary,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
