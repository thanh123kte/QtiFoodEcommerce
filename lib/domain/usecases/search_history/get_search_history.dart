import '../../entities/search_history.dart';
import '../../repositories/search_history_repository.dart';
import '../../../utils/result.dart';

class GetSearchHistory {
  final SearchHistoryRepository repository;

  GetSearchHistory(this.repository);

  Future<Result<List<SearchHistory>>> call(String userId, {int limit = 5}) {
    return repository.getHistory(userId, limit: limit);
  }
}
