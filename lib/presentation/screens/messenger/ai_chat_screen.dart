import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'ai_chat_ui_state.dart';
import 'ai_chat_view_model.dart';

const _aiPrimary = Color(0xFFFF8A3D);
const _aiPrimaryDark = Color(0xFFC45A1E);
const _aiAccent = Color(0xFFFFB56B);
const _aiBgTop = Color(0xFFFFF6ED);
const _aiBgBottom = Color(0xFFFFF3E8);
const _aiBubbleMine = Color(0xFFFF8A3D);
const _aiBubbleBot = Colors.white;
const _aiBubbleBorder = Color(0xFFFFE3CF);

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late final FirebaseAuth _auth = GetIt.I<FirebaseAuth>();
  late final AiChatViewModel _viewModel = GetIt.I<AiChatViewModel>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _customerId = '';
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _customerId = _auth.currentUser?.uid ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.start(_customerId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AiChatViewModel>(
        builder: (context, vm, __) {
          final state = vm.state;
          if (state is AiChatLoaded && state.eventMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.eventMessage!)),
              );
              vm.consumeEvent();
            });
          }
          if (state is AiChatLoaded) {
            _maybeScroll(state);
          }
          return Scaffold(
            backgroundColor: _aiBgBottom,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(92),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_aiPrimary, _aiAccent],
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
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: Text(
                            'AI',
                            style: TextStyle(
                              color: _aiPrimaryDark,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Trợ lý QTIBot',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Hỏi đáp món ngon, cửa hàng và đơn hàng',
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
                  isSending: state is AiChatLoaded && state.isSending,
                  onSend: _handleSend,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(AiChatUiState state, AiChatViewModel vm) {
    if (state is AiChatLoading || state is AiChatInitial) {
      return const Center(child: CircularProgressIndicator(color: _aiPrimary));
    }
    if (state is AiChatError) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.start(_customerId),
              style: ElevatedButton.styleFrom(backgroundColor: _aiPrimary),
              child: const Text('Thu lai'),
            ),
          ],
        ),
      );
    }

    final messages = switch (state) {
      AiChatLoaded(:final messages) => messages,
      _ => const <AiChatMessageViewData>[],
    };

    if (messages.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        children: [
          Icon(Icons.auto_awesome, size: 72, color: _aiPrimary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'Hãy bắt đầu trò chuyện với QTIBot!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _aiPrimaryDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ví dụ: Tìm quán phở ngon gần tôi\nGợi ý món ăn hôm nay\nTheo dõi đơn hàng của tôi',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      itemCount: messages.length + ((state is AiChatLoaded && state.isSending) ? 1 : 0),
      itemBuilder: (context, index) {
        if (state is AiChatLoaded && state.isSending && index == messages.length) {
          return const _TypingIndicator();
        }
        final message = messages[index];
        return _MessageBubble(message: message);
      },
    );
  }

  void _handleSend() {
    final text = _controller.text;
    _controller.clear();
    _viewModel.send(text);
  }

  void _maybeScroll(AiChatLoaded state) {
    if (state.messages.length == _lastMessageCount) return;
    _lastMessageCount = state.messages.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }
}

class _MessageBubble extends StatelessWidget {
  final AiChatMessageViewData message;

  const _MessageBubble({required this.message});

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
              color: _aiBubbleMine,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Text(
              message.content,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
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
          backgroundColor: _aiPrimary,
          child: const Text(
            'QTIBot',
            style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _aiBubbleBot,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _aiBubbleBorder),
                boxShadow: const [
                  BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Text(
                message.content,
                style: const TextStyle(color: Color(0xFF2D3A35), fontSize: 15, height: 1.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: const BoxDecoration(
          color: _aiBgTop,
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
                  hintText: 'Nhập tin nhắn...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _aiBubbleBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _aiBubbleBorder),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: _aiPrimary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: IconButton(
                onPressed: onSend,
                icon: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _aiPrimary,
            child: const Text(
              'QTIBot',
              style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _aiBubbleBot,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _aiBubbleBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _Dot(),
                SizedBox(width: 4),
                _Dot(delay: 120),
                SizedBox(width: 4),
                _Dot(delay: 240),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({this.delay = 0});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _animation = Tween<double>(begin: 0.3, end: 1)
      .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeInOut)));

  @override
  void initState() {
    super.initState();
    if (widget.delay == 0) {
      _controller.repeat();
    } else {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.repeat();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: _aiPrimary, shape: BoxShape.circle),
          ),
        );
      },
    );
  }
}
