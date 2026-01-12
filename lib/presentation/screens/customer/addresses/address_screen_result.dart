import 'addresses_ui_state.dart';

class AddressScreenResult {
  final AddressViewData? address;
  final String? deletedId;

  const AddressScreenResult._({
    this.address,
    this.deletedId,
  });

  bool get isDeleted => deletedId != null;

  static AddressScreenResult updated(AddressViewData address) {
    return AddressScreenResult._(address: address);
  }

  static AddressScreenResult deleted(String addressId) {
    return AddressScreenResult._(deletedId: addressId);
  }
}

