
import 'package:flutter/foundation.dart';

import '../../utils/result.dart';
import '../../domain/entities/social_auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemote remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<Result<String>> signInWithEmail(String email, String password) async {
    if (kDebugMode) debugPrint('[AuthRepo] signInWithEmail email=$email');
    try { final uid = await remote.signInEmail(email, password); return Ok(uid); }
    catch (e) { return Err(e.toString()); }
  }

  @override
  Future<Result<SocialAuthUser>> signInWithGoogle() async {
    if (kDebugMode) debugPrint('[AuthRepo] signInWithGoogle');
    try { final user = await remote.signInWithGoogle(); return Ok(user); }
    catch (e) { return Err(e.toString()); }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    if (kDebugMode) debugPrint('[AuthRepo] sendPasswordResetEmail email=$email');
    try { await remote.sendPasswordResetEmail(email); return const Ok(null); }
    catch (e) { return Err(e.toString()); }
  }

  @override
  Future<Result<String>> signUpWithEmail(String email, String password) async {
    if (kDebugMode) debugPrint('[AuthRepo] signUpWithEmail email=$email');
    try { final uid = await remote.signUpEmail(email, password); return Ok(uid); }
    catch (e) { return Err(e.toString()); }
  }

  @override Future<void> signOut() => remote.signOut();
  @override Stream<String?> authStateChanges() => remote.authStateChanges();
  @override Future<void> deleteCurrentUser() => remote.deleteCurrentUser(); // NEW
}
