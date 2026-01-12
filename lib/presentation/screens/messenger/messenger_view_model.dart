import 'package:flutter/material.dart';

import '../../../domain/entities/conversation.dart';
import '../../../domain/usecases/conversation/get_conversations.dart';
import '../../../domain/usecases/store/get_store_by_owner.dart';
import 'messenger_ui_state.dart';

class MessengerViewModel extends ChangeNotifier {
	final GetConversations _getConversations;
	final GetStoreByOwner _getStoreByOwner;

	MessengerUiState _state = const MessengerInitial();
	String? _userId;

	MessengerViewModel(this._getConversations, this._getStoreByOwner);

	MessengerUiState get state => _state;

	bool get isLoading => _state is MessengerLoading || _state is MessengerRefreshing;

	Future<void> load(String userId, {bool forceRefresh = false}) async {
		if (userId.isEmpty) {
			_emit(const MessengerError('Khong tim thay tai khoan')); // cannot proceed
			return;
		}

		_userId = userId;

		final current = _currentItems;
		if (forceRefresh && current != null) {
			_emit(MessengerRefreshing(current));
		} else if (!forceRefresh) {
			_emit(const MessengerLoading());
		}

	final result = await _getConversations(userId);
	result.when(
		ok: (items) async {
			final mapped = items.map(_mapToView).toList();
			_emit(MessengerLoaded(mapped));
			await _loadStoreNames(mapped);
		},
		err: (message) {
			_emit(MessengerError(message));
		},
	);
}	Future<void> refresh() async {
		final id = _userId;
		if (id == null) return;
		await load(id, forceRefresh: true);
	}

	Future<void> retry() async {
		final id = _userId;
		if (id == null) return;
		await load(id);
	}

	ConversationViewData _mapToView(Conversation conversation) {
		final currentId = _userId;
		final counterpart = currentId != null && conversation.customer.id == currentId
				? conversation.seller
				: conversation.customer;
		final title = counterpart.fullName.isNotEmpty ? counterpart.fullName : counterpart.email;
		final subtitle = conversation.lastMessage?.content;
		final subtitleText = subtitle?.trim();
		final lastTime = conversation.lastMessage?.createdAt ?? conversation.lastMessageAt ?? conversation.createdAt;

		return ConversationViewData(
			id: conversation.id,
			title: title,
			sellerId: conversation.seller.id,
			subtitle: subtitleText?.isNotEmpty == true ? subtitleText : null,
			avatarUrl: _cleanUrl(counterpart.avatarUrl),
			lastMessageTime: lastTime,
			unreadCount: conversation.unreadCount,
		);
	}

	void _emit(MessengerUiState state) {
		if (identical(_state, state)) return;
		_state = state;
		notifyListeners();
	}

	List<ConversationViewData>? get _currentItems {
		final current = _state;
		if (current is MessengerLoaded) return current.items;
		if (current is MessengerRefreshing) return current.items;
		return null;
	}

	Future<void> _loadStoreNames(List<ConversationViewData> items) async {
		for (int i = 0; i < items.length; i++) {
			final item = items[i];
			final result = await _getStoreByOwner(item.sellerId);
			result.when(
				ok: (store) {
					if (store != null && store.name.isNotEmpty) {
						items[i] = item.copyWith(storeName: store.name);
					}
				},
				err: (_) {},
			);
		}
		notifyListeners();
	}

	String? _cleanUrl(String? url) {
		final trimmed = url?.trim();
		if (trimmed == null || trimmed.isEmpty) return null;
		return trimmed;
	}
}

