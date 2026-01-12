import '../../../utils/result.dart';
import '../../entities/profile.dart';
import '../../repositories/profile_repository.dart';

class RefreshProfile {
  final ProfileRepository repository;

  RefreshProfile(this.repository);

  Future<Result<Profile>> call(String userId) {
    return repository.refreshProfile(userId);
  }
}
