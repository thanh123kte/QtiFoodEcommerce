import '../../domain/entities/conversation.dart';
import '../../domain/entities/user.dart';
import 'message_model.dart';
import 'user_model.dart';

class ConversationModel {
  final int id;
  final AppUserModel customer;
  final AppUserModel seller;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime? createdAt;
  final DateTime? lastMessageAt;

  ConversationModel({
    required this.id,
    required this.customer,
    required this.seller,
    required this.unreadCount,
    this.lastMessage,
    this.createdAt,
    this.lastMessageAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      customer: AppUserModel.fromJson(Map<String, dynamic>.from(json['customer'] ?? const {})),
      seller: AppUserModel.fromJson(Map<String, dynamic>.from(json['seller'] ?? const {})),
        lastMessage: json['lastMessage'] is Map
          ? MessageModel.fromJson(Map<String, dynamic>.from(json['lastMessage'] as Map))
          : null,
      unreadCount: json['unreadCount'] is int
          ? json['unreadCount'] as int
          : int.tryParse('${json['unreadCount']}') ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      lastMessageAt: json['lastMessageAt'] != null ? DateTime.tryParse(json['lastMessageAt'].toString()) : null,
    );
  }

  Conversation toEntity() => Conversation(
        id: id,
        customer: _toAppUser(customer),
        seller: _toAppUser(seller),
        lastMessage: lastMessage?.toEntity(),
        unreadCount: unreadCount,
        createdAt: createdAt,
        lastMessageAt: lastMessageAt,
      );

  AppUser _toAppUser(AppUserModel model) => AppUser(
        id: model.id,
        fullName: model.fullName,
        email: model.email,
        phone: model.phone,
        avatarUrl: model.avatarUrl,
        dateOfBirth: model.dateOfBirth,
        gender: model.gender,
        isActive: model.isActive,
        roles: model.roles,
      );
}
