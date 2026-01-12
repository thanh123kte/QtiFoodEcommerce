import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../domain/usecases/chatbot/send_chatbot_message.dart';
import 'ai_chat_ui_state.dart';

class AiChatViewModel extends ChangeNotifier {
  final SendChatbotMessage _sendChatbotMessage;

  AiChatUiState _state = const AiChatInitial();
  final List<AiChatMessageViewData> _messages = [];
  String? _customerId;
  int _conversationId = 0;
  int _pendingRequests = 0;
  int _messageSeed = 0;

  AiChatViewModel(this._sendChatbotMessage);

  AiChatUiState get state => _state;

  void start(String customerId) {
    if (customerId.isEmpty) {
      _emit(const AiChatError('Khong tim thay tai khoan'));
      return;
    }
    _customerId = customerId;
    _conversationId = 0;
    _pendingRequests = 0;
    _messageSeed = 0;
    _messages.clear();
    _emitLoaded();
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final customerId = _customerId;
    if (customerId == null || customerId.isEmpty) {
      _emit(const AiChatError('Khong tim thay tai khoan'));
      return;
    }
    if (_state is! AiChatLoaded) {
      _emitLoaded();
    }

    _messages.add(
      AiChatMessageViewData(
        id: _nextId(),
        content: trimmed,
        isMine: true,
        createdAt: DateTime.now(),
      ),
    );
    _pendingRequests += 1;
    _emitLoaded();

    final result = await _sendChatbotMessage(
      customerId: customerId,
      text: trimmed,
      conversationId: _conversationId > 0 ? _conversationId : null,
    );

    _pendingRequests = max(0, _pendingRequests - 1);
    result.when(
      ok: (reply) {
        if (reply.conversationId > 0) {
          _conversationId = reply.conversationId;
        }
        if (reply.reply.isNotEmpty) {
          _messages.add(
            AiChatMessageViewData(
              id: _nextId(),
              content: reply.reply,
              isMine: false,
              createdAt: DateTime.now(),
            ),
          );
        }
        _emitLoaded();
      },
      err: (message) {
        _emitLoaded(eventMessage: message);
      },
    );
  }

  void consumeEvent() {
    final current = _state;
    if (current is AiChatLoaded && current.eventMessage != null) {
      _emitLoaded(eventMessage: null);
    }
  }

  void _emitLoaded({String? eventMessage}) {
    _emit(
      AiChatLoaded(
        conversationId: _conversationId,
        messages: List.unmodifiable(_messages),
        isSending: _pendingRequests > 0,
        eventMessage: eventMessage,
      ),
    );
  }

  int _nextId() {
    _messageSeed += 1;
    return _messageSeed;
  }

  void _emit(AiChatUiState state) {
    _state = state;
    notifyListeners();
  }
}
