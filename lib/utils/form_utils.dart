import 'package:flutter/material.dart';

Future<DateTime?> pickDateTime(
  BuildContext context, {
  DateTime? initialDateTime,
  DateTime? firstDate,
  DateTime? lastDate,
  String? dateHelpText,
  String cancelText = 'Huy',
  String confirmText = 'Chon',
}) async {
  final now = DateTime.now();
  final initial = initialDateTime ?? now;
  final date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: firstDate ?? DateTime(now.year - 5),
    lastDate: lastDate ?? DateTime(now.year + 5),
    helpText: dateHelpText,
    cancelText: cancelText,
    confirmText: confirmText,
  );
  if (date == null) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDateTime ?? initial),
  );
  if (time == null) {
    return DateTime(date.year, date.month, date.day);
  }
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

String formatDateDisplay(DateTime? value) {
  if (value == null) return 'Chon ngay';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

double? parseDoubleOrNull(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed);
}

int? parseIntOrNull(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return int.tryParse(trimmed);
}
