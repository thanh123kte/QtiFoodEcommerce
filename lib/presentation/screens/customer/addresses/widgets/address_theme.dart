import 'package:flutter/material.dart';

class AddressTheme {
  static const Color primary = Color(0xFFFF8A3D);
  static const Color softPrimary = Color(0xFFFFD5B0);
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFFFFAF6);
  static const Color border = Color(0xFFFFD1A3);
  static const Color textPrimary = Color(0xFF2F241F);
  static const Color textMuted = Color(0xFF7A5D4A);
  static const Color badge = Color(0xFFFFEFE3);

  static const LinearGradient pageGradient = LinearGradient(
    colors: [Color(0xFFFFFBF8), Color(0xFFFFF1E5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.orange.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];

  static InputDecoration inputDecoration(
    String hint, {
    Widget? suffixIcon,
    int minLines = 1,
    int? maxLines,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
      suffixIcon: suffixIcon,
    );
  }
}

class AddressPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;

  const AddressPill({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? AddressTheme.badge,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: AddressTheme.primary,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AddressTheme.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
