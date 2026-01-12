import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'messenger_ui_state.dart';
import 'messenger_view_model.dart';

// Theme colors
const _primaryOrange = Color(0xFFFF8A3D);
const _lightOrange = Color(0xFFFFF6ED);
const _softOrange = Color(0xFFFFE3CF);
const _borderOrange = Color(0xFFFFE8D9);
const _textDark = Color(0xFF2D3142);
const _textMuted = Color(0xFF6B6B7A);

class MessengerScreen extends StatefulWidget {
	const MessengerScreen({super.key});

	@override
	State<MessengerScreen> createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> {
	late final FirebaseAuth _auth = GetIt.I<FirebaseAuth>();
	late final MessengerViewModel _viewModel = GetIt.I<MessengerViewModel>();

	@override
	void initState() {
		super.initState();
		final uid = _auth.currentUser?.uid ?? '';
		WidgetsBinding.instance.addPostFrameCallback((_) {
			_viewModel.load(uid);
		});
	}

	@override
	void dispose() {
		_viewModel.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return ChangeNotifierProvider.value(
			value: _viewModel,
			child: Consumer<MessengerViewModel>(
				builder: (_, vm, __) {
					final state = vm.state;
					return Scaffold(
						backgroundColor: _lightOrange,
						appBar: PreferredSize(
							preferredSize: const Size.fromHeight(96),
							child: Container(
								decoration: const BoxDecoration(
									gradient: LinearGradient(
										colors: [Color(0xFFFF7A30), Color(0xFFFFA852)],
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
										padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
										child: Row(
											children: [
												const SizedBox(width: 12),
												Expanded(
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														mainAxisAlignment: MainAxisAlignment.center,
														children: [
															Text(
																'Hỗ trợ',
																style: Theme.of(context).textTheme.titleMedium?.copyWith(
																	fontWeight: FontWeight.w800,
																	color: Colors.white,
																),
															),
															const Text(
																'Liên hệ với cửa hàng của bạn',
																style: TextStyle(
																	color: Colors.white,
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
						body: RefreshIndicator(
							color: _primaryOrange,
							onRefresh: vm.refresh,
							child: _buildBody(state, vm),
						),
						floatingActionButton: FloatingActionButton(
							backgroundColor: Colors.white,
							foregroundColor: _primaryOrange,
							elevation: 4,
							onPressed: () => context.push('/messenger/ai'),
							child: const Text(
								'AI',
								style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.6),
							),
						),
						floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
					);
				},
			),
		);
	}

	Widget _buildBody(MessengerUiState state, MessengerViewModel vm) {
		if (state is MessengerLoading || state is MessengerInitial) {
			return ListView(
				physics: const AlwaysScrollableScrollPhysics(),
				children: const [
					SizedBox(
						height: 300,
						child: Center(
							child: CircularProgressIndicator(color: _primaryOrange),
						),
					),
				],
			);
		}

		if (state is MessengerError) {
			return ListView(
				physics: const AlwaysScrollableScrollPhysics(),
				padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
				children: [
					Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
					const SizedBox(height: 16),
					Text(
						state.message,
						textAlign: TextAlign.center,
						style: TextStyle(
							fontSize: 16,
							fontWeight: FontWeight.w500,
							color: _textMuted,
						),
					),
					const SizedBox(height: 24),
					ElevatedButton(
						onPressed: vm.retry,
						style: ElevatedButton.styleFrom(
							backgroundColor: _primaryOrange,
							foregroundColor: Colors.white,
							padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(12),
							),
						),
						child: const Text('Thử lại'),
					),
				],
			);
		}

		final items = switch (state) {
			MessengerLoaded(:final items) => items,
			MessengerRefreshing(:final items) => items,
			_ => <ConversationViewData>[],
		};

		if (items.isEmpty) {
			return ListView(
				physics: const AlwaysScrollableScrollPhysics(),
				children: [
					const SizedBox(height: 100),
					Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
					const SizedBox(height: 16),
					Text(
						'Chưa có cuộc trò chuyện nào',
						textAlign: TextAlign.center,
						style: TextStyle(
							fontSize: 16,
							color: _textMuted,
							fontWeight: FontWeight.w500,
						),
					),
					const SizedBox(height: 8),
					Text(
						'Hãy bắt đầu trò chuyện với cửa hàng',
						textAlign: TextAlign.center,
						style: TextStyle(fontSize: 14, color: Colors.grey[500]),
					),
				],
			);
		}

		return Column(
			children: [
				if (state is MessengerRefreshing)
					const LinearProgressIndicator(
						minHeight: 3,
						backgroundColor: _softOrange,
						color: _primaryOrange,
					),
				Expanded(
					child: ListView.separated(
						physics: const AlwaysScrollableScrollPhysics(),
						padding: const EdgeInsets.all(16),
						itemCount: items.length,
						separatorBuilder: (_, __) => const SizedBox(height: 12),
						itemBuilder: (_, index) {
							final item = items[index];
							return _ConversationTile(
								item: item,
								onReturn: vm.refresh,
							);
						},
					),
				),
			],
		);
	}
}

class _ConversationTile extends StatelessWidget {
	final ConversationViewData item;
	final VoidCallback? onReturn;

	const _ConversationTile({required this.item, this.onReturn});

	@override
	Widget build(BuildContext context) {
		final timeLabel = _formatTime(item.lastMessageTime);
		final hasUnread = item.unreadCount > 0;

		return Container(
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(16),
				border: Border.all(color: _borderOrange, width: 1),
				boxShadow: [
					BoxShadow(
						color: _primaryOrange.withOpacity(0.08),
						blurRadius: 8,
						offset: const Offset(0, 2),
					),
				],
			),
			child: Material(
				color: Colors.transparent,
				child: InkWell(
					borderRadius: BorderRadius.circular(16),
					onTap: () async {
						await context.push(
							'/messenger/chat',
							extra: {
								'sellerId': item.sellerId,
								'storeName': item.storeName ?? item.title,
								'avatar': item.avatarUrl,
								'conversationId': item.id,
							},
						);
						// Reload when returning from chat
						onReturn?.call();
					},
					child: Padding(
						padding: const EdgeInsets.all(14),
						child: Row(
							children: [
								_Avatar(url: item.avatarUrl, hasUnread: hasUnread),
								const SizedBox(width: 14),
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Row(
												children: [
													Expanded(
														child: Text(
															item.storeName ?? item.title,
															style: const TextStyle(
																fontSize: 16,
																fontWeight: FontWeight.w700,
																color: _textDark,
																letterSpacing: 0.2,
															),
															maxLines: 1,
															overflow: TextOverflow.ellipsis,
														),
													),
													if (timeLabel != null) ...[
														const SizedBox(width: 8),
														Text(
															timeLabel,
															style: TextStyle(
																fontSize: 12,
																color: hasUnread ? _primaryOrange : _textMuted,
																fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
															),
														),
													],
												],
											),
											const SizedBox(height: 6),
											Row(
												crossAxisAlignment: CrossAxisAlignment.center,
												children: [
													Expanded(
														child: Text(
															item.subtitle ?? 'Bạn có tin nhắn mới',
															style: TextStyle(
																fontSize: 14,
																color: hasUnread ? _textDark : _textMuted,
																fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
																height: 1.3,
															),
															maxLines: 2,
															overflow: TextOverflow.ellipsis,
														),
													),
													if (hasUnread) ...[
														const SizedBox(width: 12),
														Container(
															padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
															decoration: BoxDecoration(
																gradient: const LinearGradient(
																	colors: [_primaryOrange, Color(0xFFFF6B1A)],
																),
																borderRadius: BorderRadius.circular(20),
																boxShadow: [
																	BoxShadow(
																		color: _primaryOrange.withOpacity(0.3),
																		blurRadius: 6,
																		offset: const Offset(0, 2),
																	),
																],
															),
															child: Text(
																'${item.unreadCount}',
																style: const TextStyle(
																	color: Colors.white,
																	fontWeight: FontWeight.w700,
																	fontSize: 12,
																),
															),
														),
													],
												],
											),
										],
									),
								),
							],
						),
					),
				),
			),
		);
	}

	String? _formatTime(DateTime? time) {
		if (time == null) return null;
		final now = DateTime.now();
		final difference = now.difference(time);

		if (difference.inDays == 0) {
			return DateFormat('HH:mm').format(time);
		}
		if (difference.inDays == 1) {
			return 'Hom qua';
		}
		return DateFormat('dd/MM').format(time);
	}
}

class _Avatar extends StatelessWidget {
	final String? url;
	final bool hasUnread;

	const _Avatar({this.url, this.hasUnread = false});

	@override
	Widget build(BuildContext context) {
		return Stack(
			children: [
				Container(
					width: 56,
					height: 56,
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(16),
						border: Border.all(
							color: hasUnread ? _primaryOrange : _borderOrange,
							width: 2,
						),
						boxShadow: hasUnread
								? [
										BoxShadow(
											color: _primaryOrange.withOpacity(0.2),
											blurRadius: 8,
											offset: const Offset(0, 2),
										),
									]
								: null,
					),
					child: ClipRRect(
						borderRadius: BorderRadius.circular(14),
						child: url != null && url!.isNotEmpty
								? Image.network(
										url!,
										width: 56,
										height: 56,
										fit: BoxFit.cover,
										errorBuilder: (_, __, ___) => _placeholder(),
									)
								: _placeholder(),
					),
				),
				if (hasUnread)
					Positioned(
						top: 0,
						right: 0,
						child: Container(
							width: 14,
							height: 14,
							decoration: BoxDecoration(
								color: _primaryOrange,
								shape: BoxShape.circle,
								border: Border.all(color: Colors.white, width: 2),
							),
						),
					),
			],
		);
	}

	Widget _placeholder() {
		return Container(
			color: _lightOrange,
			child: const Icon(
				Icons.store_rounded,
				color: _primaryOrange,
				size: 28,
			),
		);
	}
}

