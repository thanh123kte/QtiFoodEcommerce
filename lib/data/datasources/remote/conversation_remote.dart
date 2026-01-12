import 'package:dio/dio.dart';

class ConversationRemote {
  final Dio dio;

  ConversationRemote(this.dio);

  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    final response = await dio.get(
      '/api/conversations',
      queryParameters: {'userId': userId},
    );

    final data = response.data;
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<Map<String, dynamic>> getOrCreate({required String customerId, required String sellerId}) async {
    final response = await dio.post(
      '/api/conversations/get-or-create',
      queryParameters: {
        'customerId': customerId,
        'sellerId': sellerId,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    final response = await dio.get('/api/chat/conversations/$conversationId/messages');
    final data = response.data;
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<Map<String, dynamic>> sendMessage({
    required String senderId,
    required int conversationId,
    required String content,
    String messageType = 'TEXT',
  }) async {
    final response = await dio.post(
      '/api/chat/messages',
      queryParameters: {'senderId': senderId},
      data: {
        'conversationId': conversationId,
        'content': content,
        'messageType': messageType,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  Future<void> markAsRead({required int conversationId, required String userId}) async {
    await dio.post(
      '/api/conversations/$conversationId/mark-read',
      queryParameters: {'userId': userId},
    );
  }
}
