import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../../../../domain/entities/product_image_file.dart';
import '../../../../../domain/entities/store_category.dart';
import '../seller_products_view_model.dart';
import 'product_theme.dart';

class ProductFormSheet extends StatefulWidget {
  final ProductViewData? initial;
  final List<StoreCategory> storeCategories;

  const ProductFormSheet({
    super.key,
    this.initial,
    required this.storeCategories,
  });

  static Future<ProductFormResult?> show(
    BuildContext context, {
    ProductViewData? initial,
    required List<StoreCategory> storeCategories,
  }) {
    return showModalBottomSheet<ProductFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormSheet(
        initial: initial,
        storeCategories: storeCategories,
      ),
    );
  }

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  late final TextEditingController _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
  late final TextEditingController _descCtrl = TextEditingController(text: widget.initial?.description ?? '');
  late final TextEditingController _priceCtrl = TextEditingController(
    text: widget.initial == null ? '' : widget.initial!.price.toString(),
  );

  final ImagePicker _picker = ImagePicker();
  final List<_LocalImage> _images = [];
  bool _isPicking = false;
  String? _storeCategoryId;
  String _status = ProductStatus.available;
  bool _replaceExisting = false;

  @override
  void initState() {
    super.initState();
    _storeCategoryId = widget.initial?.storeCategoryId;
    _status = widget.initial?.status ?? ProductStatus.available;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final systemCategoryPreview = _resolveSystemCategoryId(_storeCategoryId);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 5,
                  decoration: BoxDecoration(
                    color: sellerBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.initial == null ? 'Thêm sản phẩm mới' : 'Cập nhật sản phẩm',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chia từng nhóm thông tin để dễ quản lý',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted),
                      ),
                    ],
                  ),
                  Chip(
                    label: Text(widget.initial == null ? 'Thêm mới' : 'Đang sửa'),
                    backgroundColor: sellerAccentSoft,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _FormSection(
                title: 'Thông tin cơ bản',
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: _inputDecoration('Tên sản phẩm', hint: 'VD: Trà sữa trân châu đường đen'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    decoration: _inputDecoration('Mô tả ngắn', hint: 'Mô tả giúp khách hiểu sản phẩm nhanh hơn'),
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration('Giá bán', hint: 'Nhập số, vd: 45000'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: _inputDecoration('Trạng thái'),
                    items: ProductStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(ProductStatus.label(status)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _status = value ?? ProductStatus.available),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _FormSection(
                title: 'Danh mục cửa hàng',
                description: 'Chọn danh mục cửa hàng',
                children: [
                  DropdownButtonFormField<String?>(
                    value: _storeCategoryId,
                    decoration: _inputDecoration('Danh mục cửa hàng'),
                    menuMaxHeight: 320,
                    items: [
                      ...widget.storeCategories.map(
                        (category) => DropdownMenuItem<String?>(
                          value: category.id.toString(),
                          child: Text(category.name),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _storeCategoryId = value),
                  ),
                  const SizedBox(height: 8),
                  _InlineNote(
                    text: systemCategoryPreview == null
                        ? 'Hệ thống sẽ tự đối chiếu danh mục hệ thống dựa trên danh mục của hàng.'
                        : 'Danh mục hệ thống sẽ gán: $systemCategoryPreview',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _FormSection(
                title: 'Ảnh sản phẩm',
                description: 'Giúp khách nhận diện nhanh, ưu tiên tối thiểu 2 ảnh rõ nét.',
                children: [
                  if (widget.initial?.images.isNotEmpty ?? false) ...[
                    Text(
                      'Ảnh hiện tại',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.initial!.images
                          .map(
                            (image) => ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                image.url,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Thay thế toàn bộ ảnh cũ bằng ảnh mới'),
                      value: _replaceExisting,
                      activeColor: sellerAccent,
                      onChanged: (value) => setState(() => _replaceExisting = value ?? false),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_images.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _images
                          .map(
                            (image) => Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    image.bytes,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: IconButton(
                                    iconSize: 20,
                                    splashRadius: 18,
                                    color: Colors.redAccent,
                                    onPressed: () => setState(() => _images.remove(image)),
                                    icon: const Icon(Icons.cancel),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    )
                  else
                    _InlineNote(text: 'Chưa chọn ảnh nào.'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isPicking ? null : _pickFromGallery,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: sellerAccent),
                          ),
                          icon: const Icon(Icons.photo_library_outlined, color: sellerAccent),
                          label: const Text('Thư viện', style: TextStyle(color: sellerAccent)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isPicking ? null : _captureFromCamera,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: sellerAccent),
                          ),
                          icon: const Icon(Icons.photo_camera_outlined, color: sellerAccent),
                          label: const Text('Máy ảnh', style: TextStyle(color: sellerAccent)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sellerAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _submit,
                  child: Text(widget.initial == null ? 'Lưu sản phẩm' : 'Cập nhật sản phẩm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: sellerBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isPicking = true);
    final files = await _picker.pickMultiImage(imageQuality: 85);
    await _addImages(files);
    setState(() => _isPicking = false);
  }

  Future<void> _captureFromCamera() async {
    setState(() => _isPicking = true);
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (file != null) {
      await _addImages([file]);
    }
    setState(() => _isPicking = false);
  }

  Future<void> _addImages(List<XFile> files) async {
    for (final file in files) {
      final bytes = await file.readAsBytes();
      _images.add(
        _LocalImage(
          bytes: bytes,
          fileName: _resolveFileName(file.path),
          mimeType: _guessMimeType(file.path),
        ),
      );
    }
    setState(() {});
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _showMessage('Tên sản phẩm không được để trống');
      return;
    }

    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) {
      _showMessage('Vui lòng nhập giá hợp lệ');
      return;
    }

    Navigator.of(context).pop(
      ProductFormResult(
        input: ProductFormInput(
          name: name,
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          price: price,
          status: _status,
          categoryId: _resolveSystemCategoryId(_storeCategoryId),
          storeCategoryId: _storeCategoryId,
        ),
        images: _images
            .map(
              (image) => ProductImageFile(
                bytes: image.bytes,
                fileName: image.fileName,
                mimeType: image.mimeType,
              ),
            )
            .toList(),
        replaceExistingImages: _replaceExisting,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _resolveFileName(String fullPath) {
    final base = path.basename(fullPath);
    if (base.isEmpty) {
      return 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }
    return base;
  }

  String? _guessMimeType(String fullPath) {
    final ext = path.extension(fullPath).toLowerCase();
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return null;
    }
  }

  String? _resolveSystemCategoryId(String? storeCategoryId) {
    if (storeCategoryId == null || storeCategoryId.isEmpty) {
      return widget.initial?.categoryId;
    }
    final parsed = int.tryParse(storeCategoryId);
    if (parsed != null) {
      for (final category in widget.storeCategories) {
        if (category.id == parsed) {
          final parent = category.parentCategoryId;
          if (parent != null && parent > 0) {
            return parent.toString();
          }
        }
      }
    }
    return widget.initial?.categoryId;
  }
}

class ProductFormResult {
  final ProductFormInput input;
  final List<ProductImageFile> images;
  final bool replaceExistingImages;

  const ProductFormResult({
    required this.input,
    required this.images,
    required this.replaceExistingImages,
  });
}

class _LocalImage {
  final Uint8List bytes;
  final String fileName;
  final String? mimeType;

  _LocalImage({
    required this.bytes,
    required this.fileName,
    this.mimeType,
  });
}

class _FormSection extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> children;

  const _FormSection({
    required this.title,
    this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sellerBorder),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted),
            ),
          ],
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InlineNote extends StatelessWidget {
  final String text;

  const _InlineNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: sellerBackground,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted),
      ),
    );
  }
}
