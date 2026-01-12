// lib/data/repositories_impl/user_repository_impl.dart
import 'package:dio/dio.dart';
import '../../utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/user_local.dart';
import '../datasources/remote/user_remote.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemote remote;
  final UserLocal local;

  UserRepositoryImpl(this.remote, this.local);

  @override
  Future<Result<void>> createUserProfile(AppUser user, {required String rawPassword}) async {
    final model = AppUserModel(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      dateOfBirth: user.dateOfBirth,
      gender: user.gender,
      isActive: user.isActive ?? true,
      roles: user.roles,
    );

    try {
      await remote.postUser(model.toCreateDto(rawPassword: rawPassword));
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }

    try {
      await local.saveUser(model);
    } catch (e) {
      return Err('Local cache error: $e');
    }

    return const Ok(null);
  }

  @override
  Future<Result<AppUser>> getUserById(String id) async {
    Object? localError;
    try {
      final cached = await local.getUser(id);
      if (cached != null) {
        return Ok(cached.toEntity());
      }
    } catch (e) {
      localError = e;
    }

    try {
      final json = await remote.getUserById(id);
      final model = AppUserModel.fromJson(json);
      try {
        await local.saveUser(model);
      } catch (e) {
        return Err('Local cache error: $e');
      }
      return Ok(model.toEntity());
    } on DioException catch (e) {
      final remoteMessage = e.response?.data?.toString() ?? e.message ?? 'API error';
      if (localError != null) {
        return Err('Local cache error: $localError; Remote error: $remoteMessage');
      }
      return Err(remoteMessage);
    } catch (e) {
      if (localError != null) {
        return Err('Local cache error: $localError; Remote error: ${e.toString()}');
      }
      return Err(e.toString());
    }
  }
}
