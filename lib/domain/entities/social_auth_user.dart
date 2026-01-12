class SocialAuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const SocialAuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });
}
