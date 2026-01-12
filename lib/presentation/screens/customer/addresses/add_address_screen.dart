import 'dart:async';

import 'package:datn_foodecommerce_flutter_app/presentation/common/address_type_ahead_field.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/build_contract_section.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/build_header.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_form_widgets.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/create_address_input.dart';
import 'add_address_ui_state.dart';
import 'add_address_view_model.dart';
import 'address_screen_result.dart';
import 'addresses_ui_state.dart';

class AddAddressScreen extends StatefulWidget {
  final String userId;

  const AddAddressScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _receiverController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _suppressAddressChange = false;

  @override
  void dispose() {
    _receiverController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddAddressViewModel>(
      create: (_) => GetIt.I<AddAddressViewModel>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AddressTheme.background,
            body: SafeArea(
              child: Container(
                decoration: const BoxDecoration(gradient: AddressTheme.pageGradient),
                child: Column(
                  children: [
                    const Header(title: 'Thêm địa chỉ mới'),
                    Expanded(
                      child: Consumer<AddAddressViewModel>(
                        builder: (context, viewModel, _) {
                          return GestureDetector(
                            onTap: () => FocusScope.of(context).unfocus(),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AddressHeroCard(
                                      title: 'Thông tin giao hàng',
                                      subtitle: 'Nhớ lưu địa chỉ thường dùng để đặt hàng chỉ trong một chạm.',
                                      icon: Icons.navigation_outlined,
                                    ),
                                    const SizedBox(height: 16),
                                    AddressSectionCard(
                                      title: 'Người nhận',
                                      subtitle: 'Cung cấp thông tin liên lạc rõ ràng',
                                      child: ContactSection(
                                        nameController: _receiverController,
                                        phoneController: _phoneController,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    AddressSectionCard(
                                      title: 'Địa chỉ giao hàng',
                                      subtitle: 'Nhập chi tiết hoặc chọn gợi ý từ bản đồ',
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
                                          Selector<AddAddressViewModel, String?>(
                                            selector: (_, vm) => vm.suggestionError,
                                            builder: (_, err, __) {
                                              if (err == null || err.isEmpty) {
                                                return const SizedBox.shrink();
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8),
                                                child: Text(
                                                  err,
                                                  style: const TextStyle(
                                                    color: Colors.redAccent,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _TipBox(
                                      title: 'Gợi ý nhỏ',
                                      message: 'Nên chọn địa chỉ mặc định gần bạn nhất để shipper giao nhanh và dễ dàng liên lạc.',
                                    ),
                                    const SizedBox(height: 18),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: viewModel.isSubmitting ? null : () => _onSubmit(context, viewModel),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AddressTheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          elevation: 0,
                                        ),
                                        child: viewModel.isSubmitting
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : const Text(
                                                'Lưu địa chỉ',
                                                style: TextStyle(fontWeight: FontWeight.w800),
                                              ),
                                      ),
                                    ),
                                    if (viewModel.submissionError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Text(
                                          viewModel.submissionError!,
                                          style: const TextStyle(color: Colors.redAccent),
                                        ),
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
    AddAddressViewModel viewModel,
    PlaceSuggestionViewData suggestion,
  ) {
    _unfocusIfNeeded(context);

    _suppressAddressChange = true;
    _addressController.text = suggestion.address;
    _addressController.selection = TextSelection.collapsed(offset: _addressController.text.length);
    _suppressAddressChange = false;

    viewModel.selectSuggestion(suggestion);
  }

  Future<void> _onSubmit(BuildContext context, AddAddressViewModel viewModel) async {
    _unfocusIfNeeded(context);

    final userId = widget.userId;
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Người dùng không khả dụng')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final selected = viewModel.selectedSuggestion;
    final latitude = selected?.latitude ?? 0;
    final longitude = selected?.longitude ?? 0;

    final input = CreateAddressInput(
      userId: userId,
      receiver: _receiverController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      latitude: latitude,
      longitude: longitude,
    );

    final result = await viewModel.submit(input);
    result.when(
      ok: (address) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address created successfully')),
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

class _TipBox extends StatelessWidget {
  final String title;
  final String message;

  const _TipBox({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AddressTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AddressTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AddressTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: AddressTheme.textMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
