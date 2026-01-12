
import '../../utils/result.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Result<void>> createUserProfile(AppUser user, {required String rawPassword});
  Future<Result<AppUser>> getUserById(String firebaseUserId);
}
