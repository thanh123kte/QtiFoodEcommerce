import 'package:datn_foodecommerce_flutter_app/presentation/common/address_card.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/build_header.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/error_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../../domain/usecases/address/get_address_by_id.dart';
import 'add_address_screen.dart';
import 'address_screen_result.dart';
import 'addresses_ui_state.dart';
import 'addresses_view_model.dart';
import 'update_address_screen.dart';
import 'widgets/address_form_widgets.dart';
import 'widgets/address_theme.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late final FirebaseAuth _firebaseAuth = GetIt.I<FirebaseAuth>();
  late final AddressesViewModel _viewModel = GetIt.I<AddressesViewModel>();
  late final GetAddressById _getAddressById = GetIt.I<GetAddressById>();
  String? _userId;

  @override
  void initState() {
    super.initState();
    final uid = _firebaseAuth.currentUser?.uid ?? '';
    _userId = uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadAddresses(uid);
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openAddAddress() async {
    final userId = _userId ?? _firebaseAuth.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not available')),
      );
      return;
    }

    final result = await Navigator.of(context).push<AddressScreenResult?>(
      MaterialPageRoute(
        builder: (_) => AddAddressScreen(userId: userId),
      ),
    );

    if (result != null && mounted) {
      if (result.address != null) {
        _viewModel.upsertAddress(result.address!);
      }
      await _viewModel.refresh();
    }
  }

  Future<bool> _ensureAddressActive(String addressId) async {
    if (addressId.isEmpty) {
      _showSnack('Dia chi khong ton tai.');
      return false;
    }
    final result = await _getAddressById(addressId);
    bool isActive = false;
    result.when(
      ok: (address) {
        if (address.isDeleted) {
          _showSnack('Dia chi khong ton tai.');
          return;
        }
        isActive = true;
      },
      err: (_) {
        _showSnack('Dia chi khong ton tai.');
      },
    );
    return isActive;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openUpdateAddress(AddressViewData address) async {
    final isActive = await _ensureAddressActive(address.id);
    if (!mounted) return;
    if (!isActive) {
      await _viewModel.refresh();
      return;
    }

    final result = await Navigator.of(context).push<AddressScreenResult?>(
      MaterialPageRoute(
        builder: (_) => UpdateAddressScreen(address: address),
      ),
    );

    if (result != null && mounted) {
      if (result.isDeleted && result.deletedId != null) {
        _viewModel.removeAddress(result.deletedId!);
      } else if (result.address != null) {
        _viewModel.upsertAddress(result.address!);
      }
      await _viewModel.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddressesViewModel>.value(
      value: _viewModel,
      child: Consumer<AddressesViewModel>(
        builder: (_, vm, __) {
          final state = vm.uiState;
          final addresses = switch (state) {
            AddressesLoaded(:final addresses) => addresses,
            AddressesRefreshing(:final addresses) => addresses,
            _ => const <AddressViewData>[],
          };

          final isRefreshing = state is AddressesRefreshing;
          final isLoading = state is AddressesLoading || state is AddressesInitial;

          return Scaffold(
            backgroundColor: AddressTheme.background,
            floatingActionButton: _AddAddressButton(onPressed: _openAddAddress),
            bottomNavigationBar: isRefreshing
                ? const LinearProgressIndicator(
                    minHeight: 2,
                    color: AddressTheme.primary,
                    backgroundColor: Colors.transparent,
                  )
                : null,
            body: SafeArea(
              child: Container(
                decoration: const BoxDecoration(gradient: AddressTheme.pageGradient),
                child: Column(
                  children: [
                    const Header(title: 'Địa chỉ của tôi'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: AddressHeroCard(
                        title: 'Quản lý địa chỉ',
                        subtitle: 'Lưu trữ địa chỉ giao hàng để thanh toán nhanh hơn và lưu ý tình trạng mặc định.',
                        icon: Icons.map_outlined,
                        trailing: _AddressCounterPill(
                          count: addresses.length,
                          isLoading: isLoading,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: AddressTheme.primary,
                        onRefresh: vm.refresh,
                        child: _AddressStateView(
                          state: state,
                          addresses: addresses,
                          isLoading: isLoading,
                          onEdit: _openUpdateAddress,
                          onAdd: _openAddAddress,
                          onRetry: vm.refresh,
                        ),
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
}

class _AddAddressButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddAddressButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AddressTheme.primary,
      foregroundColor: Colors.white,
      elevation: 3,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Thêm địa chỉ',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AddressCounterPill extends StatelessWidget {
  final int count;
  final bool isLoading;

  const _AddressCounterPill({
    required this.count,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AddressTheme.badge,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AddressTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.home_outlined, size: 16, color: AddressTheme.primary),
          const SizedBox(width: 6),
          Text(
            isLoading ? 'Đang cập nhật...' : '$count địa chỉ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AddressTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressStateView extends StatelessWidget {
  final AddressesUiState state;
  final List<AddressViewData> addresses;
  final bool isLoading;
  final ValueChanged<AddressViewData> onEdit;
  final VoidCallback onAdd;
  final Future<void> Function() onRetry;

  const _AddressStateView({
    required this.state,
    required this.addresses,
    required this.isLoading,
    required this.onEdit,
    required this.onAdd,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _AddressSkeletonList();
    }

    if (state is AddressesError) {
      final message = (state as AddressesError).message;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
        children: [
          ErrorView(
            message: message,
            onRetry: onRetry,
          ),
        ],
      );
    }

    if (addresses.isEmpty) {
      return _AddressEmptyView(onAdd: onAdd);
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: addresses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final address = addresses[index];
        return AddressCard(
          data: address,
          showDefaultBadge: address.isDefault,
          onEdit: () => onEdit(address),
        );
      },
    );
  }
}

class _AddressEmptyView extends StatelessWidget {
  final VoidCallback onAdd;

  const _AddressEmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AddressTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AddressTheme.border),
            boxShadow: AddressTheme.softShadow,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AddressTheme.primary.withOpacity(0.08),
                ),
                child: const Icon(
                  Icons.location_off_outlined,
                  size: 36,
                  color: AddressTheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có địa chỉ giao hàng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AddressTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Thêm địa chỉ mặc định để giao hàng nhanh hơn và tính phí chính xác.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AddressTheme.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AddressTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Thêm địa chỉ ngay',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddressSkeletonList extends StatelessWidget {
  const _AddressSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemBuilder: (_, __) => const _AddressSkeletonCard(),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: 3,
    );
  }
}

class _AddressSkeletonCard extends StatelessWidget {
  const _AddressSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AddressTheme.border),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8F1), Color(0xFFFFEFDF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AddressTheme.softShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -10,
            child: Icon(
              Icons.blur_on_rounded,
              color: AddressTheme.primary.withOpacity(0.06),
              size: 120,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 14,
                  decoration: _placeholder(),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: _placeholder(),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 140,
                  height: 14,
                  decoration: _placeholder(),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 12,
                      decoration: _placeholder(),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: _placeholder(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _placeholder() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(8),
    );
  }
}
