import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/customer/addresses/widgets/address_theme.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({
    super.key,
    required this.nameController,
    required this.phoneController,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          decoration: AddressTheme.inputDecoration(
            'Họ và tên người nhận',
            suffixIcon: const Icon(Icons.person_outline, color: AddressTheme.primary),
          ),
          style: const TextStyle(fontSize: 16),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập họ tên';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: phoneController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
          ],
          decoration: AddressTheme.inputDecoration(
            'Số điện thoại người nhận',
            suffixIcon: const Icon(Icons.phone_outlined, color: AddressTheme.primary),
          ),
          style: const TextStyle(fontSize: 16),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập số điện thoại';
            }
            final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
            if (digits.length != 10) {
              return 'Số điện thoại chưa hợp lệ';
            }
            return null;
          },
        ),
      ],
    );
  }
}
