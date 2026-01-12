import 'user.dart';

class Message {
  final int id;
  final int conversationId;
  final AppUser sender;
  final String content;
  final String messageType;
  final DateTime? createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.messageType,
    this.createdAt,
  });
}
