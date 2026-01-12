import '../../domain/entities/message.dart';
import '../../domain/entities/user.dart';
import 'user_model.dart';

class MessageModel {
  final int id;
  final int conversationId;
  final AppUserModel sender;
  final String content;
  final String messageType;
  final DateTime? createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.messageType,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      conversationId: json['conversationId'] is int
          ? json['conversationId'] as int
          : int.tryParse('${json['conversationId']}') ?? 0,
      sender: AppUserModel.fromJson(Map<String, dynamic>.from(json['sender'] ?? const {})),
      content: json['content']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? 'TEXT',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Message toEntity() => Message(
        id: id,
        conversationId: conversationId,
        sender: _toAppUser(sender),
        content: content,
        messageType: messageType,
        createdAt: createdAt,
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
