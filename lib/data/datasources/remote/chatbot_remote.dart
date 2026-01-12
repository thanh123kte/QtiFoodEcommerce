import 'package:dio/dio.dart';

class ChatbotRemote {
  final Dio dio;

  ChatbotRemote(this.dio);

  Future<Map<String, dynamic>> sendMessage({
    required String customerId,
    required String text,
    int? conversationId,
  }) async {
    final payload = <String, dynamic>{
      'customerId': customerId,
      'text': text,
    };
    if (conversationId != null && conversationId > 0) {
      payload['conversationId'] = conversationId;
    }

    final response = await dio.post('/api/chatbot/message', data: payload);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}
