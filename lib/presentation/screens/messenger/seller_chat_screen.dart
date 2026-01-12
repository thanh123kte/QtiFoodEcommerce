import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'chat_ui_state.dart';
import 'chat_view_model.dart';

class SellerChatScreen extends StatefulWidget {
  final int conversationId;
  final String? counterpartName;
  final String? counterpartAvatar;

  const SellerChatScreen({
    super.key,
    required this.conversationId,
    this.counterpartName,
    this.counterpartAvatar,
  });

  @override
  State<SellerChatScreen> createState() => _SellerChatScreenState();
}

class _SellerChatScreenState extends State<SellerChatScreen> {
  late final FirebaseAuth _auth = GetIt.I<FirebaseAuth>();
  late final ChatViewModel _viewModel = GetIt.I<ChatViewModel>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = _auth.currentUser?.uid ?? '';
      _viewModel.start(
        customerId: uid,
        sellerId: uid,
        counterpartName: widget.counterpartName,
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
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.counterpartName ?? 'Tin nhan'),
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
      return const Center(child: CircularProgressIndicator());
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
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Align(
            alignment: item.isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: item.isMine ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.content,
                      style: const TextStyle(fontSize: 15),
                    ),
                    if (item.createdAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _formatTime(item.createdAt!),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Nhap tin nhan',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
