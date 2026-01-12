import '../../domain/entities/search_history.dart';

class SearchHistoryModel extends SearchHistory {
  SearchHistoryModel({
    required String keyword,
    required DateTime searchedAt,
  }) : super(keyword: keyword, searchedAt: searchedAt);

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['searchedAt'] ?? json['createdAt'];
    DateTime parsedDate;
    if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }
    return SearchHistoryModel(
      keyword: (json['keyword'] ?? json['searchKeyword'] ?? json['term'] ?? json['key'] ?? '')
          .toString(),
      searchedAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'searchedAt': searchedAt.toIso8601String(),
    };
  }
}
