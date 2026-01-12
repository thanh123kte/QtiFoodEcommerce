import 'package:flutter/material.dart';

import '../../../../../domain/entities/address.dart';
import '../../../seller/products/widgets/product_theme.dart';

class AddressSelectionSheet extends StatelessWidget {
  final List<Address> addresses;
  final String? selectedId;
  final VoidCallback onManageTap;

  const AddressSelectionSheet({
    super.key,
    required this.addresses,
    required this.selectedId,
    required this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Chọn địa chỉ'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Divider(height: 1),
            if (addresses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Chưa có địa chỉ, hãy thêm mới.'),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return RadioListTile<String>(
                      value: address.id,
                      groupValue: selectedId,
                      onChanged: (_) => Navigator.of(context).pop(address),
                      title: Text('${address.receiver} | ${address.phone}'),
                      subtitle: Text(address.address),
                      secondary: address.isDefault ? const Icon(Icons.star, color: sellerAccent) : null,
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: sellerAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onManageTap,
                child: const Text('Quản lý địa chỉ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
