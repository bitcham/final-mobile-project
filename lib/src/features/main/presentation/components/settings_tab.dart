part of '../main_tab_screen.dart';

class _SettingsTab extends StatefulWidget {
  const _SettingsTab({
    required this.user,
    required this.watchlistMovies,
    required this.ratingHistory,
    this.onLogout,
    required this.onChangePassword,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  final AppUser user;
  final List<MovieView> watchlistMovies;
  final List<_RatingHistoryEntry> ratingHistory;
  final VoidCallback? onLogout;
  final PasswordChangeCallback onChangePassword;
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  String get _bio => widget.user.bio ?? _defaultProfileBio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 430;
        return SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, compact ? 12 : 32, 20, 34),
            children: [
              _ProfileSummaryCard(
                user: widget.user,
                bio: _bio,
                compact: compact,
              ),
              SizedBox(height: compact ? 12 : 22),
              const _SettingsSectionTitle('Account'),
              _SettingsRow(
                label: 'Change password',
                compact: compact,
                onPressed: () => _showChangePasswordDialog(context),
              ),
              SizedBox(height: compact ? 6 : 14),
              const _SettingsSectionTitle('Library'),
              _SettingsRow(
                label: 'My watchlist',
                compact: compact,
                onPressed: () =>
                    _showWatchlistDialog(context, widget.watchlistMovies),
              ),
              _SettingsRow(
                label: 'Rating history',
                compact: compact,
                onPressed: () =>
                    _showRatingHistoryDialog(context, widget.ratingHistory),
              ),
              SizedBox(height: compact ? 6 : 14),
              const _SettingsSectionTitle('App preferences'),
              _SettingsSwitchRow(
                label: 'Dark mode',
                value: widget.darkMode,
                compact: compact,
                onChanged: widget.onDarkModeChanged,
              ),
              _SettingsRow(
                label: 'Movie data source',
                compact: compact,
                icon: CupertinoIcons.info_circle,
                onPressed: () => _showMovieDataDialog(context),
              ),
              SizedBox(height: compact ? 6 : 14),
              if (widget.onLogout != null)
                _SettingsRow(
                  label: 'Log out',
                  compact: compact,
                  icon: CupertinoIcons.square_arrow_right,
                  destructive: true,
                  onPressed: widget.onLogout,
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMovieDataDialog(BuildContext context) {
    return showInfoDialog(
      context,
      title: 'Movie data source',
      message:
          'Cinerate uses TMDB for posters, trailers, cast, reviews, and streaming availability. Saved ratings and watchlist items stay in your local library.',
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;
    await showCupertinoDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => CupertinoAlertDialog(
          title: const Text('Change password'),
          content: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              children: [
                CupertinoTextField(
                  controller: currentController,
                  placeholder: 'Current password',
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: newController,
                  placeholder: 'New password',
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: confirmController,
                  placeholder: 'Confirm password',
                  obscureText: true,
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorText!,
                    style: const TextStyle(color: CupertinoColors.systemRed),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                final currentPassword = currentController.text;
                final newPassword = newController.text;
                if (newPassword.length < 8 ||
                    !RegExp(r'\d').hasMatch(newPassword)) {
                  setDialogState(
                    () =>
                        errorText = 'Use at least 8 characters and one digit.',
                  );
                  return;
                }
                if (newPassword != confirmController.text) {
                  setDialogState(() => errorText = 'Passwords do not match.');
                  return;
                }
                final changed = await widget.onChangePassword(
                  currentPassword: currentPassword,
                  newPassword: newPassword,
                );
                if (!changed) {
                  setDialogState(
                    () => errorText = 'Current password is incorrect.',
                  );
                  return;
                }
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (context.mounted) {
                  await showInfoDialog(
                    context,
                    title: 'Password updated',
                    message: 'Use the new password the next time you log in.',
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }
}
