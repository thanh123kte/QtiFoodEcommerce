class ConversationViewData {
	final int id;
	final String title;
	final String? subtitle;
	final String? avatarUrl;
	final DateTime? lastMessageTime;
	final int unreadCount;
	final String sellerId;
	final String? storeName;

	const ConversationViewData({
		required this.id,
		required this.title,
		required this.sellerId,
		this.subtitle,
		this.avatarUrl,
		this.lastMessageTime,
		this.unreadCount = 0,
		this.storeName,
	});

	ConversationViewData copyWith({
		String? storeName,
	}) {
		return ConversationViewData(
			id: id,
			title: title,
			sellerId: sellerId,
			subtitle: subtitle,
			avatarUrl: avatarUrl,
			lastMessageTime: lastMessageTime,
			unreadCount: unreadCount,
			storeName: storeName ?? this.storeName,
		);
	}
}

sealed class MessengerUiState {
	const MessengerUiState();
}

class MessengerInitial extends MessengerUiState {
	const MessengerInitial();
}

class MessengerLoading extends MessengerUiState {
	const MessengerLoading();
}

class MessengerRefreshing extends MessengerUiState {
	final List<ConversationViewData> items;

	const MessengerRefreshing(this.items);
}

class MessengerLoaded extends MessengerUiState {
	final List<ConversationViewData> items;

	const MessengerLoaded(this.items);
}

class MessengerError extends MessengerUiState {
	final String message;

	const MessengerError(this.message);
}

