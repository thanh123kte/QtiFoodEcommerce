class AddressViewData {
  final String id;
  final String userId;
  final String receiver;
  final String phone;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AddressViewData({
    required this.id,
    required this.userId,
    required this.receiver,
    required this.phone,
    required this.address,
    this.latitude,
    this.longitude,
    required this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  String get fullAddress => address;
}

sealed class AddressesUiState {
  const AddressesUiState();
}

class AddressesInitial extends AddressesUiState {
  const AddressesInitial();
}

class AddressesLoading extends AddressesUiState {
  const AddressesLoading();
}

class AddressesRefreshing extends AddressesUiState {
  final List<AddressViewData> addresses;

  const AddressesRefreshing(this.addresses);
}

class AddressesLoaded extends AddressesUiState {
  final List<AddressViewData> addresses;

  const AddressesLoaded(this.addresses);
}

class AddressesError extends AddressesUiState {
  final String message;

  const AddressesError(this.message);
}
