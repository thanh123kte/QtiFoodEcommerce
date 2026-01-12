
import '../entities/social_auth_user.dart';
import '../../utils/result.dart';

abstract class AuthRepository {
  Future<Result<String>> signUpWithEmail(String email, String password); // returns uid
  Future<Result<String>> signInWithEmail(String email, String password); // returns uid
  Future<Result<SocialAuthUser>> signInWithGoogle(); // returns user info
  Future<Result<void>> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Future<void> deleteCurrentUser();
  Stream<String?> authStateChanges(); // uid or null
}
