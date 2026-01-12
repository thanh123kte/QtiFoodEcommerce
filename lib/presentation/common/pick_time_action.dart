import 'package:flutter/material.dart';

class TimePickerHelper {
  static Future<TimeOfDay?> pickTime({
    required BuildContext context,
    required bool isOpen,
    TimeOfDay? openTime,
    TimeOfDay? closeTime,
  }) async {
    final initial = isOpen
        ? (openTime ?? const TimeOfDay(hour: 8, minute: 0))
        : (closeTime ?? const TimeOfDay(hour: 21, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    return picked;
  }
}
