import 'package:datn_foodecommerce_flutter_app/utils/result.dart';

import '../../entities/profile.dart';
import '../../repositories/profile_repository.dart';

class UploadAvatar {
  final ProfileRepository repository;

  UploadAvatar(this.repository);

  Future<Result<Profile>> call({
    required String userId,
    required String filePath,
  }) {
    return repository.uploadAvatar(userId, filePath);
  }
}
