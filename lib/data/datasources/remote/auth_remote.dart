import 'package:datn_foodecommerce_flutter_app/domain/entities/social_auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemote {
  final FirebaseAuth _fa;
  final GoogleSignIn _googleSignIn;

  AuthRemote(this._fa, {GoogleSignIn? googleSignIn}) : _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<String> signUpEmail(String email, String password) async {
    if (kDebugMode) debugPrint('[AuthRemote] signUpEmail email=$email');
    final cred = await _fa.createUserWithEmailAndPassword(email: email, password: password);
    return cred.user!.uid;
  }

  Future<String> signInEmail(String email, String password) async {
    if (kDebugMode) debugPrint('[AuthRemote] signInEmail email=$email');
    final cred = await _fa.signInWithEmailAndPassword(email: email, password: password);
    return cred.user!.uid;
  }

  Future<SocialAuthUser> signInWithGoogle() async {
    if (kDebugMode) debugPrint('[AuthRemote] signInWithGoogle start');
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(code: 'ERROR_ABORTED_BY_USER', message: 'Người dùng đã hủy đăng nhập Google');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _fa.signInWithCredential(credential);
    final user = cred.user!;
    return SocialAuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Future<void> sendPasswordResetEmail(String email) => _fa.sendPasswordResetEmail(email: email);

  Future<void> signOut() => _fa.signOut();

  Future<void> deleteCurrentUser() async {          // NEW
    final u = _fa.currentUser;
    if (u != null) {
      await u.delete(); // user vừa tạo -> "recent sign-in" nên delete được
    }
  }

  Stream<String?> authStateChanges() => _fa.authStateChanges().map((u) => u?.uid);
}
