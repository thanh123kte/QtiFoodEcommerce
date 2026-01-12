// lib/domain/usecases/auth/login/sign_in_email.dart
import 'package:flutter/foundation.dart';

import '../../../../utils/result.dart';
import '../../../entities/user.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/user_repository.dart';

class SignInEmail {
  final AuthRepository auth;
  final UserRepository userRepo;

  SignInEmail(this.auth, this.userRepo);

  Future<Result<AppUser>> call({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      debugPrint('[SignInEmail] start email=$email');
    }
    final res = await auth.signInWithEmail(email, password);
    return await res.when(
      ok: (uid) async {
        if (kDebugMode) {
          debugPrint('[SignInEmail] auth ok uid=$uid -> fetch profile');
        }
        final profile = await userRepo.getUserById(uid);
        return profile.when(
          ok: (user) => Ok(user),
          err: (message) async {
            if (kDebugMode) {
              debugPrint('[SignInEmail] profile err=$message => signOut');
            }
            // Đảm bảo không giữ phiên khi backend không có hồ sơ
            try {
              await auth.signOut();
            } catch (_) {}
            return Err(message);
          },
        );
      },
      err: (message) {
        if (kDebugMode) {
          debugPrint('[SignInEmail] auth err=$message');
        }
        return Err(message);
      },
    );
  }
}
