import '../../utils/result.dart';
import '../entities/search_history.dart';

abstract class SearchHistoryRepository {
  Future<Result<List<SearchHistory>>> getHistory(String userId, {int limit = 5});

  Future<Result<void>> saveHistory(String userId, String keyword);
}
