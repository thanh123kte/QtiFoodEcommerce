import 'package:flutter/foundation.dart';

import '../../../../utils/result.dart';
import '../../../entities/user.dart';
import '../../../entities/social_auth_user.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/user_repository.dart';

class SignInGoogle {
  final AuthRepository auth;
  final UserRepository userRepo;

  SignInGoogle(this.auth, this.userRepo);

  Future<Result<AppUser>> call() async {
    if (kDebugMode) {
      debugPrint('[SignInGoogle] start');
    }
    final res = await auth.signInWithGoogle();
    return await res.when(
      ok: (SocialAuthUser social) async {
        final uid = social.uid;
        final email = social.email ?? '';
        if (kDebugMode) {
          debugPrint('[SignInGoogle] auth ok uid=$uid email=$email -> fetch profile');
        }
        final profile = await userRepo.getUserById(uid);
        return await profile.when(
          ok: (user) => Ok(user),
          err: (message) async {
            if (kDebugMode) {
              debugPrint('[SignInGoogle] profile err=$message => attempt create');
            }
            if (email.isEmpty) {
              await _safeSignOut();
              return const Err('Không tìm thấy email từ Google');
            }
            final fullName = (social.displayName?.trim().isNotEmpty ?? false)
                ? social.displayName!.trim()
                : email.split('@').first;
            final newUser = AppUser(
              id: uid,
              fullName: fullName,
              email: email,
              avatarUrl: social.photoUrl,
              isActive: true,
              roles: const ['CUSTOMER'],
            );
            final created = await userRepo.createUserProfile(newUser, rawPassword: uid);
            return created.when(
              ok: (_) => Ok(newUser),
              err: (msg) async {
                if (kDebugMode) {
                  debugPrint('[SignInGoogle] create err=$msg => signOut');
                }
                await _safeSignOut();
                return Err(msg);
              },
            );
          },
        );
      },
      err: (message) {
        if (kDebugMode) {
          debugPrint('[SignInGoogle] auth err=$message');
        }
        return Err(message);
      },
    );
  }

  Future<void> _safeSignOut() async {
    try {
      await auth.signOut();
    } catch (_) {}
  }
}
