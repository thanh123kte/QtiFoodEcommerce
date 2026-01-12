class ChatMessageViewData {
  final int id;
  final String content;
  final String senderName;
  final String senderId;
  final String? avatarUrl;
  final bool isMine;
  final DateTime? createdAt;
  final String messageType;

  const ChatMessageViewData({
    required this.id,
    required this.content,
    required this.senderName,
    required this.senderId,
    required this.isMine,
    required this.messageType,
    this.avatarUrl,
    this.createdAt,
  });
}

sealed class ChatUiState {
  const ChatUiState();
}

class ChatInitial extends ChatUiState {
  const ChatInitial();
}

class ChatLoading extends ChatUiState {
  const ChatLoading();
}

class ChatLoaded extends ChatUiState {
  final int conversationId;
  final List<ChatMessageViewData> messages;
  final String counterpartName;
  final String? counterpartAvatar;

  const ChatLoaded({
    required this.conversationId,
    required this.messages,
    required this.counterpartName,
    this.counterpartAvatar,
  });
}

class ChatRefreshing extends ChatUiState {
  final int conversationId;
  final List<ChatMessageViewData> messages;
  final String counterpartName;
  final String? counterpartAvatar;

  const ChatRefreshing({
    required this.conversationId,
    required this.messages,
    required this.counterpartName,
    this.counterpartAvatar,
  });
}

class ChatError extends ChatUiState {
  final String message;
  const ChatError(this.message);
}
