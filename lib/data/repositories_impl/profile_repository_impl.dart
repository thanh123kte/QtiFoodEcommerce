import 'package:dio/dio.dart';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../utils/result.dart';
import '../datasources/local/user_local.dart';
import '../datasources/remote/user_remote.dart';
import '../models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final UserLocal local;
  final UserRemote remote;

  ProfileRepositoryImpl(this.local, this.remote);

  @override
  Future<Result<Profile>> getProfile(String userId) async {
    String? localError;
    try {
      final cached = await local.getUser(userId);
      if (cached != null) {
        return Ok(_mapToProfile(cached));
      }
    } catch (e) {
      localError = 'Local cache error: $e';
    }

    final remoteResult = await _fetchAndCache(userId);

    return remoteResult.when(
      ok: (profile) => Ok(profile),
      err: (message) {
        if (localError != null) {
          return Err('$localError; Remote error: $message');
        }
        return Err(message);
      },
    );
  }

  @override
  Future<Result<Profile>> refreshProfile(String userId) {
    return _fetchAndCache(userId);
  }

  @override
  Future<Result<Profile>> updateProfile(Profile profile) async {
    AppUserModel? existing;
    try {
      existing = await local.getUser(profile.id);
    } catch (_) {}

    if (existing == null) {
      try {
        final json = await remote.getUserById(profile.id);
        existing = AppUserModel.fromJson(json);
      } on DioException catch (e) {
        return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
      } catch (e) {
        return Err(e.toString());
      }
    }

    final updated = existing.copyWith(
      fullName: profile.fullName,
      email: profile.email,
      phone: profile.phone,
      avatarUrl: profile.avatarUrl,
      dateOfBirth: profile.dateOfBirth,
      gender: profile.gender,
      roles: profile.role != null ? [profile.role!] : existing.roles,
    );

    try {
      await remote.updateUser(profile.id, updated.toUpdateDto());
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }

    try {
      await local.saveUser(updated);
    } catch (_) {}

    return Ok(_mapToProfile(updated));
  }

  @override
  Future<Result<Profile>> uploadAvatar(String userId, String filePath) async {
    AppUserModel? existing;
    try {
      existing = await local.getUser(userId);
    } catch (_) {}

    try {
      final url = await remote.uploadAvatar(userId, filePath);
      existing ??= await _loadRemoteUser(userId);
      if (existing == null) return const Err('Khong tim thay nguoi dung');
      final updated = existing.copyWith(avatarUrl: url);
      try {
        await local.saveUser(updated);
      } catch (_) {}
      return Ok(_mapToProfile(updated));
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<AppUserModel?> _loadRemoteUser(String userId) async {
    final json = await remote.getUserById(userId);
    return AppUserModel.fromJson(json);
  }

  Future<Result<Profile>> _fetchAndCache(String userId) async {
    try {
      final json = await remote.getUserById(userId);
      final model = AppUserModel.fromJson(json);

      try {
        await local.saveUser(model);
      } catch (_) {}

      return Ok(_mapToProfile(model));
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  Profile _mapToProfile(AppUserModel model) {
    final avatar = _resolveUrl(model.avatarUrl);
    return Profile(
      id: model.id,
      fullName: model.fullName,
      email: model.email,
      phone: model.phone,
      avatarUrl: avatar,
      dateOfBirth: model.dateOfBirth,
      gender: model.gender,
      role: model.roles.isNotEmpty ? model.roles.first : null,
    );
  }

  String? _resolveUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    final base = remote.dio.options.baseUrl;
    if (url.startsWith('/')) {
      return base.endsWith('/') ? '${base.substring(0, base.length - 1)}$url' : '$base$url';
    }
    return base.endsWith('/') ? '$base$url' : '$base/$url';
  }
}
