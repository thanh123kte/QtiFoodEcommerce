import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../config/server_config.dart';
import '../../../../domain/entities/store.dart';
import '../../../../domain/entities/update_store_input.dart';
import '../../seller/products/widgets/product_theme.dart';
import 'seller_profile_overview_state.dart';
import 'seller_store_info_view_model.dart';

class SellerStoreInfoScreen extends StatefulWidget {
  final SellerProfileViewData data;

  const SellerStoreInfoScreen({super.key, required this.data});

  @override
  State<SellerStoreInfoScreen> createState() => _SellerStoreInfoScreenState();
}

class _SellerStoreInfoScreenState extends State<SellerStoreInfoScreen> {
  late SellerProfileViewData _data = widget.data;
  late final SellerStoreInfoViewModel _viewModel = GetIt.I<SellerStoreInfoViewModel>();
  late final ImagePicker _picker = ImagePicker();
  bool _hasChanges = false;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    final result = await _viewModel.uploadAvatar(_data.storeId, pickedFile.path);
    result.when(
      ok: (imageUrl) {
        if (!mounted) return;
        setState(() {
          _data = _data.copyWith(avatarUrl: imageUrl);
          _hasChanges = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật ảnh đại diện cửa hàng.')),
        );
      },
      err: (message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SellerStoreInfoViewModel>.value(
      value: _viewModel,
      child: Consumer<SellerStoreInfoViewModel>(
        builder: (_, vm, __) {
          return WillPopScope(
            onWillPop: () async {
              _handleBack();
              return false;
            },
            child: Scaffold(
              backgroundColor: sellerBackground,
              appBar: AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                title: const Text('Thông tin cửa hàng'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _handleBack,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: vm.isSaving ? null : _openEditSheet,
                    tooltip: 'Chỉnh sửa',
                  ),
                ],
              ),
              body: Column(
                children: [
                  if (vm.isSaving) const LinearProgressIndicator(minHeight: 3, color: sellerAccent),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        _StoreHeader(
                          data: _data,
                          onEditAvatar: _pickAndUploadAvatar,
                          uploadingAvatar: vm.isUploadingAvatar,
                        ),
                        const SizedBox(height: 16),
                        _InfoSection(
                          title: 'Liên hệ',
                          items: [
                            _InfoRow(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: _formatValue(_data.email, emptyText: 'Chưa cập nhật email.'),
                            ),
                            _InfoRow(
                              icon: Icons.phone_outlined,
                              label: 'Số điện thoại',
                              value: _formatValue(_data.phone, emptyText: 'Chưa cập nhật số điện thoại.'),
                            ),
                            _InfoRow(
                              icon: Icons.place_outlined,
                              label: 'Địa chỉ',
                              value: _formatValue(_data.address, emptyText: 'Chưa cập nhật địa chỉ.'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InfoSection(
                          title: 'Mô tả và giờ hoạt động',
                          items: [
                            _InfoRow(
                              icon: Icons.description_outlined,
                              label: 'Mô tả',
                              value: _formatValue(
                                _data.description,
                                emptyText: 'Chưa có mô tả cho cửa hàng này.',
                              ),
                            ),
                            _InfoRow(
                              icon: Icons.wb_sunny_outlined,
                              label: 'Giờ mở cửa',
                              value: _formatTime(_data.openTime),
                            ),
                            _InfoRow(
                              icon: Icons.nightlight_outlined,
                              label: 'Giờ đóng cửa',
                              value: _formatTime(_data.closeTime),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleBack() {
    Navigator.of(context).pop(_hasChanges);
  }

  Future<void> _openEditSheet() async {
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<_EditStoreResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditStoreSheet(data: _data),
    );

    if (result == null) return;

    final input = _buildUpdateInput(result);
    if (input == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có thay đổi để cập nhật.')),
      );
      return;
    }

    final vm = _viewModel;
    final updateResult = await vm.updateStoreInfo(
      storeId: _data.storeId,
      input: input,
    );

    updateResult.when(
      ok: (updatedData) {
        if (!mounted) return;
        setState(() {
          _data = updatedData;
          _hasChanges = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật thông tin cửa hàng.')),
        );
      },
      err: (message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  UpdateStoreInput? _buildUpdateInput(_EditStoreResult result) {
    String? valueIfChanged(String? nextValue, String? currentValue) {
      final normalizedNext = (nextValue ?? '').trim();
      final normalizedCurrent = (currentValue ?? '').trim();
      if (normalizedNext.isEmpty && normalizedCurrent.isEmpty) {
        return null;
      }
      if (normalizedNext == normalizedCurrent) {
        return null;
      }
      return normalizedNext.isEmpty ? null : normalizedNext;
    }

    StoreDayTime? timeIfChanged(TimeOfDay? picked, StoreDayTime? current) {
      if (picked == null) return null;
      if (current != null && current.hour == picked.hour && current.minute == picked.minute) {
        return null;
      }
      return StoreDayTime(
        hour: picked.hour,
        minute: picked.minute,
        second: 0,
        nano: 0,
      );
    }

    final input = UpdateStoreInput(
      name: valueIfChanged(result.name, _data.name),
      description: valueIfChanged(result.description, _data.description),
      address: valueIfChanged(result.address, _data.address),
      email: valueIfChanged(result.email, _data.email),
      phone: valueIfChanged(result.phone, _data.phone),
      openTime: timeIfChanged(result.openTime, _data.openTime),
      closeTime: timeIfChanged(result.closeTime, _data.closeTime),
    );

    return input.toJson().isEmpty ? null : input;
  }

  String _formatValue(String? value, {String emptyText = 'Chua cap nhat'}) {
    if (value == null) return emptyText;
    final trimmed = value.trim();
    return trimmed.isEmpty ? emptyText : trimmed;
  }

  String _formatTime(StoreDayTime? time) {
    return time?.toLocalTimeString() ?? 'Chua cap nhat';
  }
}

class _StoreHeader extends StatelessWidget {
  final SellerProfileViewData data;
  final VoidCallback onEditAvatar;
  final bool uploadingAvatar;

  const _StoreHeader({
    required this.data,
    required this.onEditAvatar,
    required this.uploadingAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = resolveServerAssetUrl(data.avatarUrl);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Colors.white, sellerBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: sellerBorder),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 56,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                backgroundColor: Colors.white,
                child: avatarUrl == null ? const Icon(Icons.storefront, size: 44, color: sellerAccent) : null,
              ),
              if (uploadingAvatar)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: uploadingAvatar ? null : onEditAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sellerAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            data.description?.isNotEmpty == true
                ? data.description!
                : 'Cập nhật mô tả ngắn để thu hút khách hàng.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: sellerTextMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoRow> items;

  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sellerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: sellerBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: sellerAccent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted)),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditStoreResult {
  final String name;
  final String? description;
  final String? address;
  final String? email;
  final String? phone;
  final TimeOfDay? openTime;
  final TimeOfDay? closeTime;

  _EditStoreResult({
    required this.name,
    this.description,
    this.address,
    this.email,
    this.phone,
    this.openTime,
    this.closeTime,
  });
}

class _EditStoreSheet extends StatefulWidget {
  final SellerProfileViewData data;

  const _EditStoreSheet({required this.data});

  @override
  State<_EditStoreSheet> createState() => _EditStoreSheetState();
}

class _EditStoreSheetState extends State<_EditStoreSheet> {
  late final TextEditingController _nameCtrl = TextEditingController(text: widget.data.name);
  late final TextEditingController _descriptionCtrl = TextEditingController(text: widget.data.description ?? '');
  late final TextEditingController _addressCtrl = TextEditingController(text: widget.data.address ?? '');
  late final TextEditingController _emailCtrl = TextEditingController(text: widget.data.email ?? '');
  late final TextEditingController _phoneCtrl = TextEditingController(text: widget.data.phone ?? '');
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;

  @override
  void initState() {
    super.initState();
    _openTime = _toTimeOfDay(widget.data.openTime) ?? const TimeOfDay(hour: 8, minute: 0);
    _closeTime = _toTimeOfDay(widget.data.closeTime) ?? const TimeOfDay(hour: 21, minute: 0);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
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
                'Cập nhật thông tin cửa hàng',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _LabeledField(
                controller: _nameCtrl,
                label: 'Tên cửa hàng',
                hint: 'Nhập tên cửa hàng',
              ),
              _LabeledField(
                controller: _descriptionCtrl,
                label: 'Mô tả',
                hint: 'Mô tả ngắn',
                maxLines: 3,
              ),
              _LabeledField(
                controller: _addressCtrl,
                label: 'Địa chỉ',
                hint: 'Số nhà, đường, phường',
                maxLines: 2,
              ),
              _LabeledField(
                controller: _emailCtrl,
                label: 'Email',
                hint: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              _LabeledField(
                controller: _phoneCtrl,
                label: 'Số điện thoại',
                hint: 'Nhập số liên hệ',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _TimePickerField(
                      label: 'Giờ mở cửa',
                      time: _openTime,
                      onTap: () => _pickTime(isOpen: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimePickerField(
                      label: 'Giờ đóng cửa',
                      time: _closeTime,
                      onTap: () => _pickTime(isOpen: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
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
                  child: const Text('Lưu thay đổi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime({required bool isOpen}) async {
    final initial = isOpen ? (_openTime ?? const TimeOfDay(hour: 8, minute: 0)) : (_closeTime ?? const TimeOfDay(hour: 21, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;
    setState(() {
      if (isOpen) {
        _openTime = picked;
      } else {
        _closeTime = picked;
      }
    });
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên cửa hàng không được để trống.')),
      );
      return;
    }
    Navigator.of(context).pop(
      _EditStoreResult(
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        openTime: _openTime,
        closeTime: _closeTime,
      ),
    );
  }

  TimeOfDay? _toTimeOfDay(StoreDayTime? time) {
    if (time == null) return null;
    int clamp(int value, int max) {
      if (value < 0) return 0;
      if (value > max) return max;
      return value;
    }

    return TimeOfDay(
      hour: clamp(time.hour, 23),
      minute: clamp(time.minute, 59),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimePickerField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = time == null ? 'Chưa chọn' : time!.format(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: sellerBackground,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        child: Text(display),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType keyboardType;

  const _LabeledField({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: sellerBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
