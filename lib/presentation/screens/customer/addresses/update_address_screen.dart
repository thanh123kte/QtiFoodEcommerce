import 'package:datn_foodecommerce_flutter_app/presentation/common/address_type_ahead_field.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/build_contract_section.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/build_header.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_form_widgets.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/update_address_input.dart';
import 'add_address_ui_state.dart';
import 'address_screen_result.dart';
import 'addresses_ui_state.dart';
import 'update_address_view_model.dart';

class UpdateAddressScreen extends StatefulWidget {
  final AddressViewData address;

  const UpdateAddressScreen({
    super.key,
    required this.address,
  });

  @override
  State<UpdateAddressScreen> createState() => _UpdateAddressScreenState();
}

class _UpdateAddressScreenState extends State<UpdateAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _receiverController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  double _currentLatitude = 0;
  double _currentLongitude = 0;
  bool _suppressAddressChange = false;

  @override
  void initState() {
    super.initState();
    _receiverController = TextEditingController(text: widget.address.receiver);
    _phoneController = TextEditingController(text: widget.address.phone);
    _addressController = TextEditingController(text: widget.address.address);
    _currentLatitude = widget.address.latitude ?? 0;
    _currentLongitude = widget.address.longitude ?? 0;
  }

  @override
  void dispose() {
    _receiverController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdateAddressViewModel>(
      create: (_) {
        final viewModel = GetIt.I<UpdateAddressViewModel>();
        viewModel.setInitialData(
          addressId: widget.address.id,
          isDefault: widget.address.isDefault,
        );
        return viewModel;
      },
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AddressTheme.background,
            body: SafeArea(
              child: Container(
                decoration: const BoxDecoration(gradient: AddressTheme.pageGradient),
                child: Column(
                  children: [
                    const Header(title: 'Cập nhật địa chỉ'),
                    Expanded(
                      child: Consumer<UpdateAddressViewModel>(
                        builder: (context, viewModel, _) {
                          return GestureDetector(
                            onTap: () => FocusScope.of(context).unfocus(),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    AddressHeroCard(
                                      title: widget.address.isDefault ? 'Địa chỉ mặc định' : 'Chỉnh sửa địa chỉ',
                                      subtitle: widget.address.isDefault
                                          ? 'Đây là địa chỉ sẽ được ưu tiên khi bạn đặt hàng.'
                                          : 'Bạn có thể chọn làm mặc định để giao hàng nhanh hơn.',
                                      icon: Icons.edit_location_alt_outlined,
                                      trailing: AddressPill(
                                        label: widget.address.isDefault ? 'Mặc định' : 'Đang lưu',
                                        icon: widget.address.isDefault ? Icons.star_rounded : Icons.bookmark_border_outlined,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    AddressSectionCard(
                                      title: 'Người nhận',
                                      subtitle: 'Cập nhật thông tin liên lạc',
                                      child: ContactSection(
                                        nameController: _receiverController,
                                        phoneController: _phoneController,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    AddressSectionCard(
                                      title: 'Địa chỉ giao hàng',
                                      subtitle: 'Sửa nhanh địa chỉ cũ hoặc chọn gợi ý mới',
                                      child: Column(
                                        children: [
                                          AddressTypeAheadField(
                                            controller: _addressController,
                                            isLoading: viewModel.isSuggestionLoading,
                                            suggestionError: viewModel.suggestionError,
                                            fetchSuggestions: (pattern) => viewModel.loadSuggestions(pattern),
                                            itemBuilder: (context, suggestion) => ListTile(
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
                                                return 'Vui lòng nhập địa chỉ giao hàng';
                                              }
                                              return null;
                                            },
                                          ),
                                          Selector<UpdateAddressViewModel, String?>(
                                            selector: (_, vm) => vm.suggestionError,
                                            builder: (_, err, __) {
                                              if (err == null || err.isEmpty) {
                                                return const SizedBox.shrink();
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8),
                                                child: Text(
                                                  err,
                                                  style: const TextStyle(color: Colors.redAccent),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    AddressSectionCard(
                                      title: 'Tùy chọn',
                                      subtitle: 'Chọn làm địa chỉ mặc định',
                                      child: SwitchListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: const Text(
                                          'Đặt làm địa chỉ mặc định',
                                          style: TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        value: viewModel.isDefault,
                                        activeColor: AddressTheme.primary,
                                        onChanged: viewModel.setDefault,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _onSubmit(context, viewModel),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AddressTheme.primary,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              'Cập nhật',
                                              style: TextStyle(fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _confirmDelete(context, viewModel),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.redAccent,
                                              side: const BorderSide(color: Colors.redAccent),
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            ),
                                            child: const Text(
                                              'Xoa dia chi',
                                              style: TextStyle(fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _applySuggestion(
    BuildContext context,
    UpdateAddressViewModel viewModel,
    PlaceSuggestionViewData suggestion,
  ) {
    _unfocusIfNeeded(context);

    _suppressAddressChange = true;
    _addressController.text = suggestion.address;
    _addressController.selection = TextSelection.collapsed(offset: _addressController.text.length);
    _suppressAddressChange = false;

    setState(() {
      _currentLatitude = suggestion.latitude ?? _currentLatitude;
      _currentLongitude = suggestion.longitude ?? _currentLongitude;
    });

    viewModel.selectSuggestion(suggestion);
  }

  Future<void> _onSubmit(BuildContext context, UpdateAddressViewModel viewModel) async {
    _unfocusIfNeeded(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selected = viewModel.selectedSuggestion;
    final latitude = selected?.latitude ?? _currentLatitude;
    final longitude = selected?.longitude ?? _currentLongitude;

    final input = UpdateAddressInput(
      id: widget.address.id,
      receiver: _receiverController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      latitude: latitude,
      longitude: longitude,
      isDefault: viewModel.isDefault,
    );

    final result = await viewModel.submit(input);
    result.when(
      ok: (address) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Địa chỉ đã được cập nhật thành công')),
        );
        Navigator.of(context).pop(AddressScreenResult.updated(_mapToViewData(address)));
      },
      err: (message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    UpdateAddressViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Xóa địa chỉ'),
            content: const Text(
              'Bạn có chắc muốn xóa địa chỉ này? Thao tác này không thể hoàn tác.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final result = await viewModel.delete();
    result.when(
      ok: (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Địa chỉ đã được xóa thành công')),
        );
        Navigator.of(context).pop(AddressScreenResult.deleted(widget.address.id));
      },
      err: (message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  void _unfocusIfNeeded(BuildContext context) {
    final scope = FocusScope.of(context);
    if (!scope.hasPrimaryFocus && scope.focusedChild != null) {
      scope.unfocus();
    }
  }

  AddressViewData _mapToViewData(Address address) {
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
}
