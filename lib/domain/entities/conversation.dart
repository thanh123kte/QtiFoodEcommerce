import 'message.dart';
import 'user.dart';

class Conversation {
  final int id;
  final AppUser customer;
  final AppUser seller;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime? createdAt;
  final DateTime? lastMessageAt;

  const Conversation({
    required this.id,
    required this.customer,
    required this.seller,
    required this.unreadCount,
    this.lastMessage,
    this.createdAt,
    this.lastMessageAt,
  });
}
