import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:datn_foodecommerce_flutter_app/domain/entities/search_history.dart';
import 'package:datn_foodecommerce_flutter_app/utils/currency_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../domain/usecases/product/get_products.dart';
import '../../../../domain/usecases/product/search_by_image.dart';
import '../dashboard/customer_dashboard_view_model.dart';
import '../dashboard/customer_product_detail_screen.dart';
import 'customer_search_view_model.dart';
import 'image_search_result_screen.dart';
import 'image_search_result_view_model.dart';

const Color _searchAccent = Color(0xFFFF8A3D);
const Color _searchBackground = Color(0xFFFFF8F2);
const Color _searchSurface = Colors.white;
const Color _searchBorder = Color(0xFFFFE3CF);
const Color _searchMuted = Color(0xFF8B8B8B);

class CustomerSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const CustomerSearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  late final CustomerSearchViewModel _viewModel = GetIt.I<CustomerSearchViewModel>();
  late final FirebaseAuth _firebaseAuth = GetIt.I<FirebaseAuth>();
  late final SearchByImage _searchByImage = GetIt.I<SearchByImage>();
  late final GetFeaturedProducts _getFeaturedProducts = GetIt.I<GetFeaturedProducts>();
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialQuery ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadHistory(_firebaseAuth.currentUser?.uid);
      if ((_controller.text).trim().isNotEmpty) {
        _viewModel.search(keyword: _controller.text, userId: _firebaseAuth.currentUser?.uid);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CustomerSearchViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: _searchBackground,
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(context),
              Consumer<CustomerSearchViewModel>(
                builder: (_, vm, __) {
                  final hasHistory = vm.history.isNotEmpty;
                  return Column(
                    children: [
                      if (vm.isHistoryLoading)
                        const LinearProgressIndicator(
                          minHeight: 2,
                          color: _searchAccent,
                          backgroundColor: _searchBorder,
                        ),
                      if (hasHistory)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: _HistoryChips(
                            histories: vm.history,
                            onSelected: (keyword) {
                              _controller.text = keyword;
                              _controller.selection = TextSelection.fromPosition(
                                TextPosition(offset: _controller.text.length),
                              );
                              _triggerSearch(keyword);
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
              const Divider(height: 1, color: _searchBorder),
              Expanded(
                child: Consumer<CustomerSearchViewModel>(
                  builder: (_, vm, __) {
                    if (vm.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: _searchAccent),
                      );
                    }
                    if (vm.error != null) {
                      return _ErrorState(
                        message: vm.error!,
                        onRetry: () => _triggerSearch(_controller.text),
                      );
                    }
                    if (vm.results.isEmpty) {
                      return const _EmptyState();
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final item = vm.results[index];
                        return _SearchResultTile(
                          product: item,
                          onTap: () => _openProductDetail(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: _searchAccent),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _searchSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _searchBorder),
                boxShadow: const [
                  BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: _searchAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm sản phẩm',
                        hintStyle: TextStyle(color: _searchMuted),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: _triggerSearch,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: _searchMuted),
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                        });
                        _viewModel.search(keyword: '', userId: _firebaseAuth.currentUser?.uid);
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.search, color: _searchAccent),
                    onPressed: () => _triggerSearch(_controller.text),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: _searchAccent),
            onPressed: _showImagePickerOptions,
          ),
        ],
      ),
    );
  }

  void _triggerSearch(String keyword) {
    FocusScope.of(context).unfocus();
    _viewModel.search(keyword: keyword, userId: _firebaseAuth.currentUser?.uid);
    setState(() {});
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _searchSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chọn ảnh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: _searchAccent),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: _searchAccent),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile == null) return;

      if (!mounted) return;

      await _performImageSearch(pickedFile.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _performImageSearch(String imagePath) async {
    try {
      if (!mounted) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: _searchAccent),
              SizedBox(width: 16),
              Text('Đang tìm kiếm...'),
            ],
          ),
        ),
      );

      // Convert image to base64
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Call search API
      final result = await _searchByImage(base64Image: base64Image);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      result.when(
        ok: (productIds) {
          if (!mounted) return;

          final resultViewModel = ImageSearchResultViewModel(
            _getFeaturedProducts,
            productIds,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageSearchResultScreen(
                imagePath: imagePath,
                viewModel: resultViewModel,
                customerId: _firebaseAuth.currentUser?.uid,
              ),
            ),
          );
        },
        err: (message) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tìm kiếm thất bại: $message'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openProductDetail(DashboardProductTile product) {
    final userId = _firebaseAuth.currentUser?.uid;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerProductDetailScreen(
          product: product,
          customerId: userId,
        ),
      ),
    );
  }
}

class _HistoryChips extends StatelessWidget {
  final List<SearchHistory> histories;
  final ValueChanged<String> onSelected;

  const _HistoryChips({
    required this.histories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: const [
              Icon(Icons.history, size: 18, color: _searchAccent),
              SizedBox(width: 8),
              Text('Lịch sử tìm kiếm', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Material(
          color: _searchSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _searchBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: histories.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: _searchBorder),
            itemBuilder: (_, index) {
              final item = histories[index];
              return InkWell(
                onTap: () => onSelected(item.keyword),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.north_west, size: 16, color: _searchMuted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.keyword,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const Icon(Icons.close, size: 16, color: _searchMuted),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final DashboardProductTile product;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = product.status.trim().toUpperCase();
    final isUnavailable = status.contains('UNAVAILABLE');
    return Opacity(
      opacity: isUnavailable ? 0.5 : 1,
      child: Material(
        color: _searchSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _searchBorder),
        ),
        child: InkWell(
          onTap: isUnavailable ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.imageUrl == null
                      ? Container(
                          height: 64,
                          width: 64,
                          color: _searchBackground,
                          child: const Icon(Icons.image_not_supported),
                        )
                      : Image.network(
                          product.imageUrl!,
                          height: 64,
                          width: 64,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.description ?? 'Khong co mo ta',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _searchMuted),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            formatCurrency(product.discountPrice ?? product.price),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: _searchAccent),
                          ),
                          if (product.discountPrice != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                formatCurrency(product.price),
                                style: const TextStyle(
                                  color: _searchMuted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: _searchAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search_off, size: 48, color: _searchAccent),
          SizedBox(height: 8),
          Text('Không tìm thấy sản phẩm', style: TextStyle(color: _searchMuted)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: _searchAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
