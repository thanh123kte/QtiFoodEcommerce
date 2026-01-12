class ChatbotReply {
  final int conversationId;
  final String botUserId;
  final String reply;
  final List<ChatbotToolTrace> toolTrace;

  const ChatbotReply({
    required this.conversationId,
    required this.botUserId,
    required this.reply,
    this.toolTrace = const [],
  });
}

class ChatbotToolTrace {
  final String tool;
  final Map<String, dynamic> args;
  final int? count;

  const ChatbotToolTrace({
    required this.tool,
    required this.args,
    this.count,
  });
}
