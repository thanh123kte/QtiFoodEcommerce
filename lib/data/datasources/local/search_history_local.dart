import 'package:hive_flutter/hive_flutter.dart';

import '../../models/search_history_model.dart';

class SearchHistoryLocal {
  static const String boxName = 'search_history';
  static const int _maxEntries = 20;

  final Box<Map<dynamic, dynamic>> box;

  SearchHistoryLocal(this.box);

  Future<List<SearchHistoryModel>> getHistory(String userId) async {
    final data = box.get(userId);
    if (data == null) return const [];
    final rawList = data['history'] as List<dynamic>? ?? [];
    return rawList
        .whereType<Map>()
        .map((map) => SearchHistoryModel.fromJson(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> saveHistory(String userId, List<SearchHistoryModel> history) async {
    await box.put(
      userId,
      {
        'history': history.take(_maxEntries).map((e) => e.toJson()).toList(),
      },
    );
  }

  Future<void> addEntry(String userId, SearchHistoryModel entry) async {
    final current = await getHistory(userId);
    final updated = <SearchHistoryModel>[
      entry,
      ...current.where((item) => item.keyword.toLowerCase() != entry.keyword.toLowerCase()),
    ];
    await saveHistory(userId, updated);
  }
}
