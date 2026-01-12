import '../../repositories/search_history_repository.dart';
import '../../../utils/result.dart';

class SaveSearchHistory {
  final SearchHistoryRepository repository;

  SaveSearchHistory(this.repository);

  Future<Result<void>> call({
    required String userId,
    required String keyword,
  }) {
    return repository.saveHistory(userId, keyword);
  }
}
