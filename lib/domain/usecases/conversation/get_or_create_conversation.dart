import '../../../utils/result.dart';
import '../../entities/conversation.dart';
import '../../repositories/conversation_repository.dart';

class GetOrCreateConversation {
  final ConversationRepository repository;

  GetOrCreateConversation(this.repository);

  Future<Result<Conversation>> call({required String customerId, required String sellerId}) {
    return repository.getOrCreate(customerId: customerId, sellerId: sellerId);
  }
}
