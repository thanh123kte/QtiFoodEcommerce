import 'package:flutter/material.dart';

class DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const DatePickerTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value == null ? 'Chưa cập nhật' : '${value!.day}/${value!.month}/${value!.year}';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(displayValue, style: const TextStyle(fontSize: 16)),
        onTap: onTap,
      ),
    );
  }
}