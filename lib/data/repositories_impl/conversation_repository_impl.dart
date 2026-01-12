import 'package:dio/dio.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../utils/result.dart';
import '../datasources/remote/conversation_remote.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationRemote remote;

  ConversationRepositoryImpl(this.remote);

  @override
  Future<Result<List<Conversation>>> getConversations(String userId) async {
    if (userId.isEmpty) {
      return const Err('Khong tim thay tai khoan');
    }

    try {
      final list = await remote.getConversations(userId);
      final conversations = list
          .map((json) => ConversationModel.fromJson(Map<String, dynamic>.from(json)))
          .map((model) => model.toEntity())
          .toList();
      return Ok(conversations);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Conversation>> getOrCreate({required String customerId, required String sellerId}) async {
    if (customerId.isEmpty || sellerId.isEmpty) {
      return const Err('Thieu thong tin tai khoan');
    }
    try {
      final json = await remote.getOrCreate(customerId: customerId, sellerId: sellerId);
      final entity = ConversationModel.fromJson(Map<String, dynamic>.from(json)).toEntity();
      return Ok(entity);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<List<Message>>> getMessages(int conversationId) async {
    try {
      final list = await remote.getMessages(conversationId);
      final messages = list
          .map((json) => MessageModel.fromJson(Map<String, dynamic>.from(json)))
          .map((model) => model.toEntity())
          .toList();
      return Ok(messages);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<Message>> sendMessage({
    required String senderId,
    required int conversationId,
    required String content,
    String messageType = 'TEXT',
  }) async {
    if (senderId.isEmpty || content.trim().isEmpty) {
      return const Err('Thieu noi dung hoac nguoi gui');
    }
    try {
      final json = await remote.sendMessage(
        senderId: senderId,
        conversationId: conversationId,
        content: content,
        messageType: messageType,
      );
      final entity = MessageModel.fromJson(Map<String, dynamic>.from(json)).toEntity();
      return Ok(entity);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<void>> markAsRead({required int conversationId, required String userId}) async {
    if (userId.isEmpty) {
      return const Err('Khong tim thay tai khoan');
    }
    try {
      await remote.markAsRead(conversationId: conversationId, userId: userId);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(e.response?.data?.toString() ?? e.message ?? 'API error');
    } catch (e) {
      return Err(e.toString());
    }
  }
}
