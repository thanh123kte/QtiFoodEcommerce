import '../../utils/result.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ConversationRepository {
  Future<Result<List<Conversation>>> getConversations(String userId);
  Future<Result<Conversation>> getOrCreate({required String customerId, required String sellerId});
  Future<Result<List<Message>>> getMessages(int conversationId);
  Future<Result<Message>> sendMessage({
    required String senderId,
    required int conversationId,
    required String content,
    String messageType = 'TEXT',
  });
  Future<Result<void>> markAsRead({required int conversationId, required String userId});
}
