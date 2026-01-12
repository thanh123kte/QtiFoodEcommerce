import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_theme.dart';
import 'package:flutter/material.dart';

import '../order_detail_view_model.dart';

class OrderCustomerInfoCard extends StatelessWidget {
  final OrderDetailViewModel vm;

  const OrderCustomerInfoCard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoadingAddress) {
      return _InfoContainer(
        child: Row(
          children: const [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AddressTheme.primary),
            ),
            SizedBox(width: 10),
            Text('Dang tai dia chi...'),
          ],
        ),
      );
    }

    if (vm.addressError != null) {
      return _InfoContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vm.addressError!, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => vm.loadAddress(vm.order?.shippingAddressId),
              style: OutlinedButton.styleFrom(
                foregroundColor: AddressTheme.primary,
                side: const BorderSide(color: AddressTheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Thu lai'),
            ),
          ],
        ),
      );
    }

    final address = vm.address;
    if (address == null) {
      return const _InfoContainer(
        child: Text('Khong co dia chi giao hang'),
      );
    }

    return _InfoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin giao hàng',
            style: TextStyle(fontWeight: FontWeight.w800, color: AddressTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.person,
            label: address.receiver,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.phone,
            label: address.phone,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.location_on,
            label: address.address,
            multiLine: true,
          ),
        ],
      ),
    );
  }
}

class _InfoContainer extends StatelessWidget {
  final Widget child;

  const _InfoContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AddressTheme.border),
        boxShadow: AddressTheme.softShadow,
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool multiLine;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.multiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AddressTheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AddressTheme.textPrimary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
