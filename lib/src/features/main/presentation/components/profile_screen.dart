part of '../main_tab_screen.dart';

class _ProfileScreen extends StatefulWidget {
  const _ProfileScreen({
    required this.user,
    required this.watchlistMovies,
    required this.ratingHistory,
    required this.onUpdateProfile,
    required this.onPickProfileImage,
    required this.onPickProfileBanner,
  });

  final AppUser user;
  final List<MovieView> watchlistMovies;
  final List<_RatingHistoryEntry> ratingHistory;
  final ProfileUpdateCallback onUpdateProfile;
  final Future<String?> Function(ImageSource source) onPickProfileImage;
  final Future<String?> Function(ImageSource source) onPickProfileBanner;

  @override
  State<_ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<_ProfileScreen> {
  late AppUser _user = widget.user;

  String get _bio => _user.bio ?? _defaultProfileBio;

  @override
  void didUpdateWidget(covariant _ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _user = widget.user;
    }
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: _user.realName);
    final bioController = TextEditingController(text: _bio);
    String? errorText;

    await showCupertinoDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => CupertinoAlertDialog(
          title: const Text('Edit profile'),
          content: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              children: [
                CupertinoTextField(
                  controller: nameController,
                  placeholder: 'Real name',
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: bioController,
                  placeholder: 'Bio',
                  maxLines: 3,
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
                final name = nameController.text.trim();
                final bio = bioController.text.trim();
                if (name.isEmpty) {
                  setDialogState(() => errorText = 'Name is required.');
                  return;
                }
                if (bio.isEmpty) {
                  setDialogState(() => errorText = 'Bio is required.');
                  return;
                }

                final updated = await widget.onUpdateProfile(
                  realName: name,
                  bio: bio,
                );
                if (!mounted) {
                  return;
                }
                setState(() => _user = updated);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    bioController.dispose();
  }

  Future<void> _changeProfileImage() async {
    final source = await _pickImageSource(title: 'Profile picture');
    if (source == null) {
      return;
    }

    final imagePath = await widget.onPickProfileImage(source);
    if (imagePath == null || !mounted) {
      return;
    }
    final updated = await widget.onUpdateProfile(profileImagePath: imagePath);
    if (mounted) {
      setState(() => _user = updated);
    }
  }

  Future<void> _changeBanner() async {
    final source = await _pickImageSource(title: 'Profile banner');
    if (source == null) {
      return;
    }

    final bannerPath = await widget.onPickProfileBanner(source);
    if (bannerPath == null || !mounted) {
      return;
    }
    final updated = await widget.onUpdateProfile(
      profileBannerImagePath: bannerPath,
    );
    if (mounted) {
      setState(() => _user = updated);
    }
  }

  Future<ImageSource?> _pickImageSource({required String title}) {
    return showCupertinoModalPopup<ImageSource>(
      context: context,
      useRootNavigator: false,
      builder: (context) => CupertinoActionSheet(
        title: Text(title),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            child: const Text('Choose from library'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            child: const Text('Take a photo'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return CupertinoPageScaffold(
      key: const ValueKey('profile-screen'),
      backgroundColor: palette.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              sliver: SliverList.list(
                children: [
                  const _ProfileTopBar(),
                  const SizedBox(height: 22),
                  _ProfileHero(
                    user: _user,
                    bio: _bio,
                    onEditProfile: _showEditProfileDialog,
                    onChangeProfileImage: _changeProfileImage,
                    onChangeBanner: _changeBanner,
                  ),
                  const SizedBox(height: 18),
                  _ProfileStats(
                    watchlistCount: widget.watchlistMovies.length,
                    ratedCount: widget.ratingHistory.length,
                    averageRating: _averageRating(widget.ratingHistory),
                  ),
                  const SizedBox(height: 18),
                  _ProfileActionStrip(onEditProfile: _showEditProfileDialog),
                  const SizedBox(height: 24),
                  _ProfileSection(
                    title: 'Saved movies',
                    child: _ProfileMovieList(
                      movies: widget.watchlistMovies.take(3).toList(),
                      emptyIcon: CupertinoIcons.heart,
                      emptyMessage: 'No saved movies yet',
                    ),
                  ),
                  const SizedBox(height: 22),
                  _ProfileSection(
                    title: 'Recent ratings',
                    child: _ProfileRatingList(
                      entries: widget.ratingHistory.take(3).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _averageRating(List<_RatingHistoryEntry> entries) {
    if (entries.isEmpty) {
      return null;
    }
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.rating);
    return total / entries.length;
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar();

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Row(
      children: [
        _ProfileIconButton(
          key: const ValueKey('profile-back-button'),
          icon: CupertinoIcons.chevron_left,
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Text(
            'Profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: palette.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 40, height: 40),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.user,
    required this.bio,
    required this.onEditProfile,
    required this.onChangeProfileImage,
    required this.onChangeBanner,
  });

  final AppUser user;
  final String bio;
  final VoidCallback onEditProfile;
  final VoidCallback onChangeProfileImage;
  final VoidCallback onChangeBanner;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    final handle = _profileHandleFromEmail(user.email);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: palette.surface,
        border: Border.all(color: palette.tagBackground),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.34),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileBannerHeader(
            user: user,
            onEditProfile: onEditProfile,
            onChangeProfileImage: onChangeProfileImage,
            onChangeBanner: onChangeBanner,
          ),
          const SizedBox(height: 14),
          Text(
            user.realName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            handle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            bio,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBannerHeader extends StatelessWidget {
  const _ProfileBannerHeader({
    required this.user,
    required this.onEditProfile,
    required this.onChangeProfileImage,
    required this.onChangeBanner,
  });

  final AppUser user;
  final VoidCallback onEditProfile;
  final VoidCallback onChangeProfileImage;
  final VoidCallback onChangeBanner;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 214,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _ProfileBanner(
              imagePath: user.profileBannerImagePath,
              onChangeBanner: onChangeBanner,
            ),
          ),
          Positioned(
            bottom: 0,
            child: ProfileAvatar(
              imagePath: user.profileImagePath,
              size: 104,
              showEditBadge: true,
              onTap: onChangeProfileImage,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner({required this.imagePath, required this.onChangeBanner});

  final String? imagePath;
  final VoidCallback onChangeBanner;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    final hasValidFile =
        imagePath != null &&
        imagePath!.isNotEmpty &&
        File(imagePath!).existsSync();
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 154,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasValidFile)
              Image.file(File(imagePath!), fit: BoxFit.cover)
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      palette.primary.withValues(alpha: 0.95),
                      const Color(0xFF4B5563),
                      palette.surfaceAlt,
                    ],
                  ),
                ),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CupertinoColors.black.withValues(alpha: 0.05),
                    CupertinoColors.black.withValues(alpha: 0.52),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: CupertinoButton(
                key: const ValueKey('profile-change-banner'),
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 36),
                borderRadius: BorderRadius.circular(18),
                onPressed: onChangeBanner,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: CupertinoColors.black.withValues(alpha: 0.46),
                    border: Border.all(
                      color: CupertinoColors.white.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.photo,
                          size: 15,
                          color: CupertinoColors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Change banner',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({
    required this.watchlistCount,
    required this.ratedCount,
    required this.averageRating,
  });

  final int watchlistCount;
  final int ratedCount;
  final double? averageRating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProfileStatTile(
            label: 'Saved',
            value: watchlistCount.toString(),
            icon: CupertinoIcons.heart_fill,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ProfileStatTile(
            label: 'Rated',
            value: ratedCount.toString(),
            icon: CupertinoIcons.star_fill,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ProfileStatTile(
            label: 'Average',
            value: averageRating?.toStringAsFixed(1) ?? '-',
            icon: CupertinoIcons.chart_bar_fill,
          ),
        ),
      ],
    );
  }
}

class _ProfileStatTile extends StatelessWidget {
  const _ProfileStatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Container(
      height: 88,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: palette.surface,
        border: Border.all(color: palette.tagBackground),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 17, color: palette.primary),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: palette.textPrimary,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionStrip extends StatelessWidget {
  const _ProfileActionStrip({required this.onEditProfile});

  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return _ProfileActionButton(
      label: 'Edit profile',
      icon: CupertinoIcons.pencil,
      prominent: true,
      onPressed: onEditProfile,
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _ProfileMovieList extends StatelessWidget {
  const _ProfileMovieList({
    required this.movies,
    required this.emptyIcon,
    required this.emptyMessage,
  });

  final List<MovieView> movies;
  final IconData emptyIcon;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return _ProfileEmptyState(icon: emptyIcon, message: emptyMessage);
    }
    return Column(
      children: [
        for (final movie in movies)
          _ProfileMovieRow(
            movie: movie,
            trailing: movie.rating.toStringAsFixed(1),
          ),
      ],
    );
  }
}

class _ProfileRatingList extends StatelessWidget {
  const _ProfileRatingList({required this.entries});

  final List<_RatingHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _ProfileEmptyState(
        icon: CupertinoIcons.star,
        message: 'No ratings yet',
      );
    }
    return Column(
      children: [
        for (final entry in entries)
          _ProfileMovieRow(
            movie: entry.movie,
            trailing: entry.rating.toStringAsFixed(1),
          ),
      ],
    );
  }
}

class _ProfileMovieRow extends StatelessWidget {
  const _ProfileMovieRow({required this.movie, required this.trailing});

  final MovieView movie;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: palette.surface,
        border: Border.all(color: palette.tagBackground),
      ),
      child: Row(
        children: [
          _ProfilePoster(movie: movie),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${movie.year} - ${movie.genres.isEmpty ? 'Movie' : movie.genres.first}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(CupertinoIcons.star_fill, size: 13, color: palette.primary),
          const SizedBox(width: 4),
          Text(
            trailing,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePoster extends StatelessWidget {
  const _ProfilePoster({required this.movie});

  final MovieView movie;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 44,
        height: 64,
        child: posterUrl == null
            ? _ProfilePosterFallback(movie: movie)
            : Image.network(
                posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _ProfilePosterFallback(movie: movie),
              ),
      ),
    );
  }
}

class _ProfilePosterFallback extends StatelessWidget {
  const _ProfilePosterFallback({required this.movie});

  final MovieView movie;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: movie.palette,
        ),
      ),
    );
  }
}

class _ProfileEmptyState extends StatelessWidget {
  const _ProfileEmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: palette.surface,
        border: Border.all(color: palette.tagBackground),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: palette.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: palette.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.prominent = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    final background = prominent ? palette.primary : palette.surface;
    final foreground = prominent ? CupertinoColors.white : palette.textPrimary;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 48),
      borderRadius: BorderRadius.circular(18),
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: background,
          border: Border.all(
            color: prominent
                ? CupertinoColors.white.withValues(alpha: 0.16)
                : palette.tagBackground,
          ),
        ),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: foreground),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileIconButton extends StatelessWidget {
  const _ProfileIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(40, 40),
      borderRadius: BorderRadius.circular(20),
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.surface,
          border: Border.all(color: palette.tagBackground),
        ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: palette.textPrimary),
        ),
      ),
    );
  }
}
