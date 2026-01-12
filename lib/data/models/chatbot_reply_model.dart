import '../../domain/entities/chatbot_reply.dart';

class ChatbotReplyModel {
  final int conversationId;
  final String botUserId;
  final String reply;
  final List<ChatbotToolTraceModel> toolTrace;

  ChatbotReplyModel({
    required this.conversationId,
    required this.botUserId,
    required this.reply,
    this.toolTrace = const [],
  });

  factory ChatbotReplyModel.fromJson(Map<String, dynamic> json) {
    final rawTrace = json['toolTrace'];
    final traces = rawTrace is List
        ? rawTrace
            .whereType<Map>()
            .map((item) => ChatbotToolTraceModel.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <ChatbotToolTraceModel>[];
    return ChatbotReplyModel(
      conversationId: json['conversationId'] is int
          ? json['conversationId'] as int
          : int.tryParse('${json['conversationId']}') ?? 0,
      botUserId: json['botUserId']?.toString() ?? '',
      reply: json['reply']?.toString() ?? '',
      toolTrace: traces,
    );
  }

  ChatbotReply toEntity() => ChatbotReply(
        conversationId: conversationId,
        botUserId: botUserId,
        reply: reply,
        toolTrace: toolTrace.map((trace) => trace.toEntity()).toList(),
      );
}

class ChatbotToolTraceModel {
  final String tool;
  final Map<String, dynamic> args;
  final int? count;

  ChatbotToolTraceModel({
    required this.tool,
    required this.args,
    this.count,
  });

  factory ChatbotToolTraceModel.fromJson(Map<String, dynamic> json) {
    final rawArgs = json['args'];
    return ChatbotToolTraceModel(
      tool: json['tool']?.toString() ?? '',
      args: rawArgs is Map ? Map<String, dynamic>.from(rawArgs) : const {},
      count: json['count'] is int ? json['count'] as int : int.tryParse('${json['count']}'),
    );
  }

  ChatbotToolTrace toEntity() => ChatbotToolTrace(
        tool: tool,
        args: args,
        count: count,
      );
}
