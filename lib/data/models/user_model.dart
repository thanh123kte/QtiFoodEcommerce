import '../../domain/entities/user.dart';

class AppUserModel {
  final String id;               // Firebase UID
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final bool? isActive;
  final List<String> roles;

  AppUserModel({
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

  AppUserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? gender,
    bool? isActive,
    List<String>? roles,
  }) {
    return AppUserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      isActive: isActive ?? this.isActive,
      roles: roles ?? this.roles,
    );
  }

  factory AppUserModel.fromJson(Map<String, dynamic> json) => AppUserModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
        gender: json['gender'] as String?,
        isActive: json['isActive'] as bool?,
        roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );

  Map<String, dynamic> toCreateDto({required String rawPassword}) => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': rawPassword,
        'avatarUrl': avatarUrl,
        'dateOfBirth': dateOfBirth?.toIso8601String().split('T').first,
        'gender': gender,
        'isActive': isActive ?? true,
        'roles': roles,
      };

  Map<String, dynamic> toUpdateDto() {
    final map = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String().split('T').first,
      'gender': gender,
      'isActive': isActive ?? true,
      'roles': roles,
    };
    map.removeWhere((_, value) => value == null);
    return map;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'gender': gender,
        'isActive': isActive,
        'roles': roles,
      };

  AppUser toEntity() => AppUser(
        id: id,
        fullName: fullName,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
        dateOfBirth: dateOfBirth,
        gender: gender,
        isActive: isActive,
        roles: roles,
      );
}
