import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/create_address_input.dart';
import '../../../../domain/usecases/address/create_address.dart';
import '../../../../domain/usecases/address/search_address_suggestions.dart';
import '../../../../utils/result.dart';
import 'add_address_ui_state.dart';

class AddAddressViewModel extends ChangeNotifier {
  final CreateAddress _createAddress;
  final SearchAddressSuggestions _searchAddressSuggestions;

  AddAddressSubmissionStatus _submissionStatus = AddAddressSubmissionStatus.idle;
  bool _isSuggestionLoading = false;
  String? _submissionError;
  String? _suggestionError;
  List<PlaceSuggestionViewData> _suggestions = const [];
  PlaceSuggestionViewData? _selectedSuggestion;
  Timer? _suggestionDebounce;

  AddAddressViewModel(
    this._createAddress,
    this._searchAddressSuggestions,
  );

  AddAddressSubmissionStatus get submissionStatus => _submissionStatus;
  bool get isSubmitting => _submissionStatus == AddAddressSubmissionStatus.submitting;
  bool get isSuccess => _submissionStatus == AddAddressSubmissionStatus.success;

  bool get isSuggestionLoading => _isSuggestionLoading;
  String? get submissionError => _submissionError;
  String? get suggestionError => _suggestionError;
  List<PlaceSuggestionViewData> get suggestions => _suggestions;
  PlaceSuggestionViewData? get selectedSuggestion => _selectedSuggestion;

  @override
  void dispose() {
    _suggestionDebounce?.cancel();
    super.dispose();
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

  Future<Result<Address>> submit(CreateAddressInput input) async {
    if (isSubmitting) {
      return Err('Another request is still processing');
    }

    _submissionStatus = AddAddressSubmissionStatus.submitting;
    _submissionError = null;
    notifyListeners();

    final result = await _createAddress(input);
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

  /// ====== API cũ: dùng debounce nội bộ (KHÔNG dùng cho TypeAheadField) ======
  void searchSuggestions(
    String query, {
    double? latitude,
    double? longitude,
    int limit = 5,
    Duration debounce = const Duration(milliseconds: 350),
  }) {
    _suggestionDebounce?.cancel();

    if (query.trim().isEmpty) {
      _suggestions = const [];
      _suggestionError = null;
      _isSuggestionLoading = false;
      notifyListeners();
      return;
    }

    _suggestionDebounce = Timer(debounce, () {
      _fetchSuggestions(
        query,
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


