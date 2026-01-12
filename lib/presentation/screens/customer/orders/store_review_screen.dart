import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'store_review_view_model.dart';

class StoreReviewScreen extends StatefulWidget {
  final int orderId;
  final int storeId;
  final String storeName;
  final String? storeAddress;

  const StoreReviewScreen({
    super.key,
    required this.orderId,
    required this.storeId,
    required this.storeName,
    this.storeAddress,
  });

  @override
  State<StoreReviewScreen> createState() => _StoreReviewScreenState();
}

class _StoreReviewScreenState extends State<StoreReviewScreen> {
  late final StoreReviewViewModel _viewModel = GetIt.I<StoreReviewViewModel>();
  late final ImagePicker _picker = ImagePicker();
  final TextEditingController _commentController = TextEditingController();

  final List<String> _quickTags = const [
    'Ngon',
    'Đóng gói tốt',
    'Giá hợp lý',
    'Phục vụ tốt',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<StoreReviewViewModel>(
        builder: (_, vm, __) {
          final state = vm.state;
          final selectedCount = state.images.length;
          final customerId = FirebaseAuth.instance.currentUser?.uid;

          return Scaffold(
            backgroundColor: const Color(0xFFFDF6EE),
            appBar: AppBar(
              backgroundColor: const Color(0xFFFFF1EA),
              elevation: 0,
              title: const Text('Đánh giá đơn hàng'),
              foregroundColor: const Color(0xFF2D1B12),
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SuccessBanner(storeName: widget.storeName, storeAddress: widget.storeAddress),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn đánh giá cửa hàng này thế nào?',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _RatingBar(
                    rating: state.rating,
                    onSelect: vm.setRating,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Rất tệ',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Tuyệt vời',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ImagePickerSection(
                    count: selectedCount,
                    images: state.images,
                    onAdd: _pickImage,
                    onRemove: vm.removeImageAt,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ảnh rõ món ăn sẽ giúp cửa hàng cải thiện chất lượng',
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  const Text('Cảm nhận của bạn (không bắt buộc)', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  _CommentField(
                    controller: _commentController,
                    onChanged: vm.setComment,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickTags
                        .map(
                          (t) => FilterChip(
                            label: Text(t),
                            selected: state.tags.contains(t),
                            onSelected: (_) => vm.toggleTag(t),
                            selectedColor: const Color(0xFFFFE7D8),
                            checkmarkColor: const Color(0xFFCC5C24),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: state.anonymous,
                    onChanged: (v) => vm.toggleAnonymous(v ?? false),
                    title: const Text('Ẩn danh đánh giá'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: customerId == null || state.isSubmitting
                        ? null
                        : () async {
                            final result = await vm.submit(
                              orderId: widget.orderId,
                              storeId: widget.storeId,
                              customerId: customerId,
                            );
                            result.when(
                              ok: (_) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã gửi đánh giá')),
                                );
                                Navigator.of(context).pop(true);
                              },
                              err: (message) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              },
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A45),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Gửi đánh giá', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file != null) {
      _viewModel.addImage(file);
    }
  }
}

class _SuccessBanner extends StatelessWidget {
  final String storeName;
  final String? storeAddress;

  const _SuccessBanner({required this.storeName, this.storeAddress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE7D8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle, color: Color(0xFFCC5C24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Đơn hàng đã giao thành công', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(storeName, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (storeAddress != null && storeAddress!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            storeAddress!,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onSelect;

  const _RatingBar({required this.rating, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final value = index + 1;
        final active = value <= rating;
        return IconButton(
          onPressed: () => onSelect(value),
          iconSize: 36,
          icon: Icon(
            active ? Icons.star_rounded : Icons.star_border_rounded,
            color: active ? const Color(0xFFFFA000) : Colors.grey.shade400,
          ),
        );
      }),
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  final int count;
  final List<XFile> images;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const _ImagePickerSection({
    required this.count,
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];
    tiles.add(_AddTile(onTap: onAdd, count: count));
    for (var i = 0; i < images.length; i++) {
      tiles.add(_ImageTile(file: images[i], onRemove: () => onRemove(i)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_camera_outlined, color: Color(0xFFCC5C24)),
            const SizedBox(width: 6),
            Text('Thêm ảnh món ăn ($count/5)', style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tiles,
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  final int count;

  const _AddTile({required this.onTap, required this.count});

  @override
  Widget build(BuildContext context) {
    final disabled = count >= 5;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: disabled ? Colors.grey.shade300 : const Color(0xFFCC5C24),
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            color: disabled ? Colors.grey.shade400 : const Color(0xFFCC5C24),
          ),
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _ImageTile({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(file.path),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CommentField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 5,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Món ăn nóng, đóng gói cẩn thận, sẽ ủng hộ lại',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}