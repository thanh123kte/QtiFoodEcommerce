import '../../../utils/result.dart';
import '../../repositories/conversation_repository.dart';

class MarkConversationAsRead {
  final ConversationRepository repository;

  MarkConversationAsRead(this.repository);

  Future<Result<void>> call({required int conversationId, required String userId}) {
    return repository.markAsRead(conversationId: conversationId, userId: userId);
  }
}
