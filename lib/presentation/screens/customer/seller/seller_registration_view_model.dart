import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../domain/entities/create_store_input.dart';
import '../../../../domain/entities/store.dart';
import '../../../../domain/usecases/address/search_address_suggestions.dart';
import '../../../../domain/usecases/store/create_store.dart';
import '../../../../domain/usecases/store/get_store_by_owner.dart';
import '../../../../utils/result.dart';
import '../addresses/add_address_ui_state.dart';

class SellerRegistrationViewModel extends ChangeNotifier {
  final CreateStore _createStore;
  final GetStoreByOwner _getStoreByOwner;
  final SearchAddressSuggestions _searchAddressSuggestions;

  bool _isSubmitting = false;
  bool _isLoadingStore = false;
  bool _isSuggestionLoading = false;
  String? _submissionError;
  String? _loadStoreError;
  String? _suggestionError;
  Store? _store;

  List<PlaceSuggestionViewData> _suggestions = const [];
  PlaceSuggestionViewData? _selectedSuggestion;
  Timer? _suggestionDebounce;

  SellerRegistrationViewModel(
    this._createStore,
    this._getStoreByOwner,
    this._searchAddressSuggestions,
  );

  bool get isSubmitting => _isSubmitting;
  bool get isLoadingStore => _isLoadingStore;
  bool get isSuggestionLoading => _isSuggestionLoading;
  String? get submissionError => _submissionError;
  String? get loadStoreError => _loadStoreError;
  String? get suggestionError => _suggestionError;
  Store? get store => _store;
  bool get hasPendingStore {
    final status = (_store?.status ?? '').toUpperCase();
    return status == 'PENDING';
  }
  String get storeStatus => _store?.status ?? '';
  List<PlaceSuggestionViewData> get suggestions => _suggestions;
  PlaceSuggestionViewData? get selectedSuggestion => _selectedSuggestion;

  @override
  void dispose() {
    _suggestionDebounce?.cancel();
    super.dispose();
  }

  void clearStore() {
    if (_store != null) {
      _store = null;
      notifyListeners();
    }
  }

  Future<void> loadStore(String ownerId) async {
    if (ownerId.isEmpty) return;
    _isLoadingStore = true;
    _loadStoreError = null;
    notifyListeners();
    print("Loading store for ownerId: $ownerId");

    final result = await _getStoreByOwner(ownerId);
    result.when(
      ok: (store) {
        _store = store;
        _loadStoreError = null;
      },
      err: (message) {
        if (_isMissingStore(message)) {
          _store = null;
          _loadStoreError = null;
        } else {
          _loadStoreError = message;
        }
      },
    );

    _isLoadingStore = false;
    notifyListeners();
  }

  bool _isMissingStore(String message) {
    final lower = message.toLowerCase();
    return lower.contains('404') || lower.contains('not found') || lower.contains('khong tim thay');
  }

  void clearSuggestionError() {
    if (_suggestionError != null) {
      _suggestionError = null;
      notifyListeners();
    }
  }

  void clearSubmissionError() {
    if (_submissionError != null) {
      _submissionError = null;
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

  Future<Result<Store>> submit(CreateStoreInput input) async {
    if (_isSubmitting) {
      return Err('A request is already processing');
    }
    _isSubmitting = true;
    _submissionError = null;
    notifyListeners();

    final result = await _createStore(input);
    result.when(
      ok: (store) {
        _store = store;
        _submissionError = null;
      },
      err: (message) {
        _submissionError = message;
      },
    );

    _isSubmitting = false;
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
    _suggestionDebounce?.cancel();

    if (query.trim().isEmpty) {
      _suggestions = const [];
      _suggestionError = null;
      _isSuggestionLoading = false;
      notifyListeners();
      return const [];
    }

    return _fetchSuggestions(
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
