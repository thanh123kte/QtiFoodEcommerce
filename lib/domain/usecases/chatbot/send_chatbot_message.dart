import '../../../utils/result.dart';
import '../../entities/chatbot_reply.dart';
import '../../repositories/chatbot_repository.dart';

class SendChatbotMessage {
  final ChatbotRepository repository;

  SendChatbotMessage(this.repository);

  Future<Result<ChatbotReply>> call({
    required String customerId,
    required String text,
    int? conversationId,
  }) {
    return repository.sendMessage(
      customerId: customerId,
      text: text,
      conversationId: conversationId,
    );
  }
}
