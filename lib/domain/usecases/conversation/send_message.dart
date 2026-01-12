import '../../../utils/result.dart';
import '../../entities/message.dart';
import '../../repositories/conversation_repository.dart';

class SendMessage {
  final ConversationRepository repository;

  SendMessage(this.repository);

  Future<Result<Message>> call({
    required String senderId,
    required int conversationId,
    required String content,
    String messageType = 'TEXT',
  }) {
    return repository.sendMessage(
      senderId: senderId,
      conversationId: conversationId,
      content: content,
      messageType: messageType,
    );
  }
}
