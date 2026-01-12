import '../../../utils/result.dart';
import '../../entities/message.dart';
import '../../repositories/conversation_repository.dart';

class GetMessages {
  final ConversationRepository repository;

  GetMessages(this.repository);

  Future<Result<List<Message>>> call(int conversationId) {
    return repository.getMessages(conversationId);
  }
}
