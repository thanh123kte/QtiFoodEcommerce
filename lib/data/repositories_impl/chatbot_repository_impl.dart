import 'package:dio/dio.dart';

import '../../domain/entities/chatbot_reply.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../../utils/result.dart';
import '../datasources/remote/chatbot_remote.dart';
import '../models/chatbot_reply_model.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemote remote;

  ChatbotRepositoryImpl(this.remote);

  @override
  Future<Result<ChatbotReply>> sendMessage({
    required String customerId,
    required String text,
    int? conversationId,
  }) async {
    if (customerId.isEmpty || text.trim().isEmpty) {
      return const Err('Thieu thong tin gui tin nhan');
    }
    try {
      final json = await remote.sendMessage(
        customerId: customerId,
        text: text,
        conversationId: conversationId,
      );
      final entity = ChatbotReplyModel.fromJson(json).toEntity();
      return Ok(entity);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }
}
