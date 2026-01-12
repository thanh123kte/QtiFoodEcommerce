// lib/domain/usecases/auth/register/sign_up_email.dart
import 'package:flutter/foundation.dart';

import '../../../../utils/result.dart';
import '../../../entities/user.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/user_repository.dart';

class SignUpEmail {
  final AuthRepository auth;
  final UserRepository userRepo;

  SignUpEmail(this.auth, this.userRepo);

  Future<Result<void>> call({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? avatarUrl,
    DateTime? dob,
    String? gender,
    bool? isActive,
    List<String>? roles,
  }) async {
    if (kDebugMode) {
      debugPrint('[SignUpEmail] start email=$email fullName=$fullName');
    }
    final res = await auth.signUpWithEmail(email, password);

    return await res.when(
      ok: (uid) async {
        if (kDebugMode) {
          debugPrint('[SignUpEmail] firebase ok uid=$uid -> create profile');
        }
        final user = AppUser(
          id: uid,
          fullName: fullName,
          email: email,
          phone: phone,
          avatarUrl: avatarUrl,
          dateOfBirth: dob,
          gender: gender,
          isActive: isActive ?? true,
          roles: (roles == null || roles.isEmpty) ? ['CUSTOMER'] : roles,
        );

        final created = await userRepo.createUserProfile(
          user,
          rawPassword: password,
        );

        return await created.when(
          ok: (_) async {
            if (kDebugMode) {
              debugPrint('[SignUpEmail] profile created -> stay signed in');
            }
            return const Ok(null);
          },
          err: (message) async {
            if (kDebugMode) {
              debugPrint('[SignUpEmail] profile err=$message => delete firebase user');
            }
            try {
              await auth.deleteCurrentUser();
            } catch (_) {}
            return Err(message);
          },
        );
      },
      err: (message) {
        if (kDebugMode) {
          debugPrint('[SignUpEmail] firebase err=$message');
        }
        return Err(message);
      },
    );
  }
}
