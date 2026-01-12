import '../../../utils/result.dart';
import '../../entities/profile.dart';
import '../../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<Result<Profile>> call(Profile profile) {
    return repository.updateProfile(profile);
  }
}
