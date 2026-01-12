import 'package:flutter/foundation.dart';

import '../../../../domain/entities/create_voucher_input.dart';
import '../../../../domain/entities/voucher.dart';
import '../../../../domain/usecases/voucher/create_voucher.dart';
import '../../../../domain/usecases/voucher/delete_voucher.dart';
import '../../../../domain/usecases/voucher/get_store_vouchers.dart';
import '../../../../domain/usecases/voucher/update_voucher.dart';
import '../../../../utils/result.dart';

class SellerVoucherViewData {
  final int id;
  final int storeId;
  final String code;
  final String title;
  final String? description;
  final VoucherDiscountType discountType;
  final double discountValue;
  final double? minOrderValue;
  final double? maxDiscount;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? usageLimit;
  final int? usageCount;
  final VoucherStatus status;
  final bool isActive;
  final bool isCreatedByAdmin;

  const SellerVoucherViewData({
    required this.id,
    required this.storeId,
    required this.code,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderValue,
    this.maxDiscount,
    this.startDate,
    this.endDate,
    this.usageLimit,
    this.usageCount,
    required this.status,
    required this.isActive,
    required this.isCreatedByAdmin,
  });

  factory SellerVoucherViewData.fromEntity(Voucher voucher) {
    return SellerVoucherViewData(
      id: voucher.id,
      storeId: voucher.storeId,
      code: voucher.code,
      title: voucher.title,
      description: voucher.description,
      discountType: voucher.discountType,
      discountValue: voucher.discountValue,
      minOrderValue: voucher.minOrderValue,
      maxDiscount: voucher.maxDiscount,
      startDate: voucher.startDate,
      endDate: voucher.endDate,
      usageLimit: voucher.usageLimit ?? 0,
      usageCount: voucher.usageCount ?? 0,
      status: voucher.status,
      isActive: voucher.isActive,
      isCreatedByAdmin: voucher.isCreatedByAdmin,
    );
  }
}

class VoucherFormData {
  final String code;
  final String title;
  final String? description;
  final VoucherDiscountType discountType;
  final double discountValue;
  final double? minOrderValue;
  final double? maxDiscount;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? usageLimit;
  final VoucherStatus status;
  final bool isActive;

  const VoucherFormData({
    required this.code,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderValue,
    this.maxDiscount,
    this.startDate,
    this.endDate,
    this.usageLimit,
    required this.status,
    required this.isActive,
  });
}

class SellerVouchersViewModel extends ChangeNotifier {
  final GetStoreVouchers _getVouchers;
  final CreateVoucher _createVoucher;
  final UpdateVoucher _updateVoucher;
  final DeleteVoucher _deleteVoucher;

  SellerVouchersViewModel(
    this._getVouchers,
    this._createVoucher,
    this._updateVoucher,
    this._deleteVoucher,
  );

  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;
  int? _storeId;
  String _query = '';
  List<SellerVoucherViewData> _items = const [];
  List<SellerVoucherViewData> _filtered = const [];

  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  List<SellerVoucherViewData> get vouchers => List.unmodifiable(_filtered);
  bool get hasData => _filtered.isNotEmpty;
  List<SellerVoucherViewData> get allVouchers => List.unmodifiable(_items);

  Future<void> load({required int storeId, bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    _storeId = storeId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getVouchers(storeId);
    result.when(
      ok: (items) {
        _items = items.map(SellerVoucherViewData.fromEntity).toList();
        _applyFilter();
        _error = null;
      },
      err: (message) {
        _items = const [];
        _filtered = const [];
        _error = message;
      },
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    final id = _storeId;
    if (id == null || id == 0) return;
    await load(storeId: id, refresh: true);
  }

  void search(String query) {
    _query = query;
    _applyFilter();
    notifyListeners();
  }

  Future<Result<SellerVoucherViewData>> createVoucher(VoucherFormData data) async {
    final storeId = _storeId;
    if (storeId == null || storeId == 0) {
      return const Err('Khong tim thay cua hang cho voucher.');
    }
    _isProcessing = true;
    notifyListeners();

    final input = CreateVoucherInput(
      storeId: storeId,
      code: data.code,
      title: data.title,
      description: data.description,
      discountType: data.discountType,
      discountValue: data.discountValue,
      minOrderValue: data.minOrderValue,
      maxDiscount: data.maxDiscount,
      startDate: data.startDate,
      endDate: data.endDate,
      usageLimit: data.usageLimit,
      status: data.status,
      isActive: data.isActive,
    );

    final result = await _createVoucher(input);
    return result.when(
      ok: (voucher) {
        final viewData = SellerVoucherViewData.fromEntity(voucher);
        _items = [viewData, ..._items];
        _applyFilter();
        _isProcessing = false;
        _error = null;
        notifyListeners();
        return Ok(viewData);
      },
      err: (message) {
        _isProcessing = false;
        _error = message;
        notifyListeners();
        return Err(message);
      },
    );
  }

  Future<Result<SellerVoucherViewData>> updateVoucher(int id, VoucherFormData data) async {
    final storeId = _storeId;
    if (storeId == null || storeId == 0) {
      return const Err('Khong tim thay cua hang cho voucher.');
    }
    _isProcessing = true;
    notifyListeners();

    final input = UpdateVoucherInput(
      storeId: storeId,
      code: data.code,
      title: data.title,
      description: data.description,
      discountType: data.discountType,
      discountValue: data.discountValue,
      minOrderValue: data.minOrderValue,
      maxDiscount: data.maxDiscount,
      startDate: data.startDate,
      endDate: data.endDate,
      usageLimit: data.usageLimit,
      status: data.status,
      isActive: data.isActive,
    );

    final result = await _updateVoucher(id, input);
    return result.when(
      ok: (voucher) {
        final updated = SellerVoucherViewData.fromEntity(voucher);
        _items = _items.map((item) => item.id == id ? updated : item).toList();
        _applyFilter();
        _isProcessing = false;
        _error = null;
        notifyListeners();
        return Ok(updated);
      },
      err: (message) {
        _isProcessing = false;
        _error = message;
        notifyListeners();
        return Err(message);
      },
    );
  }

  Future<Result<void>> deleteVoucher(int id) async {
    _isProcessing = true;
    notifyListeners();

    final result = await _deleteVoucher(id);
    return result.when(
      ok: (_) {
        _items = _items.where((item) => item.id != id).toList();
        _applyFilter();
        _isProcessing = false;
        _error = null;
        notifyListeners();
        return const Ok(null);
      },
      err: (message) {
        _isProcessing = false;
        _error = message;
        notifyListeners();
        return Err(message);
      },
    );
  }

  void _applyFilter() {
    if (_query.trim().isEmpty) {
      _filtered = List.unmodifiable(_items);
      return;
    }

    final needle = _query.trim().toLowerCase();
    _filtered = _items
        .where(
          (item) =>
              item.code.toLowerCase().contains(needle) ||
              item.title.toLowerCase().contains(needle) ||
              (item.description?.toLowerCase().contains(needle) ?? false),
        )
        .toList();
  }
}
