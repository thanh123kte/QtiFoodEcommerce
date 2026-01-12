import '../../../../utils/result.dart';
import '../../../repositories/auth_repository.dart';

class SendPasswordReset {
  final AuthRepository auth;

  SendPasswordReset(this.auth);

  Future<Result<void>> call(String email) => auth.sendPasswordResetEmail(email);
}
