import 'package:flutter/material.dart';

class EditableTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final int? maxLines;
  final int? minLines;
  final TextStyle? textStyle;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final bool obscureText;
  final bool showLabel;
  final bool useCard;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry contentPadding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final TextStyle? hintStyle;
  final InputDecoration? decoration;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const EditableTile({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.maxLines = 1,
    this.minLines,
    this.textStyle,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
    this.obscureText = false,
    this.showLabel = false,
    this.useCard = false,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 10),
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.hintStyle = const TextStyle(color: Colors.grey),
    this.decoration,
    this.enabledBorder,
    this.focusedBorder,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      maxLines: maxLines,
      minLines: minLines,
      style: textStyle ?? const TextStyle(fontSize: 16),
      decoration: _buildDecoration(),
      validator: validator,
      readOnly: readOnly,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      onTap: onTap,
      focusNode: focusNode,
    );

    Widget content = field;
    if (padding != EdgeInsets.zero) {
      content = Padding(
        padding: padding,
        child: content,
      );
    }

    if (useCard) {
      return Card(
        margin: margin == EdgeInsets.zero
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 6)
            : margin,
        child: Padding(
          padding: padding == EdgeInsets.zero
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
              : padding,
          child: field,
        ),
      );
    }

    if (margin != EdgeInsets.zero) {
      content = Padding(
        padding: margin,
        child: content,
      );
    }
    return content;
  }

  InputDecoration _buildDecoration() {
    if (decoration != null) {
      return decoration!.copyWith(
        hintText: decoration!.hintText ?? hintText ?? label,
        labelText: decoration!.labelText ?? (showLabel ? label : null),
        suffixIcon: decoration!.suffixIcon ?? suffixIcon,
        prefixIcon: decoration!.prefixIcon ?? prefixIcon,
        contentPadding: decoration!.contentPadding ?? contentPadding,
      );
    }

    final InputBorder defaultEnabledBorder =
        enabledBorder ?? const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.3),
        );
    final InputBorder defaultFocusedBorder =
        focusedBorder ?? const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 0.8),
        );

    return InputDecoration(
      hintText: hintText ?? label,
      hintStyle: hintStyle,
      labelText: showLabel ? label : null,
      border: InputBorder.none,
      enabledBorder: defaultEnabledBorder,
      focusedBorder: defaultFocusedBorder,
      contentPadding: contentPadding,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }
}
