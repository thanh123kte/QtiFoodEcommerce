import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/models/message_model.dart';
import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/conversation/get_messages.dart';
import '../../../domain/usecases/conversation/get_or_create_conversation.dart';
import '../../../domain/usecases/conversation/send_message.dart';
import '../../../domain/usecases/conversation/mark_conversation_as_read.dart';
import '../../../services/chat/chat_socket_service.dart';
import '../../../utils/result.dart';
import 'chat_ui_state.dart';

class ChatViewModel extends ChangeNotifier {
  final GetOrCreateConversation _getOrCreateConversation;
  final GetMessages _getMessages;
  final SendMessage _sendMessage;
  final MarkConversationAsRead _markAsRead;
  final ChatSocketService _socketService;

  ChatUiState _state = const ChatInitial();
  String? _currentUserId;
  StreamSubscription<Map<String, dynamic>>? _socketSub;
  final Map<int, ChatMessageViewData> _messageMap = {};

  ChatViewModel(
    this._getOrCreateConversation,
    this._getMessages,
    this._sendMessage,
    this._markAsRead,
    this._socketService,
  );

  ChatUiState get state => _state;

  Future<void> start({
    required String customerId,
    required String sellerId,
    String? counterpartName,
    String? counterpartAvatar,
    int? conversationId,
  }) async {
    if (customerId.isEmpty) {
      _emit(const ChatError('Khong tim thay tai khoan')); return;
    }
    if (sellerId.isEmpty && conversationId == null) {
      _emit(const ChatError('Khong tim thay nguoi ban')); return;
    }
    _currentUserId = customerId;
    _emit(const ChatLoading());

    final Result<Conversation> convResult = conversationId != null
        ? Ok(Conversation(
            id: conversationId,
            customer: AppUser(id: customerId, fullName: '', email: '', roles: const []),
            seller: AppUser(id: sellerId, fullName: '', email: '', roles: const []),
            unreadCount: 0,
          ))
        : await _getOrCreateConversation(customerId: customerId, sellerId: sellerId);

    return convResult.when(
      ok: (conv) async {
        final counterpart = _pickCounterpart(conv, customerId, fallbackName: counterpartName, fallbackAvatar: counterpartAvatar);
        await _loadMessages(
          conversationId: conv.id,
          counterpartName: counterpart.name,
          counterpartAvatar: counterpart.avatar,
          refreshing: false,
        );
        await _connectSocket(conv.id);
        // Mark conversation as read
        await _markAsRead(conversationId: conv.id, userId: customerId);
      },
      err: (message) {
        _emit(ChatError(message));
      },
    );
  }

  Future<void> refresh() async {
    final current = _state;
    if (current is ChatLoaded) {
      await _loadMessages(
        conversationId: current.conversationId,
        counterpartName: current.counterpartName,
        counterpartAvatar: current.counterpartAvatar,
        refreshing: true,
      );
    }
  }

  Future<void> send(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    final current = _state;
    if (current is! ChatLoaded) return;
    final senderId = _currentUserId;
    if (senderId == null) return;

    // Try WS first
    if (_socketService.isConnected) {
      await _socketService.send(
        conversationId: current.conversationId,
        body: {
          'conversationId': current.conversationId,
          'senderId': senderId,
          'content': trimmed,
          'messageType': 'TEXT',
        },
      );
    }

    // REST fallback or to ensure delivery confirmation
    final result = await _sendMessage(
      senderId: senderId,
      conversationId: current.conversationId,
      content: trimmed,
    );
    result.when(
      ok: (msg) {
        _appendMessage(msg);
      },
      err: (_) {
        // keep silent; UI already shows existing messages
      },
    );
  }

  Future<void> disposeSocket() async {
    await _socketSub?.cancel();
    _socketSub = null;
    await _socketService.disconnect();
  }

  @override
  void dispose() {
    disposeSocket();
    super.dispose();
  }

  Future<void> _loadMessages({
    required int conversationId,
    required String counterpartName,
    String? counterpartAvatar,
    required bool refreshing,
  }) async {
    if (refreshing) {
      final current = _state;
      if (current is ChatLoaded) {
        _emit(ChatRefreshing(
          conversationId: conversationId,
          messages: current.messages,
          counterpartName: counterpartName,
          counterpartAvatar: counterpartAvatar,
        ));
      }
    }

    final result = await _getMessages(conversationId);
    result.when(
      ok: (list) {
        _messageMap
          ..clear()
          ..addEntries(list.map((e) => MapEntry(e.id, _toView(e))));
        _emit(ChatLoaded(
          conversationId: conversationId,
          messages: _sortedMessages(),
          counterpartName: counterpartName,
          counterpartAvatar: counterpartAvatar,
        ));
      },
      err: (message) => _emit(ChatError(message)),
    );
  }

  Future<void> _connectSocket(int conversationId) async {
    await _socketService.connect(conversationId: conversationId);
    _socketSub = _socketService.stream?.listen(
      (data) {
        final message = MessageModel.fromJson(Map<String, dynamic>.from(data)).toEntity();
        _appendMessage(message);
      },
      onError: (_) async {
        await refresh();
      },
    );
  }

  void _appendMessage(Message message) {
    _messageMap[message.id] = _toView(message);
    final current = _state;
    if (current is ChatLoaded) {
      _emit(ChatLoaded(
        conversationId: current.conversationId,
        messages: _sortedMessages(),
        counterpartName: current.counterpartName,
        counterpartAvatar: current.counterpartAvatar,
      ));
    }
  }

  ChatMessageViewData _toView(Message message) {
    final uid = _currentUserId;
    final sender = message.sender;
    final isMine = uid != null && sender.id == uid;
    final content = message.content;
    return ChatMessageViewData(
      id: message.id,
      content: content,
      senderName: sender.fullName.isNotEmpty ? sender.fullName : sender.email,
      senderId: sender.id,
      avatarUrl: sender.avatarUrl,
      isMine: isMine,
      createdAt: message.createdAt,
      messageType: message.messageType,
    );
  }

  _Counterpart _pickCounterpart(
    Conversation conversation,
    String userId, {
    String? fallbackName,
    String? fallbackAvatar,
  }) {
    final isCustomer = conversation.customer.id == userId;
    final other = isCustomer ? conversation.seller : conversation.customer;
    return _Counterpart(
      name: (other.fullName.isNotEmpty ? other.fullName : other.email).isNotEmpty
          ? (other.fullName.isNotEmpty ? other.fullName : other.email)
          : (fallbackName ?? 'Lien he'),
      avatar: other.avatarUrl?.isNotEmpty == true ? other.avatarUrl : fallbackAvatar,
    );
  }

  List<ChatMessageViewData> _sortedMessages() {
    final list = _messageMap.values.toList();
    list.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aTime.compareTo(bTime);
    });
    return List.unmodifiable(list);
  }

  void _emit(ChatUiState state) {
    _state = state;
    notifyListeners();
  }
}

class _Counterpart {
  final String name;
  final String? avatar;
  _Counterpart({required this.name, this.avatar});
}
