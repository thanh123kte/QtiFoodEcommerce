import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'chat_ui_state.dart';
import 'chat_view_model.dart';

const _chatPrimary = Color(0xFFFF8A3D);
const _chatPrimaryDark = Color(0xFFC45A1E);
const _chatAccent = Color(0xFFFFB56B);
const _chatBgTop = Color(0xFFFFF6ED);
const _chatBgBottom = Color(0xFFFFF3E8);
const _chatBubbleMine = Color(0xFFFF8A3D);
const _chatBubbleBot = Colors.white;
const _chatBubbleBorder = Color(0xFFFFE3CF);

class ChatScreen extends StatefulWidget {
  final String sellerId;
  final String? storeName;
  final String? counterpartAvatar;
  final int? conversationId;

  const ChatScreen({
    super.key,
    required this.sellerId,
    this.storeName,
    this.counterpartAvatar,
    this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final FirebaseAuth _auth = GetIt.I<FirebaseAuth>();
  late final ChatViewModel _viewModel = GetIt.I<ChatViewModel>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = _auth.currentUser?.uid ?? '';
      _viewModel.start(
        customerId: uid,
        sellerId: widget.sellerId,
        counterpartName: widget.storeName,
        counterpartAvatar: widget.counterpartAvatar,
        conversationId: widget.conversationId,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _viewModel.disposeSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ChatViewModel>(
        builder: (_, vm, __) {
          final state = vm.state;
          if (state is ChatLoaded) {
            _maybeScroll(state);
          }
          return Scaffold(
            backgroundColor: _chatBgBottom,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(92),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_chatPrimary, _chatAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 14, 16, 16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Text(
                            (widget.storeName ?? 'CH').trim().isNotEmpty
                                ? (widget.storeName ?? 'CH').trim().substring(0, 1).toUpperCase()
                                : 'CH',
                            style: const TextStyle(
                              color: _chatPrimaryDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.storeName ?? 'Tin nhan',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Ho tro don hang va san pham',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(child: _buildBody(state, vm)),
                _MessageInput(
                  controller: _controller,
                  onSend: () {
                    final text = _controller.text;
                    _controller.clear();
                    vm.send(text);
                    _scrollToBottom();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ChatUiState state, ChatViewModel vm) {
    if (state is ChatLoading || state is ChatInitial) {
      return const Center(child: CircularProgressIndicator(color: _chatPrimary));
    }
    if (state is ChatError) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: vm.refresh,
              style: ElevatedButton.styleFrom(backgroundColor: _chatPrimary),
              child: const Text('Thu lai'),
            ),
          ],
        ),
      );
    }

    final items = switch (state) {
      ChatLoaded(:final messages) => messages,
      ChatRefreshing(:final messages) => messages,
      _ => <ChatMessageViewData>[],
    };

    return RefreshIndicator(
      onRefresh: vm.refresh,
      color: _chatPrimary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _MessageBubble(
            message: item,
            timeLabel: item.createdAt != null ? _formatTime(item.createdAt!) : null,
          );
        },
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _maybeScroll(ChatLoaded state) {
    if (state.messages.length == _lastMessageCount) return;
    _lastMessageCount = state.messages.length;
    _scrollToBottom();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.day == time.day && now.month == time.month && now.year == time.year) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    final d = time.day.toString().padLeft(2, '0');
    final mo = time.month.toString().padLeft(2, '0');
    return '$d/$mo';
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: const BoxDecoration(
          color: _chatBgTop,
          boxShadow: [
            BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, -2)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Nhap tin nhan...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _chatBubbleBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _chatBubbleBorder),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: _chatPrimary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageViewData message;
  final String? timeLabel;

  const _MessageBubble({
    required this.message,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.74;
    if (message.isMine) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _chatBubbleMine,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                ),
                if (timeLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      timeLabel!,
                      style: const TextStyle(fontSize: 11, color: Color(0xFFFFF3E8)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: _chatPrimary,
          child: const Icon(Icons.store, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _chatBubbleBot,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _chatBubbleBorder),
                boxShadow: const [
                  BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: const TextStyle(color: Color(0xFF2D3A35), fontSize: 15, height: 1.4),
                  ),
                  if (timeLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        timeLabel!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF9C8A7B)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
