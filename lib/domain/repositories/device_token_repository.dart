import '../../utils/result.dart';

abstract class DeviceTokenRepository {
  Future<Result<void>> saveToken({
    required String userId,
    required String token,
    required String platform,
  });
}
