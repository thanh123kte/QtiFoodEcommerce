import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/voucher.dart';
import '../../../../utils/currency_formatter.dart';
import '../../../../utils/form_utils.dart';
import '../../../../utils/result.dart';
import '../products/widgets/product_theme.dart';
import 'seller_vouchers_view_model.dart';
import 'widgets/voucher_card.dart';
import 'widgets/voucher_empty_state.dart';
import 'widgets/voucher_filter_row.dart';
import 'widgets/voucher_search_bar.dart';
import 'widgets/voucher_stats_section.dart';
import 'widgets/voucher_utils.dart';

class SellerVouchersScreen extends StatefulWidget {
  final int storeId;
  final String? storeName;

  const SellerVouchersScreen({
    super.key,
    required this.storeId,
    this.storeName,
  });

  @override
  State<SellerVouchersScreen> createState() => _SellerVouchersScreenState();
}

class _SellerVouchersScreenState extends State<SellerVouchersScreen> {
  late final SellerVouchersViewModel _viewModel = GetIt.I<SellerVouchersViewModel>();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.load(storeId: widget.storeId);
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearch)
      ..dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleSearch() {
    _viewModel.search(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SellerVouchersViewModel>.value(
      value: _viewModel,
      child: Consumer<SellerVouchersViewModel>(
        builder: (_, vm, __) {
          return Scaffold(
            backgroundColor: sellerBackground,
            appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            title: const Text('Voucher cửa hàng'),
            actions: [
              IconButton(
                tooltip: 'Làm mới',
                icon: const Icon(Icons.refresh, color: sellerAccent),
                  onPressed: vm.isLoading ? null : vm.refresh,
                ),
                IconButton(
                  tooltip: 'Tạo voucher',
                  icon: const Icon(Icons.add, color: sellerAccent),
                  onPressed: vm.isProcessing ? null : () => _openVoucherForm(vm),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: sellerAccent,
              foregroundColor: Colors.white,
              onPressed: vm.isProcessing ? null : () => _openVoucherForm(vm),
              icon: const Icon(Icons.add),
              label: const Text('Thêm voucher'),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  if (vm.isProcessing) const LinearProgressIndicator(minHeight: 3, color: sellerAccent),
                  Expanded(child: _buildBody(vm)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(SellerVouchersViewModel vm) {
    if (vm.isLoading && !vm.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final allVouchers = vm.allVouchers;
    final visibleVouchers = _applyStatusFilter(vm.vouchers);
    final hasSearchText = _searchController.text.trim().isNotEmpty;

    return Column(
      children: [
        VoucherStatsSection(vouchers: allVouchers),
        VoucherSearchBar(
          controller: _searchController,
          onChanged: (value) {
            vm.search(value);
            setState(() {});
          },
          onClear: () {
            _searchController.clear();
            vm.search('');
            setState(() {});
          },
        ),
        VoucherFilterRow(
          selectedFilter: _selectedFilter,
          onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
        ),
        if (vm.error != null && !vm.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sellerAccentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: sellerAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vm.error!,
                      style: const TextStyle(color: sellerAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const Divider(height: 1),
        Expanded(
          child: RefreshIndicator(
            color: sellerAccent,
            onRefresh: vm.refresh,
            child: visibleVouchers.isEmpty
                ? VoucherEmptyState(
                    hasSearch: hasSearchText,
                    isProcessing: vm.isProcessing,
                    onCreate: () => _openVoucherForm(vm),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    itemCount: visibleVouchers.length,
                    itemBuilder: (_, index) {
                      final voucher = visibleVouchers[index];
                      return VoucherCard(
                        voucher: voucher,
                        onEdit: () => _openVoucherForm(vm, initial: voucher),
                        onDelete: () => _confirmDelete(vm, voucher),
                        onDetails: () => _showVoucherDetails(voucher),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  void _showVoucherDetails(SellerVoucherViewData voucher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Chi tiết voucher ${voucher.code}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Mã voucher', voucher.code),
              _detailRow('Tiêu đề', voucher.title),
              _detailRow('Loại giảm', voucherDiscountDescription(voucher)),
              _detailRow('Giảm tối đa', voucher.maxDiscount == null ? 'Không giới hạn' : formatCurrency(voucher.maxDiscount!)),
              _detailRow('Đơn tối thiểu', voucher.minOrderValue == null ? 'Không yêu cầu' : formatCurrency(voucher.minOrderValue!)),
              _detailRow('Giới hạn sử dụng', '${voucher.usageLimit ?? 0}'),
              _detailRow('Đã sử dụng', '${voucher.usageCount ?? 0}'),
              _detailRow('Trạng thái', voucherStatusLabel(resolveVoucherStatus(voucher))),
              _detailRow('Thời gian', voucherDateRangeText(voucher.startDate, voucher.endDate)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  List<SellerVoucherViewData> _applyStatusFilter(List<SellerVoucherViewData> items) {
    final status = _statusFromFilter(_selectedFilter);
    if (status == null) return items;
    return items.where((voucher) => resolveVoucherStatus(voucher) == status).toList();
  }

  VoucherStatus? _statusFromFilter(String label) {
    switch (label) {
      case 'Hoat dong':
        return VoucherStatus.active;
      case 'Het han':
        return VoucherStatus.expired;
      case 'Tam ngung':
        return VoucherStatus.inactive;
      default:
        return null;
    }
  }

  Future<void> _openVoucherForm(SellerVouchersViewModel vm, {SellerVoucherViewData? initial}) async {
    final result = await showModalBottomSheet<VoucherFormData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _VoucherFormSheet(initial: initial),
    );
    if (result == null) return;

    final response = initial == null ? await vm.createVoucher(result) : await vm.updateVoucher(initial.id, result);

    if (!mounted) return;
    if (response is Ok) {
      await vm.refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(initial == null ? 'Tạo voucher thành công' : 'Cập nhật voucher'),
        ),
      );
    } else if (response is Err) {
      final message = (response as Err).message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _confirmDelete(SellerVouchersViewModel vm, SellerVoucherViewData voucher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa voucher'),
        content: Text('Bạn có chắc muốn xóa mã ${voucher.code}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final result = await vm.deleteVoucher(voucher.id);
    result.when(
      ok: (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Da xoa voucher'))),
      err: (message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))),
    );
  }
}

class _VoucherFormSheet extends StatefulWidget {
  final SellerVoucherViewData? initial;

  const _VoucherFormSheet({this.initial});

  @override
  State<_VoucherFormSheet> createState() => _VoucherFormSheetState();
}

class _VoucherFormSheetState extends State<_VoucherFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late VoucherDiscountType _discountType = widget.initial?.discountType ?? VoucherDiscountType.percentage;
  late VoucherStatus _status;
  late bool _isActive;

  late final TextEditingController _codeCtrl = TextEditingController(text: widget.initial?.code ?? '');
  late final TextEditingController _titleCtrl = TextEditingController(text: widget.initial?.title ?? '');
  late final TextEditingController _descriptionCtrl = TextEditingController(text: widget.initial?.description ?? '');
  late final TextEditingController _discountValueCtrl = TextEditingController(
    text: widget.initial?.discountValue.toString() ?? '',
  );
  late final TextEditingController _minOrderCtrl =
      TextEditingController(text: widget.initial?.minOrderValue?.toString() ?? '');
  late final TextEditingController _maxDiscountCtrl =
      TextEditingController(text: widget.initial?.maxDiscount?.toString() ?? '');
  late final TextEditingController _usageLimitCtrl =
      TextEditingController(text: widget.initial?.usageLimit?.toString() ?? '');

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initial?.startDate;
    _endDate = widget.initial?.endDate;
    final resolvedStatus =
        widget.initial == null ? VoucherStatus.active : resolveVoucherStatus(widget.initial!);
    _isActive = resolvedStatus == VoucherStatus.active;
    _status = _isActive ? VoucherStatus.active : VoucherStatus.inactive;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _discountValueCtrl.dispose();
    _minOrderCtrl.dispose();
    _maxDiscountCtrl.dispose();
    _usageLimitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 5,
                    decoration: BoxDecoration(
                      color: sellerBorder,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.initial == null ? 'Thêm voucher' : 'Chỉnh sửa voucher',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _Input(
                  controller: _codeCtrl,
                  label: 'Mã voucher',
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Nhập mã voucher';
                    if (text.contains(RegExp(r'\s'))) return 'Không có khoảng trắng';
                    return null;
                  },
                ),
                _Input(
                  controller: _titleCtrl,
                  label: 'Tiêu đề',
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Nhập tiêu đề' : null,
                ),
                _Input(
                  controller: _descriptionCtrl,
                  label: 'Mô tả',
                  maxLines: 2,
                ),
                DropdownButtonFormField<VoucherDiscountType>(
                  value: _discountType,
                  decoration: _inputDecoration('Kiểu giảm'),
                  items: const [
                    DropdownMenuItem(
                      value: VoucherDiscountType.percentage,
                      child: Text('Phần trăm'),
                    ),
                    DropdownMenuItem(
                      value: VoucherDiscountType.fixedAmount,
                      child: Text('Số tiền cố định'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _discountType = value;
                      if (_discountType == VoucherDiscountType.fixedAmount) {
                        _maxDiscountCtrl.text = _discountValueCtrl.text;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                _Input(
                  controller: _discountValueCtrl,
                  label: _discountType == VoucherDiscountType.percentage ? 'Giá trị (%)' : 'Giá trị (VND)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) return 'Giá trị phải lớn hơn 0';
                    if (_discountType == VoucherDiscountType.percentage && parsed > 100) return 'ối đa 100%';
                    return null;
                  },
                ),
                _Input(
                  controller: _minOrderCtrl,
                  label: 'Đơn tối thiểu (VND)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed < 0) return 'Nhập >= 0';
                    return null;
                  },
                ),
                if (_discountType == VoucherDiscountType.percentage)
                  _Input(
                    controller: _maxDiscountCtrl,
                    label: 'Giảm tối đa (VND)',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      final parsed = double.tryParse(value);
                      if (parsed == null || parsed < 0) return 'Nhập giảm tối đa >= 0';
                      return null;
                    },
                  ),
                _Input(
                  controller: _usageLimitCtrl,
                  label: 'Giới hạn lượt dùng',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final parsed = int.tryParse(value);
                    if (parsed == null || parsed < 0) return 'Nhập >= 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickStartDate(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: sellerAccent),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.play_circle_outline, color: sellerAccent),
                        label: Text(
                          _startDate == null ? 'Chọn ngày bắt đầu' : formatDateDisplay(_startDate),
                          style: const TextStyle(color: sellerAccent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickEndDate(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: sellerAccent),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.stop_circle_outlined, color: sellerAccent),
                        label: Text(
                          _endDate == null ? 'Chọn ngày kết thúc' : formatDateDisplay(_endDate),
                          style: const TextStyle(color: sellerAccent),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<VoucherStatus>(
                  value: _status,
                  decoration: _inputDecoration('Trạng thái'),
                  items: const [
                    DropdownMenuItem(value: VoucherStatus.active, child: Text('Kích hoạt')),
                    DropdownMenuItem(value: VoucherStatus.inactive, child: Text('Tạm ngưng')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _status = value;
                      _isActive = value == VoucherStatus.active;
                    });
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  activeColor: sellerAccent,
                  title: const Text('Kich hoat'),
                  onChanged: (value) => setState(() {
                    _isActive = value;
                    _status = value ? VoucherStatus.active : VoucherStatus.inactive;
                  }),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sellerAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _submit,
                    child: Text(widget.initial == null ? 'Tạo voucher' : 'Cập nhật'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: sellerBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final picked = await pickDateTime(
      context,
      initialDateTime: _startDate,
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final picked = await pickDateTime(
      context,
      initialDateTime: _endDate ?? _startDate,
      firstDate: _startDate ?? DateTime.now(),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày bắt đầu và kết thúc')),
      );
      return;
    }
    if (!_endDate!.isAfter(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ngày kết thúc phải lớn hơn ngày bắt đầu')),
      );
      return;
    }

    final code = _codeCtrl.text.trim().toUpperCase();
    final discountValue = double.parse(_discountValueCtrl.text.trim());
    if (_discountType == VoucherDiscountType.percentage && (discountValue <= 0 || discountValue > 100)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phần trăm giảm phải trong khoảng 1-100')),
      );
      return;
    }
    final minOrderValue = parseDoubleOrNull(_minOrderCtrl.text) ?? 0;
    if (minOrderValue < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đơn tối thiểu phải >= 0')),
      );
      return;
    }

    final maxDiscount = _discountType == VoucherDiscountType.fixedAmount
        ? discountValue
        : parseDoubleOrNull(_maxDiscountCtrl.text);
    final usageLimit = parseIntOrNull(_usageLimitCtrl.text);
    if (usageLimit != null && usageLimit < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giới hạn lượt dùng phải >= 0')),
      );
      return;
    }

    Navigator.of(context).pop(
      VoucherFormData(
        code: code,
        title: _titleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
        discountType: _discountType,
        discountValue: discountValue,
        minOrderValue: minOrderValue,
        maxDiscount: maxDiscount,
        startDate: _startDate,
        endDate: _endDate,
        usageLimit: usageLimit ?? 0,
        status: _isActive ? VoucherStatus.active : VoucherStatus.inactive,
        isActive: _isActive,
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const _Input({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: sellerBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
