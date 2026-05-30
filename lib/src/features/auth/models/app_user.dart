class AppUser {
  const AppUser({
    this.id,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
    required this.realName,
    this.profileImagePath,
    this.profileBannerImagePath,
    this.bio,
  });

  final int? id;
  final String email;
  final String passwordHash;
  final String passwordSalt;
  final String realName;
  final String? profileImagePath;
  final String? profileBannerImagePath;
  final String? bio;

  AppUser copyWith({
    int? id,
    String? email,
    String? passwordHash,
    String? passwordSalt,
    String? realName,
    String? profileImagePath,
    String? profileBannerImagePath,
    String? bio,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      realName: realName ?? this.realName,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      profileBannerImagePath:
          profileBannerImagePath ?? this.profileBannerImagePath,
      bio: bio ?? this.bio,
    );
  }

  factory AppUser.fromRow(Map<String, Object?> row) {
    return AppUser(
      id: row['id'] as int?,
      email: row['email'] as String? ?? '',
      passwordHash: row['password_hash'] as String? ?? '',
      passwordSalt: row['password_salt'] as String? ?? '',
      realName: row['real_name'] as String? ?? '',
      profileImagePath: row['profile_image_path'] as String?,
      profileBannerImagePath: row['profile_banner_image_path'] as String?,
      bio: row['bio'] as String?,
    );
  }

  Map<String, Object?> toRow() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'password_hash': passwordHash,
      'password_salt': passwordSalt,
      'real_name': realName,
      'profile_image_path': profileImagePath,
      'profile_banner_image_path': profileBannerImagePath,
      'bio': bio,
    };
  }
}
