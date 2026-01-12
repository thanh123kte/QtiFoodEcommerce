import 'package:flutter/foundation.dart';

import '../../../../domain/entities/profile.dart';
import '../../../../domain/usecases/profile/get_profile.dart';
import '../../../../domain/usecases/profile/refresh_profile.dart';
import '../../../../domain/usecases/profile/update_profile.dart';
import '../../../../domain/usecases/profile/upload_avatar.dart';
import '../../../../utils/result.dart';
import 'profile_ui_state.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetProfile getProfile;
  final RefreshProfile refreshProfile;
  final UpdateProfile updateProfile;
  final UploadAvatar uploadAvatarUsecase;

  ProfileViewModel(this.getProfile, this.refreshProfile, this.updateProfile, this.uploadAvatarUsecase);

  ProfileUiState _uiState = const ProfileInitial();
  ProfileUiState get uiState => _uiState;

  String? _userId;

  bool get isLoading => _uiState is ProfileLoading || _uiState is ProfileRefreshing;

  void _emit(ProfileUiState state) {
    if (identical(_uiState, state)) return;
    _uiState = state;
    notifyListeners();
  }

  Future<void> loadProfile({
    required String userId,
    bool forceRefresh = false,
  }) async {
    if (userId.isEmpty) {
      _emit(const ProfileError('Khong tim thay thong tin tai khoan'));
      return;
    }

    _userId = userId;

    if (forceRefresh) {
      final currentData = _currentData;
      if (currentData != null) {
        _emit(ProfileRefreshing(currentData));
      } else {
        _emit(const ProfileLoading());
      }
      final result = await refreshProfile(userId);
      result.when(
        ok: (profile) => _emit(ProfileLoaded(_map(profile))),
        err: (message) => _emit(ProfileError(message)),
      );
      return;
    }

    if (isLoading) return;
    _emit(const ProfileLoading());

    final result = await getProfile(userId);
    result.when(
      ok: (profile) => _emit(ProfileLoaded(_map(profile))),
      err: (message) => _emit(ProfileError(message)),
    );
  }

  Future<void> retry() async {
    final id = _userId;
    if (id == null) return;
    await loadProfile(userId: id);
  }

  Future<void> refresh() async {
    final id = _userId;
    if (id == null) return;
    await loadProfile(userId: id, forceRefresh: true);
  }

  Future<Result<ProfileViewData>> uploadAvatar(String filePath) async {
    final id = _userId;
    if (id == null) {
      return const Err('Khong tim thay thong tin tai khoan');
    }
    final previous = _currentData;
    if (previous != null) {
      _emit(ProfileRefreshing(previous));
    }

    final result = await uploadAvatarUsecase(userId: id, filePath: filePath);
    return result.when(
      ok: (profile) {
        final mapped = _map(profile);
        _emit(ProfileLoaded(mapped));
        return Ok(mapped);
      },
      err: (message) {
        if (previous != null) {
          _emit(ProfileLoaded(previous));
        } else {
          _emit(ProfileError(message));
        }
        return Err(message);
      },
    );
  }

  Future<Result<void>> submitProfileUpdate({
    required String fullName,
    required String email,
    String? phone,
    String? gender,
    DateTime? birthDate,
  }) async {
    final id = _userId;
    if (id == null) {
      return const Err('Khong tim thay thong tin tai khoan');
    }

    final previous = _currentData;
    final pending = ProfileViewData(
      displayName: fullName.trim().isNotEmpty
          ? fullName.trim()
          : (email.trim().isNotEmpty ? email.trim() : previous?.displayName ?? 'Nguoi dung'),
      email: email.trim().isNotEmpty ? email.trim() : null,
      phone: phone != null && phone.trim().isNotEmpty ? phone.trim() : null,
      avatarUrl: previous?.avatarUrl,
      birthDate: birthDate,
      gender: gender,
      role: previous?.role,
    );

    _emit(ProfileRefreshing(pending));

    final result = await updateProfile(
      Profile(
        id: id,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone?.trim().isNotEmpty == true ? phone!.trim() : null,
        avatarUrl: previous?.avatarUrl,
        dateOfBirth: birthDate,
        gender: gender,
      ),
    );

    return result.when(
      ok: (profile) {
        _emit(ProfileLoaded(_map(profile)));
        return const Ok(null);
      },
      err: (message) {
        if (previous != null) {
          _emit(ProfileLoaded(previous));
        } else {
          _emit(ProfileError(message));
        }
        return Err(message);
      },
    );
  }

  ProfileViewData? get _currentData {
    final state = _uiState;
    if (state is ProfileLoaded) return state.data;
    if (state is ProfileRefreshing) return state.data;
    return null;
  }

  ProfileViewData _map(Profile profile) {
    final fullName = profile.fullName.trim();
    final email = profile.email.trim();
    final phone = profile.phone?.trim();
    final avatar = profile.avatarUrl?.trim();

    return ProfileViewData(
      displayName: fullName.isNotEmpty
          ? fullName
          : (email.isNotEmpty ? email : 'Nguoi dung'),
      email: email.isNotEmpty ? email : null,
      phone: phone != null && phone.isNotEmpty ? phone : null,
      avatarUrl: avatar != null && avatar.isNotEmpty ? avatar : null,
      birthDate: profile.dateOfBirth,
      gender: profile.gender,
      role: profile.role,
    );
  }
}
