class AiChatMessageViewData {
  final int id;
  final String content;
  final bool isMine;
  final DateTime createdAt;

  const AiChatMessageViewData({
    required this.id,
    required this.content,
    required this.isMine,
    required this.createdAt,
  });
}

sealed class AiChatUiState {
  const AiChatUiState();
}

class AiChatInitial extends AiChatUiState {
  const AiChatInitial();
}

class AiChatLoading extends AiChatUiState {
  const AiChatLoading();
}

class AiChatLoaded extends AiChatUiState {
  final int conversationId;
  final List<AiChatMessageViewData> messages;
  final bool isSending;
  final String? eventMessage;

  const AiChatLoaded({
    required this.conversationId,
    required this.messages,
    this.isSending = false,
    this.eventMessage,
  });

  AiChatLoaded copyWith({
    int? conversationId,
    List<AiChatMessageViewData>? messages,
    bool? isSending,
    String? eventMessage,
  }) {
    return AiChatLoaded(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      eventMessage: eventMessage,
    );
  }
}

class AiChatError extends AiChatUiState {
  final String message;

  const AiChatError(this.message);
}
