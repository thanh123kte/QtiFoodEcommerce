import 'package:flutter/material.dart';

class TimePickerTile extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final String? errorText;
  final VoidCallback onTap;

  const TimePickerTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20,10,20,10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null ? value!.format(context) : 'Chọn thời gian',
                  style: TextStyle(
                    color: value != null ? theme.colorScheme.onSurface : Colors.grey,
                  ),
                ),
                const Icon(Icons.access_time, color: Colors.orange,),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
