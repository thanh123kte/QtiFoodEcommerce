import 'package:flutter/foundation.dart';

import '../../../../domain/entities/update_store_input.dart';
import '../../../../domain/usecases/store/update_store.dart';
import '../../../../domain/usecases/store/upload_store_image.dart';
import '../../../../utils/result.dart';
import 'seller_profile_overview_state.dart';

class SellerStoreInfoViewModel extends ChangeNotifier {
  final UpdateStore _updateStore;
  final UploadStoreImage _uploadStoreImage;

  SellerStoreInfoViewModel(this._updateStore, this._uploadStoreImage);

  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _error;

  bool get isSaving => _isSaving;
  bool get isUploadingAvatar => _isUploadingAvatar;
  String? get error => _error;

  Future<Result<SellerProfileViewData>> updateStoreInfo({
    required int storeId,
    required UpdateStoreInput input,
  }) async {
    if (_isSaving) {
      return const Err('Dang xu ly yeu cau khac');
    }

    _isSaving = true;
    notifyListeners();

    final result = await _updateStore(storeId, input);
    final mapped = result.when<Result<SellerProfileViewData>>(
      ok: (store) {
        _error = null;
        return Ok(SellerProfileViewData.fromStore(store));
      },
      err: (message) {
        _error = message;
        return Err(message);
      },
    );

    _isSaving = false;
    notifyListeners();
    return mapped;
  }

  Future<Result<String>> uploadAvatar(int storeId, String imagePath) async {
    if (_isUploadingAvatar) {
      return const Err('Dang tai anh len');
    }

    _isUploadingAvatar = true;
    notifyListeners();

    final result = await _uploadStoreImage(storeId, imagePath);
    result.when(
      ok: (_) => _error = null,
      err: (message) => _error = message,
    );

    _isUploadingAvatar = false;
    notifyListeners();
    return result;
  }
}
