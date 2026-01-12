import '../../utils/result.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Result<Profile>> getProfile(String userId);
  Future<Result<Profile>> refreshProfile(String userId);
  Future<Result<Profile>> updateProfile(Profile profile);
  Future<Result<Profile>> uploadAvatar(String userId, String filePath);
}
