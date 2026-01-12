import 'package:dio/dio.dart';

import '../../domain/entities/search_history.dart';
import '../../domain/repositories/search_history_repository.dart';
import '../../utils/result.dart';
import '../datasources/local/search_history_local.dart';
import '../datasources/remote/search_history_remote.dart';
import '../models/search_history_model.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  final SearchHistoryRemote remote;
  final SearchHistoryLocal local;

  SearchHistoryRepositoryImpl(this.remote, this.local);

  @override
  Future<Result<List<SearchHistory>>> getHistory(String userId, {int limit = 5}) async {
    List<SearchHistoryModel> cached = const [];
    try {
      cached = await local.getHistory(userId);
    } catch (_) {
      cached = const [];
    }

    try {
      final json = await remote.getHistory(userId, limit: limit);
      final models = json.map(SearchHistoryModel.fromJson).toList()
        ..sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
      await local.saveHistory(userId, models);
      return Ok(models.take(limit).toList());
    } on DioException catch (e) {
      if (cached.isNotEmpty) {
        return Ok(cached);
      }
      return Err(_readMessage(e));
    } catch (e) {
      if (cached.isNotEmpty) {
        return Ok(cached);
      }
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> saveHistory(String userId, String keyword) async {
    final normalized = keyword.trim();
    if (normalized.isEmpty) {
      return const Ok(null);
    }
    final entry = SearchHistoryModel(keyword: normalized, searchedAt: DateTime.now());
    try {
      await remote.addHistory(userId, normalized);
      await local.addEntry(userId, entry);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(_readMessage(e));
    } catch (e) {
      return Err(e.toString());
    }
  }

  String _readMessage(DioException exception) {
    return exception.response?.data?.toString() ?? exception.message ?? 'API error';
  }
}
