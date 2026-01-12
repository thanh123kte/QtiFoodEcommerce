import '../../utils/result.dart';
import '../entities/chatbot_reply.dart';

abstract class ChatbotRepository {
  Future<Result<ChatbotReply>> sendMessage({
    required String customerId,
    required String text,
    int? conversationId,
  });
}
