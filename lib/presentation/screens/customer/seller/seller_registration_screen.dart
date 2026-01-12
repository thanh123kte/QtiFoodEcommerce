import 'package:datn_foodecommerce_flutter_app/presentation/common/address_type_ahead_field.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/build_header.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/editable_field.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/time_picker_tile.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/add_address_ui_state.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_theme.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/seller/widgets/seller_registration_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/create_store_input.dart';
import '../../../../domain/entities/store.dart';
import '../profile/profile_ui_state.dart';
import 'seller_registration_view_model.dart';

class SellerRegistrationScreen extends StatefulWidget {
  final String ownerId;
  final ProfileViewData? profile;

  const SellerRegistrationScreen({
    super.key,
    required this.ownerId,
    this.profile,
  });

  @override
  State<SellerRegistrationScreen> createState() => _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _imageUrlController = TextEditingController();

  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  String? _openTimeError;
  String? _closeTimeError;

  double? _latitude;
  double? _longitude;
  bool _suppressAddressChange = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    if (profile != null) {
      if (profile.displayName.trim().isNotEmpty) {
        _nameController.text = profile.displayName.trim();
      }
      if ((profile.email ?? '').trim().isNotEmpty) {
        _emailController.text = profile.email!.trim();
      }
      if ((profile.phone ?? '').trim().isNotEmpty) {
        _phoneController.text = profile.phone!.trim();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SellerRegistrationViewModel>(
      create: (_) => GetIt.I<SellerRegistrationViewModel>()..loadStore(widget.ownerId),
      child: Consumer<SellerRegistrationViewModel>(
        builder: (context, viewModel, _) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: AddressTheme.background,
              body: SafeArea(
                child: Container(
                  decoration: const BoxDecoration(gradient: AddressTheme.pageGradient),
                  child: Column(
                    children: [
                      const Header(title: 'Trở thành đối tác'),
                      Expanded(
                        child: viewModel.isLoadingStore
                            ? const _SellerLoading()
                            : viewModel.store != null
                                ? _buildStoreStatusSection(context, viewModel, viewModel.store!)
                                : _buildRegistrationForm(context, viewModel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegistrationForm(
    BuildContext context,
    SellerRegistrationViewModel viewModel,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SellerHeroCard(
              title: 'Mở cửa hàng của bạn',
              subtitle: 'Đăng ký cửa hàng để hiển thị với khách hàng và nhận đơn online.',
              icon: Icons.store_mall_directory_outlined,
            ),
            const SizedBox(height: 16),
            if (viewModel.loadStoreError != null)
              SellerSectionCard(
                title: 'Không tải được dữ liệu',
                subtitle: 'Thử lại để hoàn tất đăng ký',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.loadStoreError!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => viewModel.loadStore(widget.ownerId),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            if (viewModel.loadStoreError != null) const SizedBox(height: 14),
            SellerSectionCard(
              title: 'Thông tin cửa hàng',
              subtitle: 'Giúp khách hàng nhận diện và tin tưởng',
              child: Column(
                children: [
                  EditableTile(
                    padding: EdgeInsets.zero,
                    label: 'Tên cửa hàng',
                    hintText: 'Tên cửa hàng',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    suffixIcon: const Icon(Icons.store_outlined, color: AddressTheme.primary),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên cửa hàng';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  EditableTile(
                    padding: EdgeInsets.zero,
                    label: 'Mô tả',
                    hintText: 'Mô tả ngắn gọn về cửa hàng',
                    controller: _descriptionController,
                    textInputAction: TextInputAction.newline,
                    maxLines: 4,
                    minLines: 3,
                    suffixIcon: const Icon(Icons.description_outlined, color: AddressTheme.primary),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập mô tả cửa hàng';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SellerSectionCard(
              title: 'Liên hệ',
              subtitle: 'Số điện thoại và email cho khách hàng',
              child: Column(
                children: [
                  EditableTile(
                    padding: EdgeInsets.zero,
                    label: 'Số điện thoại',
                    hintText: 'Số điện thoại',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumberNational],
                    suffixIcon: const Icon(Icons.phone_outlined, color: AddressTheme.primary),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập số điện thoại';
                      }
                      if (value.trim().length < 9) {
                        return 'Số điện thoại chưa hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  EditableTile(
                    padding: EdgeInsets.zero,
                    label: 'Email',
                    hintText: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    suffixIcon: const Icon(Icons.email_outlined, color: AddressTheme.primary),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      final trimmed = value.trim();
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(trimmed)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SellerSectionCard(
              title: 'Địa chỉ cửa hàng',
              subtitle: 'Nhập địa chỉ chi tiết và tọa độ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddressTypeAheadField(
                    controller: _addressController,
                    isLoading: viewModel.isSuggestionLoading,
                    suggestionError: viewModel.suggestionError,
                    fetchSuggestions: viewModel.loadSuggestions,
                    itemBuilder: (context, suggestion) => ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(suggestion.title),
                      subtitle: Text(suggestion.address),
                    ),
                    onSelected: (suggestion) => _applySuggestion(context, viewModel, suggestion),
                    onChanged: (value) {
                      if (_suppressAddressChange) return;
                      viewModel.clearSelectedSuggestion();
                      viewModel.clearSuggestionError();
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập địa chỉ';
                      }
                      return null;
                    },
                  ),
                  if (_latitude != null && _longitude != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Toa do: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                        style: const TextStyle(color: AddressTheme.textMuted),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SellerSectionCard(
              title: 'Thời gian hoạt động',
              subtitle: 'Giờ mở cửa và đóng cửa',
              child: Column(
                children: [
                  TimePickerTile(
                    label: 'Giờ mở cửa',
                    value: _openTime,
                    errorText: _openTimeError,
                    onTap: () => _pickTime(isOpen: true),
                  ),
                  const SizedBox(height: 12),
                  TimePickerTile(
                    label: 'Giờ đóng cửa',
                    value: _closeTime,
                    errorText: _closeTimeError,
                    onTap: () => _pickTime(isOpen: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SellerTipBox(
              title: 'Mẹo nhỏ',
              message: 'Nhập mô tả ngon, số điện thoại rõ ràng và địa chỉ chính xác để được duyệt nhanh hơn.',
            ),
            const SizedBox(height: 20),
            if (viewModel.submissionError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  viewModel.submissionError!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: viewModel.isSubmitting ? null : () => _submit(context, viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AddressTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: viewModel.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Gửi yêu cầu đăng ký',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreStatusSection(
    BuildContext context,
    SellerRegistrationViewModel viewModel,
    Store store,
  ) {
    final status = viewModel.storeStatus;
    final isPending = viewModel.hasPendingStore;
    final statusLabel = _statusLabel(status);
    final statusDescription = isPending
        ? 'Yêu cầu đăng ký cửa hàng của bạn đang được xử lý. Vui lòng chờ xác duyệt.'
        : 'Trạng thái cửa hàng: $statusLabel.';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SellerHeroCard(
            title: 'Cửa hàng đã đăng ký',
            subtitle: 'ạn có thể theo dõi trạng thái và cập nhật thông tin khi cần.',
            icon: Icons.verified_outlined,
          ),
          const SizedBox(height: 16),
          SellerStatusCard(
            store: store,
            statusLabel: statusLabel,
            statusDescription: statusDescription,
            isPending: isPending,
            onRefresh: () => viewModel.loadStore(widget.ownerId),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    final upper = status.toUpperCase();
    switch (upper) {
      case 'PENDING':
        return 'Đang chờ duyệt';
      case 'APPROVED':
      case 'ACTIVE':
        return 'Đã phê duyệt';
      case 'REJECTED':
        return 'Bị từ chối';
      case 'INACTIVE':
        return 'Ngưng hoạt động';
      default:
        return status.isEmpty ? 'Không xác định' : status;
    }
  }

  Future<void> _pickTime({required bool isOpen}) async {
    final initial = isOpen ? _openTime : _closeTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (isOpen) {
          _openTime = picked;
          _openTimeError = null;
        } else {
          _closeTime = picked;
          _closeTimeError = null;
        }
      });
    }
  }

  void _applySuggestion(
    BuildContext context,
    SellerRegistrationViewModel viewModel,
    PlaceSuggestionViewData suggestion,
  ) {
    _suppressAddressChange = true;
    _addressController.text = suggestion.address;
    _addressController.selection = TextSelection.collapsed(offset: _addressController.text.length);
    _suppressAddressChange = false;
    setState(() {
      _latitude = suggestion.latitude;
      _longitude = suggestion.longitude;
    });
    viewModel.selectSuggestion(suggestion);
  }

  Future<void> _submit(
    BuildContext context,
    SellerRegistrationViewModel viewModel,
  ) async {
    if (widget.ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không xác định được tài khoản đăng ký')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_openTime == null) {
      setState(() => _openTimeError = 'Vui lòng chọn giờ mở cửa');
    }
    if (_closeTime == null) {
      setState(() => _closeTimeError = 'Vui lòng chọn giờ đóng cửa');
    }
    if (_openTime == null || _closeTime == null) {
      return;
    }

    final input = CreateStoreInput(
      ownerId: widget.ownerId,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: _latitude ?? 0,
      longitude: _longitude ?? 0,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      openTime: StoreDayTime(
        hour: _openTime!.hour,
        minute: _openTime!.minute,
        second: 0,
        nano: 0,
      ),
      closeTime: StoreDayTime(
        hour: _closeTime!.hour,
        minute: _closeTime!.minute,
        second: 0,
        nano: 0,
      ),
    );

    final result = await viewModel.submit(input);
    if (!mounted) return;

    result.when(
      ok: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký cửa hàng thành công')),
        );
        viewModel.loadStore(widget.ownerId);
      },
      err: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }
}

class _SellerLoading extends StatelessWidget {
  const _SellerLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(color: AddressTheme.primary),
      ),
    );
  }
}
