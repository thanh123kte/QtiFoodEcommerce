import 'dart:async';

import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/add_address_ui_state.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/screens/customer/addresses/widgets/address_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddressTypeAheadField extends StatelessWidget {
  const AddressTypeAheadField({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.suggestionError,
    required this.fetchSuggestions,
    required this.itemBuilder,
    required this.onSelected,
    required this.onChanged,
    required this.validator,
  });

  final TextEditingController controller;
  final bool isLoading;
  final String? suggestionError;
  final FutureOr<List<PlaceSuggestionViewData>> Function(String pattern) fetchSuggestions;

  final Widget Function(BuildContext, PlaceSuggestionViewData) itemBuilder;
  final void Function(PlaceSuggestionViewData) onSelected;

  final void Function(String) onChanged;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<PlaceSuggestionViewData>(
      debounceDuration: const Duration(milliseconds: 350),
      suggestionsCallback: (pattern) => fetchSuggestions(pattern.trim()),
      itemBuilder: itemBuilder,
      onSelected: (suggestion) {
        controller.text = suggestion.address;
        onSelected(suggestion);
      },
      builder: (context, providedController, focusNode) {
        if (providedController.text != controller.text) {
          providedController.value = controller.value;
        }

        return TextFormField(
          controller: providedController,
          focusNode: focusNode,
          maxLines: 3,
          minLines: 1,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            if (controller.text != value) {
              controller.value = providedController.value;
            }
            onChanged(value);
          },
          validator: validator,
          decoration: AddressTheme.inputDecoration(
            'Nhập địa chỉ giao hàng chi tiết',
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(
                    Icons.location_on_outlined,
                    color: AddressTheme.primary,
                  ),
          ),
        );
      },
      decorationBuilder: (context, child) => Material(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        child: child,
      ),
      emptyBuilder: (context) {
        if ((suggestionError ?? '').isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              suggestionError!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        return const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Không có gợi ý phù hợp'),
        );
      },
      loadingBuilder: (context) => const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorBuilder: (context, error) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text('$error', style: const TextStyle(color: Colors.redAccent)),
      ),
    );
  }
}
