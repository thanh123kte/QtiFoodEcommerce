class ProfileViewData {
  final String displayName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final DateTime? birthDate;
  final String? gender;
  final String? role;

  const ProfileViewData({
    required this.displayName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.birthDate,
    this.gender,
    this.role,
  });
}

sealed class ProfileUiState {
  const ProfileUiState();
}

class ProfileInitial extends ProfileUiState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileUiState {
  const ProfileLoading();
}

class ProfileRefreshing extends ProfileUiState {
  final ProfileViewData data;

  const ProfileRefreshing(this.data);
}

class ProfileLoaded extends ProfileUiState {
  final ProfileViewData data;

  const ProfileLoaded(this.data);
}

class ProfileError extends ProfileUiState {
  final String message;

  const ProfileError(this.message);
}
