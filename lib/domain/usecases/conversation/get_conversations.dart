import '../../../utils/result.dart';
import '../../entities/conversation.dart';
import '../../repositories/conversation_repository.dart';

class GetConversations {
  final ConversationRepository repository;

  GetConversations(this.repository);

  Future<Result<List<Conversation>>> call(String userId) {
    return repository.getConversations(userId);
  }
}
