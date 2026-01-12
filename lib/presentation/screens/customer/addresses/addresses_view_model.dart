import 'package:flutter/foundation.dart';

import '../../../../domain/entities/address.dart';
import '../../../../domain/usecases/address/get_addresses.dart';
import 'addresses_ui_state.dart';

class AddressesViewModel extends ChangeNotifier {
  final GetAddresses getAddresses;

  AddressesViewModel(this.getAddresses);

  AddressesUiState _uiState = const AddressesInitial();
  AddressesUiState get uiState => _uiState;

  String? _userId;

  bool get isLoading => _uiState is AddressesLoading || _uiState is AddressesRefreshing;

  void _emit(AddressesUiState state) {
    if (identical(_uiState, state)) return;
    _uiState = state;
    notifyListeners();
  }

  Future<void> loadAddresses(String userId) async {
    if (userId.isEmpty) {
      _emit(const AddressesError('Khong tim thay nguoi dung'));
      return;
    }
    _userId = userId;

    if (isLoading) return;
    _emit(const AddressesLoading());

    final result = await getAddresses(userId);
    result.when(
      ok: (addresses) => _emit(AddressesLoaded(addresses.map(_map).toList())),
      err: (message) => _emit(AddressesError(message)),
    );
  }

  Future<void> refresh() async {
    final id = _userId;
    if (id == null) return;

    final current = switch (_uiState) {
      AddressesLoaded(:final addresses) => addresses,
      AddressesRefreshing(:final addresses) => addresses,
      _ => const <AddressViewData>[],
    };
    if (current.isNotEmpty) {
      _emit(AddressesRefreshing(current));
    } else {
      _emit(const AddressesLoading());
    }

    final result = await getAddresses(id, forceRefresh: true);
    result.when(
      ok: (addresses) => _emit(AddressesLoaded(addresses.map(_map).toList())),
      err: (message) => _emit(AddressesError(message)),
    );
  }

  AddressViewData _map(Address address) {
    return AddressViewData(
      id: address.id,
      userId: address.userId,
      receiver: address.receiver,
      phone: address.phone,
      address: address.address,
      latitude: address.latitude,
      longitude: address.longitude,
      isDefault: address.isDefault,
      createdAt: address.createdAt,
      updatedAt: address.updatedAt,
    );
  }

  void upsertAddress(AddressViewData address) {
    final current = switch (_uiState) {
      AddressesLoaded(:final addresses) => addresses,
      AddressesRefreshing(:final addresses) => addresses,
      _ => const <AddressViewData>[],
    };

    final updated = <AddressViewData>[
      address,
      ...current.where((item) => item.id != address.id),
    ];

    _emit(AddressesLoaded(updated));
  }

  void removeAddress(String addressId) {
    final current = switch (_uiState) {
      AddressesLoaded(:final addresses) => addresses,
      AddressesRefreshing(:final addresses) => addresses,
      _ => const <AddressViewData>[],
    };

    final updated = current.where((item) => item.id != addressId).toList();
    _emit(AddressesLoaded(updated));
  }
}
