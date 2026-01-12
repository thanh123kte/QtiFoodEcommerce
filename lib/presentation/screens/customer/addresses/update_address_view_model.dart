import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/update_address_input.dart';
import '../../../../domain/entities/delete_address_input.dart';
import '../../../../domain/usecases/address/delete_address.dart';
import '../../../../domain/usecases/address/search_address_suggestions.dart';
import '../../../../domain/usecases/address/update_address.dart';
import '../../../../utils/result.dart';
import 'add_address_ui_state.dart';

class UpdateAddressViewModel extends ChangeNotifier {
  final UpdateAddress _updateAddress;
  final SearchAddressSuggestions _searchAddressSuggestions;
  final DeleteAddress _deleteAddress;

  AddAddressSubmissionStatus _submissionStatus = AddAddressSubmissionStatus.idle;
  bool _isSuggestionLoading = false;
  bool _isDeleting = false;
  String? _submissionError;
  String? _suggestionError;
  List<PlaceSuggestionViewData> _suggestions = const [];
  PlaceSuggestionViewData? _selectedSuggestion;
  Timer? _suggestionDebounce;
  bool _isDefault = false;
  String? _addressId;

  UpdateAddressViewModel(
    this._updateAddress,
    this._searchAddressSuggestions,
    this._deleteAddress,
  );

  AddAddressSubmissionStatus get submissionStatus => _submissionStatus;
  bool get isSubmitting => _submissionStatus == AddAddressSubmissionStatus.submitting;
  bool get isSuccess => _submissionStatus == AddAddressSubmissionStatus.success;
  bool get isSuggestionLoading => _isSuggestionLoading;
  bool get isDeleting => _isDeleting;
  String? get submissionError => _submissionError;
  String? get suggestionError => _suggestionError;
  List<PlaceSuggestionViewData> get suggestions => _suggestions;
  PlaceSuggestionViewData? get selectedSuggestion => _selectedSuggestion;
  bool get isDefault => _isDefault;

  void setInitialData({
    required String addressId,
    required bool isDefault,
  }) {
    _addressId = addressId;
    _isDefault = isDefault;
  }

  @override
  void dispose() {
    _suggestionDebounce?.cancel();
    super.dispose();
  }

  void setDefault(bool value) {
    if (_isDefault == value) return;
    _isDefault = value;
    notifyListeners();
  }

  void resetSubmissionStatus() {
    if (_submissionStatus != AddAddressSubmissionStatus.idle) {
      _submissionStatus = AddAddressSubmissionStatus.idle;
      _submissionError = null;
      notifyListeners();
    }
  }

  void clearSuggestionError() {
    if (_suggestionError != null) {
      _suggestionError = null;
      notifyListeners();
    }
  }

  void selectSuggestion(PlaceSuggestionViewData suggestion) {
    _selectedSuggestion = suggestion;
    _suggestionError = null;
    notifyListeners();
  }

  void clearSelectedSuggestion() {
    if (_selectedSuggestion != null) {
      _selectedSuggestion = null;
      notifyListeners();
    }
  }

  Future<Result<Address>> submit(UpdateAddressInput input) async {
    final id = _addressId ?? input.id;
    if (id.isEmpty) {
      return Err('Address ID is missing');
    }
    if (_isDeleting) {
      return Err('Delete request is already in progress');
    }
    if (isSubmitting) {
      return Err('Another request is still processing');
    }

    _submissionStatus = AddAddressSubmissionStatus.submitting;
    _submissionError = null;
    notifyListeners();

    final result = await _updateAddress(
      UpdateAddressInput(
        id: id,
        receiver: input.receiver,
        phone: input.phone,
        address: input.address,
        latitude: input.latitude,
        longitude: input.longitude,
        isDefault: _isDefault,
      ),
    );

    result.when(
      ok: (_) {
        _submissionStatus = AddAddressSubmissionStatus.success;
        _submissionError = null;
      },
      err: (message) {
        _submissionStatus = AddAddressSubmissionStatus.failure;
        _submissionError = message;
      },
    );

    notifyListeners();
    return result;
  }

  Future<Result<bool>> delete() async {
    final id = _addressId;

    if (id == null || id.isEmpty) {
      return Err('Address information is incomplete');
    }
    if (_isDeleting) {
      return Err('Delete request is already in progress');
    }

    _isDeleting = true;
    _submissionError = null;
    notifyListeners();

    final result = await _deleteAddress(
      DeleteAddressInput(id: id),
    );

    result.when(
      ok: (_) => _submissionError = null,
      err: (message) => _submissionError = message,
    );

    _isDeleting = false;
    notifyListeners();

    return result;
  }

  void searchSuggestions(
    String query, {
    double? latitude,
    double? longitude,
    int limit = 5,
    Duration debounce = const Duration(milliseconds: 350),
  }) {
    _suggestionDebounce?.cancel();

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _suggestions = const [];
      _suggestionError = null;
      _isSuggestionLoading = false;
      notifyListeners();
      return;
    }

    _suggestionDebounce = Timer(debounce, () {
      _fetchSuggestions(
        trimmed,
        latitude: latitude,
        longitude: longitude,
        limit: limit,
      );
    });
  }

  Future<List<PlaceSuggestionViewData>> loadSuggestions(
    String query, {
    double? latitude,
    double? longitude,
    int limit = 5,
  }) async {
    // Hủy debounce đang chờ (nếu trước đó có dùng searchSuggestions)
    _suggestionDebounce?.cancel();

    if (query.trim().isEmpty) {
      _suggestions = const [];
      _suggestionError = null;
      _isSuggestionLoading = false;
      notifyListeners();
      return const [];
    }

    return await _fetchSuggestions(
      query,
      latitude: latitude,
      longitude: longitude,
      limit: limit,
    );
  }

  Future<List<PlaceSuggestionViewData>> _fetchSuggestions(
    String query, {
    double? latitude,
    double? longitude,
    int limit = 5,
  }) async {
    _isSuggestionLoading = true;
    _suggestionError = null;
    notifyListeners();

    final result = await _searchAddressSuggestions(
      query,
      latitude: latitude,
      longitude: longitude,
      limit: limit,
    );

    List<PlaceSuggestionViewData> mapped = const [];
    result.when(
      ok: (values) {
        mapped = values
            .map(
              (s) => PlaceSuggestionViewData(
                id: s.id,
                title: s.title,
                address: s.address,
                latitude: s.latitude,
                longitude: s.longitude,
              ),
            )
            .toList();
        _suggestions = mapped;
        _suggestionError = null;
      },
      err: (message) {
        _suggestionError = message;
        _suggestions = const [];
        mapped = const [];
      },
    );

    _isSuggestionLoading = false;
    notifyListeners();
    return mapped;
  }
  
}
