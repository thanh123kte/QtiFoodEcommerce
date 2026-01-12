import 'package:flutter/material.dart';

import 'product_theme.dart';

class ProductSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
  });

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(covariant ProductSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleChange);
      widget.controller.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: 'Tìm sản phẩm...',
        prefixIcon: const Icon(Icons.search, color: sellerAccent),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                onPressed: widget.onClear,
                icon: const Icon(Icons.clear, color: sellerTextMuted),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: sellerBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: sellerBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: sellerAccent),
        ),
      ),
    );
  }
}
