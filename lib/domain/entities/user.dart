// lib/domain/entities/user.dart
class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final bool? isActive;
  final List<String> roles;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.isActive,
    this.roles = const [],
  });
}
