import 'package:dio/dio.dart';

import '../../domain/repositories/device_token_repository.dart';
import '../../utils/result.dart';
import '../datasources/remote/device_token_remote.dart';

class DeviceTokenRepositoryImpl implements DeviceTokenRepository {
  final DeviceTokenRemote remote;

  DeviceTokenRepositoryImpl(this.remote);

  @override
  Future<Result<void>> saveToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    try {
      final existing = await remote.getTokens(userId);
      if (existing.isNotEmpty) {
        for (final old in existing) {
          try {
            await remote.deleteToken(userId: userId, token: old);
          } catch (_) {}
        }
      }
      await remote.registerToken(userId: userId, token: token, platform: platform);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }
}
