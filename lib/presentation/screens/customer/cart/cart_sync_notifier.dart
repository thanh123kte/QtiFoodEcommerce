import 'package:flutter/foundation.dart';

class CartSyncNotifier extends ChangeNotifier {
  final Set<String> _dirtyCustomerIds = <String>{};

  void markDirty(String customerId) {
    if (_dirtyCustomerIds.add(customerId)) {
      notifyListeners();
    }
  }

  bool takeIfDirty(String customerId) {
    if (_dirtyCustomerIds.contains(customerId)) {
      _dirtyCustomerIds.remove(customerId);
      return true;
    }
    return false;
  }
}
