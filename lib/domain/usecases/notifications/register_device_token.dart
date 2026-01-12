import '../../../utils/result.dart';
import '../../repositories/device_token_repository.dart';

class RegisterDeviceToken {
  final DeviceTokenRepository repository;

  RegisterDeviceToken(this.repository);

  Future<Result<void>> call({
    required String userId,
    required String token,
    required String platform,
  }) {
    return repository.saveToken(userId: userId, token: token, platform: platform);
  }
}
